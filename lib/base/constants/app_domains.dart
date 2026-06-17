/// Canonical public domains and app store identifiers.
///
/// **Website / share links** use [webHost] (`api.uydosh.com`).
/// **Store package / bundle IDs** use [androidApplicationId] (`com.uydosh.app`) —
/// do not change those to `api.uydosh.com`; they are unrelated to the public URL.
abstract final class AppDomains {
  /// Hostname for https share links and universal links (no scheme).
  static const webHost = 'api.uydosh.com';

  /// Base URL for shareable listing links (`https://api.uydosh.com/listing/123`).
  static const shareWebBase = 'https://$webHost';

  /// Marketing/support domain. This may differ from the deep-link host while
  /// the API host handles Universal Links / App Links.
  static const marketingWebHost = 'uydosh.com';

  static const supportEmail = 'support@$marketingWebHost';

  /// Previous marketing domain; still accepted when opening old shared links.
  static const legacyWebHost = 'uydosh.app';

  /// Google Play / Firebase Android applicationId (not a website).
  static const androidApplicationId = 'com.uydosh.app';

  /// macOS bundle identifier (not a website).
  static const macosBundleId = 'com.uydosh.app';

  static bool isListingLinkHost(String host) {
    final h = host.toLowerCase();
    return h == webHost ||
        h == marketingWebHost ||
        h == 'www.$marketingWebHost' ||
        h == legacyWebHost ||
        h == 'www.$legacyWebHost';
  }
}
