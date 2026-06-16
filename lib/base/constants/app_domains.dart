/// Canonical public domains and app store identifiers.
///
/// **Website / share links** use [webHost] (`uydosh.com`).
/// **Store package / bundle IDs** use [androidApplicationId] (`com.uydosh.app`) —
/// do not change those to `uydosh.com`; they are unrelated to the public URL.
abstract final class AppDomains {
  /// Hostname for https share links and universal links (no scheme).
  static const webHost = 'uydosh.com';

  /// Base URL for shareable listing links (`https://uydosh.com/listing/123`).
  static const shareWebBase = 'https://$webHost';

  static const supportEmail = 'support@$webHost';

  /// Previous marketing domain; still accepted when opening old shared links.
  static const legacyWebHost = 'uydosh.app';

  /// Google Play / Firebase Android applicationId (not a website).
  static const androidApplicationId = 'com.uydosh.app';

  /// macOS bundle identifier (not a website).
  static const macosBundleId = 'com.uydosh.app';

  static bool isListingLinkHost(String host) {
    final h = host.toLowerCase();
    return h == webHost || h == 'www.$webHost' || h == legacyWebHost || h == 'www.$legacyWebHost';
  }
}
