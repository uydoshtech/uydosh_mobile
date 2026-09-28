import "dart:async";
import "package:dio/dio.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/utils/toast_reporting.dart";
import "package:uy_dosh/domain/services/listing_claim_service.dart";

/// Server eligibility is the only authority; local storage only remembers prompts.
class ListingClaimBanner extends StatefulWidget {
  const ListingClaimBanner({
    required this.listingId,
    required this.onClaimed,
    super.key,
  });
  final int listingId;
  final VoidCallback onClaimed;

  @override
  State<ListingClaimBanner> createState() => _ListingClaimBannerState();
}

class _ListingClaimBannerState extends State<ListingClaimBanner>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final _service = ListingClaimService(getIt<IOAuthApiClient>());
  static final Set<String> _seen = {};
  ListingClaimEligibility? _eligibility;
  int? _userId;
  int _generation = 0;
  bool _pending = false;

  @override
  void initState() {
    super.initState();
    AuthenticationState().addListener(_onAuthChanged);
    unawaited(_check());
  }

  @override
  void didUpdateWidget(covariant ListingClaimBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_pending) unawaited(_check());
  }

  @override
  void dispose() {
    AuthenticationState().removeListener(_onAuthChanged);
    _generation++;
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() => _eligibility = null);
    unawaited(_check());
  }

  Future<void> _check({bool prompt = true}) async {
    final generation = ++_generation;
    if (!AuthenticationState().isAuthenticated) return;
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return;
      final eligibility = await _service.eligibility(widget.listingId);
      if (!mounted || generation != _generation) return;
      setState(() {
        _userId = userId;
        _eligibility = eligibility;
      });
      if (!eligibility.eligible || !prompt || _pending) return;
      final prefs = await SharedPreferences.getInstance();
      final key = _promptKey(userId);
      if (!mounted ||
          generation != _generation ||
          _seen.contains(key) ||
          prefs.getBool(key) == true)
        return;
      // Never put a prompt over a sign-in/profile route or another dialog.
      if (ModalRoute.of(context)?.isCurrent != true) return;
      await _offer();
    } catch (_) {
      // An optional prompt must not prevent viewing the listing.
    }
  }

  String _promptKey(int userId) =>
      "uydosh.claimPrompt.v1.$userId.${widget.listingId}";

  String get _message {
    final username = _eligibility?.telegramUsername;
    return username == null
        ? context.l10n.listing_claim_subtitle
        : context.l10n.listing_claim_account("@$username");
  }

  Future<void> _offer() async {
    final userId = _userId;
    if (_pending || userId == null || _eligibility?.eligible != true) return;
    setState(() => _pending = true);
    try {
      final key = _promptKey(userId);
      _seen.add(key);
      try {
        await (await SharedPreferences.getInstance()).setBool(key, true);
      } catch (_) {
        /* Memory fallback. */
      }
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.listing_claim_title),
          content: Text(_message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.listing_claim_later),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.listing_claim_button),
            ),
          ],
        ),
      );
      if (confirmed != true ||
          !mounted ||
          !AuthenticationState().isAuthenticated ||
          await SessionManager.getUserId() != userId)
        return;
      // Native sign-in may leave a new account without a profile. Reuse the
      // existing wizard and resume this exact claim only after it completes.
      try {
        await getIt<IUserProfileService>().getCurrentUserProfile();
      } on DioException catch (error) {
        if (error.response?.statusCode != 404) rethrow;
        if (!mounted) return;
        await context.pushAuthWizard(
          initialPage: 3,
          skipExistingSessionCheck: true,
          returnToPreviousRoute: true,
        );
        if (!mounted || await SessionManager.getUserId() != userId) return;
        try {
          await getIt<IUserProfileService>().getCurrentUserProfile();
        } on DioException catch (error) {
          if (error.response?.statusCode == 404) return;
          rethrow;
        }
      }
      if (!mounted ||
          !AuthenticationState().isAuthenticated ||
          await SessionManager.getUserId() != userId)
        return;
      await _service.claim(widget.listingId);
      if (!mounted || await SessionManager.getUserId() != userId) return;
      if (!mounted) return;
      setState(() => _eligibility = null);
      ToastReporting.successMessage(
        context,
        context.l10n.listing_claim_success,
      );
      widget.onClaimed();
    } catch (_) {
      if (!mounted) return;
      ToastReporting.errorMessage(context, context.l10n.listing_claim_error);
      await _check(prompt: false);
      if (mounted && _eligibility?.eligible == false) widget.onClaimed();
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_eligibility?.eligible != true) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.listing_claim_title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(_message),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _pending ? null : _offer,
                child: Text(
                  _pending
                      ? context.l10n.listing_claim_pending
                      : context.l10n.listing_claim_button,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
