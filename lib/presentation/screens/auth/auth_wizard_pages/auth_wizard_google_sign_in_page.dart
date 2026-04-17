import "package:cached_network_image/cached_network_image.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class AuthWizardGoogleSignInPage extends StatefulWidget {
  const AuthWizardGoogleSignInPage({
    required this.isAuthenticating,
    required this.isGoogleSignedIn,
    required this.currentUser,
    required this.onSignInWithGoogle,
    super.key,
  });

  final bool isAuthenticating;
  final bool isGoogleSignedIn;
  final User? currentUser;
  final VoidCallback onSignInWithGoogle;

  @override
  State<AuthWizardGoogleSignInPage> createState() =>
      _AuthWizardGoogleSignInPageState();
}

class _AuthWizardGoogleSignInPageState extends State<AuthWizardGoogleSignInPage> {
  bool _pressed = false;

  bool get _enabled => !widget.isAuthenticating;

  Color _getOnboardingTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _getOnboardingTextSecondaryColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    const loaderSlotHeight = 104.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: L10n.text(
                      "sign_in_with_google_description",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        height: 1.25,
                        color: _getOnboardingTextSecondaryColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (!widget.isGoogleSignedIn) ...[
                    Center(
                      child: SizedBox(
                        width: 199,
                        height: 44,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 90),
                          transform: Matrix4.translationValues(
                            0,
                            _pressed && _enabled ? 2 : 0,
                            0,
                          ),
                          child: InkWell(
                            onTap:
                                widget.isAuthenticating
                                    ? null
                                    : widget.onSignInWithGoogle,
                            borderRadius: BorderRadius.circular(22),
                            onHighlightChanged:
                                _enabled
                                    ? (v) => setState(() => _pressed = v)
                                    : null,
                            child: Opacity(
                              opacity: _enabled ? 1 : 0.55,
                              child: ListenableBuilder(
                                listenable: ThemeState(),
                                builder: (context, child) {
                                  final currentTheme =
                                      ThemeState().currentTheme;
                                  final svgAsset =
                                      currentTheme == AppTheme.lightTheme
                                          ? "assets/images/ios_dark_rd_ctn.svg"
                                          : "assets/images/ios_neutral_rd_ctn.svg";
                                  return SvgPicture.asset(
                                    svgAsset,
                                    width: 199,
                                    height: 44,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (widget.isGoogleSignedIn && widget.currentUser != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _getOnboardingTextColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          widget.currentUser!.photoURL != null
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: widget.currentUser!.photoURL!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    memCacheWidth: 120,
                                    memCacheHeight: 120,
                                    placeholder: (context, url) => ThemeIcon(
                                      Icons.person,
                                      size: 30,
                                      color: _getOnboardingTextColor(context),
                                    ),
                                    errorWidget: (context, url, error) => ThemeIcon(
                                      Icons.person,
                                      size: 30,
                                      color: _getOnboardingTextColor(context),
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 30,
                                  child: ThemeIcon(
                                    Icons.person,
                                    size: 30,
                                    color: _getOnboardingTextColor(context),
                                  ),
                                ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.currentUser!.displayName ?? "User",
                                  style: TextStyle(
                                    color: _getOnboardingTextColor(context),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.currentUser!.email ?? "",
                                  style: TextStyle(
                                    color: _getOnboardingTextSecondaryColor(context),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Reserve space so content doesn't jump when loader appears.
                  SizedBox(
                    height: loaderSlotHeight,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child:
                            widget.isAuthenticating
                                ? CenteredHouseLoadingIndicator(
                                  key: const ValueKey("auth_loader"),
                                  text: L10n.get("signing_in"),
                                  textStyle: TextStyle(
                                    color:
                                        _getOnboardingTextSecondaryColor(context),
                                    fontSize: 16,
                                  ),
                                )
                                : const SizedBox(
                                  key: ValueKey("auth_loader_placeholder"),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
