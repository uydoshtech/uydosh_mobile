/// When true, phone numbers, @Telegram handles, and t.me links are removed from
/// listing description text in the UI; owner profile hides Telegram card and call CTA.
/// Data may still exist in API/DB for internal use.
///
/// Kept false so scraped listing text is shown to users unmodified, as originally
/// posted; contacts found within it are rendered as tappable links/buttons instead
/// of being stripped out.
abstract final class ClientListingContactUiConfig {
  static const bool hidePublicContactDetails = false;
}
