/// When true, phone numbers, @Telegram handles, and t.me links are removed from
/// listing description text in the UI; owner profile hides Telegram card and call CTA.
/// Data may still exist in API/DB for internal use.
abstract final class ClientListingContactUiConfig {
  static const bool hidePublicContactDetails = true;
}
