import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/router/app_router_keys.dart" as router_keys;
import "package:uy_dosh/presentation/router/main_navigation.dart";
import "package:uy_dosh/presentation/widgets/tutorial/search_tutorial_overlay.dart";

export "package:uy_dosh/presentation/router/main_navigation.dart"
    show MainNavigation, MainNavigationState, mainNavigationKey;

class AppRouter {
  /// Global key for the profile icon in the app bar, used by the search tutorial.
  static GlobalKey<TutorialTargetWrapperState> get profileIconTutorialKey =>
      router_keys.profileIconTutorialKey;

  /// Global key for the main app bar notifications bell (saved alerts).
  static GlobalKey<TutorialTargetWrapperState>
      get notificationsBellTutorialKey => router_keys.notificationsBellTutorialKey;

  static Widget buildMainNavigation({
    bool attachKey = false,
    int initialIndex = 0,
  }) =>
      BlocProvider(
        create: (context) => ListingsBloc(getIt<IListingService>()),
        child: MainNavigation(
          key: attachKey ? mainNavigationKey : null,
          initialIndex: initialIndex,
        ),
      );

  static Widget get initialRoute => buildMainNavigation(attachKey: true);

  static Widget get mainNavigationRoute => buildMainNavigation();
}
