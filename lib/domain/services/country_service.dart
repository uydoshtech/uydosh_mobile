import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/cache/country_cache.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/models/country.dart";

/// Read-only access to the ISO 3166-1 country catalog.
///
/// Mirrors [IRegionService] / [CountryCache] — callers stay decoupled from
/// the data source, so the backing store can later move from the static
/// cache to an HTTP call without touching the UI.
abstract class ICountryService {
  /// All countries ordered for display in the current language (pinned
  /// CIS / neighbors first, then alphabetical by localized name).
  Future<List<Country>> getCountries(String language);

  /// Convenience lookup by ISO 3166-1 alpha-2 code.
  Future<Country?> getCountryByIso2(String iso2);
}

class CountryService implements ICountryService {
  CountryService(this._publicApiClient);

  // Unused today, kept in the constructor so this service matches the
  // shape of the other public services and slots into DI cleanly when we
  // switch to a backend-backed catalog.
  // ignore: unused_field
  final IPublicApiClient _publicApiClient;

  Future<void> _ensureInitialized() async {
    if (!CountryCache.isInitialized) {
      await CountryCache.initialize();
    }
  }

  @override
  Future<List<Country>> getCountries(String language) async {
    try {
      await _ensureInitialized();
      final countries = CountryCache.getCountriesSortedByLanguage(language);
      logger.d(
        "CountryService: returning ${countries.length} countries "
        "(lang=$language)",
      );
      return countries;
    } catch (error) {
      logger.d("CountryService.getCountries error: $error");
      rethrow;
    }
  }

  @override
  Future<Country?> getCountryByIso2(String iso2) async {
    await _ensureInitialized();
    return CountryCache.getCountryByIso2(iso2);
  }
}
