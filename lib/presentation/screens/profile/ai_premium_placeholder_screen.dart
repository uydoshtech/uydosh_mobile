import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";

/// Placeholder until Payme/Click checkout for [ai_premium_month] ships in-app.
class AiPremiumPlaceholderScreen extends StatelessWidget {
  const AiPremiumPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.get("ai_premium_placeholder_title")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          L10n.get("ai_premium_placeholder_body"),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
