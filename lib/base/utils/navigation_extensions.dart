import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_page_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_screen.dart";
import "package:uy_dosh/presentation/screens/profile/notifications_screen.dart";
import "package:uy_dosh/presentation/screens/profile/profile_screen.dart";

/// Navigation helpers to reduce duplication of Navigator.push / MaterialPageRoute.
extension NavigatorExtensions on BuildContext {
  /// Push listing detail screen with required BlocProvider.
  void pushListingDetail(int listingId) {
    Navigator.of(this).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => ListingDetailBloc(getIt<IListingService>()),
            ),
            BlocProvider(create: (_) => ListingDetailPageBloc()),
          ],
          child: ListingDetailScreen(listingId: listingId),
        ),
      ),
    );
  }

  /// Replace current route with listing detail screen.
  void pushReplaceListingDetail(int listingId) {
    Navigator.of(this).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => ListingDetailBloc(getIt<IListingService>()),
            ),
            BlocProvider(create: (_) => ListingDetailPageBloc()),
          ],
          child: ListingDetailScreen(listingId: listingId),
        ),
      ),
    );
  }

  /// Push auth wizard screen.
  void pushAuthWizard() {
    Navigator.of(this).push(
      MaterialPageRoute<void>(builder: (_) => const AuthWizardScreen()),
    );
  }

  /// Push auth wizard and remove all previous routes.
  void pushAuthWizardAndRemoveUntil() {
    Navigator.of(this).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AuthWizardScreen()),
      (route) => false,
    );
  }

  /// Replace current route with auth wizard.
  /// Returns the Future from Navigator.pushReplacement for chaining .then().
  Future<void> pushReplaceAuthWizard({
    int initialPage = 0,
    bool skipExistingSessionCheck = false,
  }) {
    return Navigator.of(this).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AuthWizardScreen(
          initialPage: initialPage,
          skipExistingSessionCheck: skipExistingSessionCheck,
        ),
      ),
    );
  }

  /// Push profile screen.
  void pushProfile() {
    Navigator.of(this).push(
      MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
    );
  }

  /// Push search notifications (saved search alerts) screen.
  void pushNotifications() {
    Navigator.of(this).push(
      MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
    );
  }

  /// Replace current route with main navigation (home).
  void pushReplaceMainNavigation() {
    Navigator.of(this).pushReplacement(
      // IMPORTANT: don't use `initialRoute` here.
      // `AppRouter.initialRoute` attaches the global `mainNavigationKey` so it
      // must only be mounted once at the true app root. During route
      // transitions Flutter can temporarily keep both old and new routes alive,
      // which would mount two widgets with the same GlobalKey and crash.
      MaterialPageRoute<void>(builder: (_) => AppRouter.mainNavigationRoute),
    );
  }

  /// Push main navigation and remove all previous routes.
  void pushMainNavigationAndRemoveUntil() {
    Navigator.of(this).pushAndRemoveUntil(
      // See note in `pushReplaceMainNavigation`.
      MaterialPageRoute<void>(builder: (_) => AppRouter.mainNavigationRoute),
      (route) => false,
    );
  }
}
