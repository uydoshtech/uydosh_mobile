/*
 * HTTP response cache policy for outbound Dio requests.
 *
 * Applied via `PublicDioConfigurator` so every client (public + OAuth) shares
 * one in-memory LRU store. By default NOTHING is cached — the global policy
 * is `CachePolicy.request` (honor server directives), and our backend does
 * not currently emit `Cache-Control`, so no response is stored unless a
 * caller explicitly opts in via `AppCache.longOptions` / `AppCache.shortOptions`.
 *
 * Opting in gives you:
 *   - Deduplication: concurrent identical GETs share a single network call.
 *   - Re-open speed: repeat GETs within the TTL return instantly from memory.
 *   - Offline fallback on network failure (see `hitCacheOnNetworkFailure`).
 *
 * The store is purely in-memory; it resets on app restart, so there is no
 * long-term staleness risk to worry about.
 */

import "package:dio/dio.dart";
import "package:dio_cache_interceptor/dio_cache_interceptor.dart";

class AppCache {
  AppCache._();

  /// Process-wide in-memory cache store, shared across all Dio instances.
  /// ~50 entries max; eviction is LRU.
  static final CacheStore store = MemCacheStore(maxSize: 10 * 1024 * 1024);

  /// Global default: honor HTTP cache directives. Since the backend does not
  /// send `Cache-Control`, this effectively disables caching by default.
  /// Individual requests opt in by passing `shortOptions` / `longOptions`.
  static final CacheOptions defaultOptions = CacheOptions(
    store: store,
    policy: CachePolicy.request,
    hitCacheOnErrorCodes: const [],
    hitCacheOnNetworkFailure: false,
    maxStale: null,
    priority: CachePriority.normal,
  );

  /// Short cache: ~60s. Use for slowly-changing data where a slightly stale
  /// response during a session is acceptable (e.g. public app settings,
  /// viewed listing details).
  static final CacheOptions shortOptions = defaultOptions.copyWith(
    policy: CachePolicy.forceCache,
    maxStale: const Duration(minutes: 1),
    hitCacheOnNetworkFailure: true,
    hitCacheOnErrorCodes: const [500, 502, 503, 504],
  );

  /// Long cache: ~1h. Use for near-static reference data (amenities,
  /// subway stations, regions) that rarely changes between app launches.
  static final CacheOptions longOptions = defaultOptions.copyWith(
    policy: CachePolicy.forceCache,
    maxStale: const Duration(hours: 1),
    hitCacheOnNetworkFailure: true,
    hitCacheOnErrorCodes: const [500, 502, 503, 504],
  );

  /// Convenience: Dio `Options` for a short-cached GET.
  static Options shortGetOptions() => shortOptions.toOptions();

  /// Convenience: Dio `Options` for a long-cached GET.
  static Options longGetOptions() => longOptions.toOptions();
}
