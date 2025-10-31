import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:curved_navigation_bar/curved_navigation_bar.dart";

import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/unread_messages_state.dart";

import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/location_service.dart";
import "package:uy_dosh/domain/services/subway_station_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_event.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_screen.dart";
import "package:uy_dosh/presentation/screens/create_listing/create_listing_screen.dart";
import "package:uy_dosh/presentation/screens/favorites/favorites_screen.dart";
import "package:uy_dosh/presentation/screens/home/home_screen.dart";
import "package:uy_dosh/presentation/screens/profile/profile_screen.dart";
import "package:uy_dosh/presentation/screens/messages/messages_inbox_screen.dart";
import "package:uy_dosh/presentation/widgets/burger_menu_widget.dart";
import "package:uy_dosh/presentation/widgets/curved_navigation_widget.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

import "package:firebase_auth/firebase_auth.dart";

class AppRouter {
  static Widget get initialRoute => BlocProvider(
    create: (context) {
      final bloc = ListingsBloc(getIt<IListingService>());
      bloc.add(const ListingsEvent.searchListings(isRefresh: true));
      return bloc;
    },
    child: MainNavigation(key: mainNavigationKey),
  );
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

// Global key to access MainNavigation state
final GlobalKey<_MainNavigationState> mainNavigationKey =
    GlobalKey<_MainNavigationState>();

class _MainNavigationState extends State<MainNavigation>
    with WidgetsBindingObserver {
  late int _currentIndex;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // Add observer for app lifecycle
    WidgetsBinding.instance.addObserver(this);

    // Listen to global authentication state changes
    AuthenticationState().addListener(() {
      if (mounted) {
        _checkAuthenticationStatus();
      }
    });

    // Check initial authentication status
    _checkAuthenticationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  // Check authentication status and adjust current index if needed
  Future<void> _checkAuthenticationStatus() async {
    try {
      final wasAuthenticated = _isAuthenticated;
      final authState = AuthenticationState();

      // Just read the current state without refreshing (to avoid infinite loops)
      _isAuthenticated = authState.isAuthenticated;

      // Only log when authentication state changes
      if (wasAuthenticated != _isAuthenticated) {
        debugPrint(
          "🔐 AppRouter: Auth state changed - was: $wasAuthenticated, now: $_isAuthenticated",
        );
        debugPrint(
          "🔐 AppRouter: Firebase user: ${FirebaseAuth.instance.currentUser?.email ?? "null"}",
        );

        // If user logged out (was authenticated but now is not), redirect to home
        if (wasAuthenticated && !_isAuthenticated) {
          debugPrint(
            "🔐 AppRouter: User logged out, redirecting to home screen",
          );

          // Pop any pushed screens (like ProfileScreen) and redirect to home
          if (mounted && Navigator.of(context).canPop()) {
            debugPrint("🔐 AppRouter: Popping pushed screens...");
            Navigator.of(context).pop();
          }

          // Redirect to home screen
          setState(() {
            _currentIndex = 0; // Redirect to home screen
          });
        } else if (!wasAuthenticated && _isAuthenticated) {
          debugPrint("🔐 AppRouter: User logged in, forcing UI rebuild");
          setState(() {
            // Force UI rebuild to update navigation bar
          });
        }
      }

      // Check if we need to redirect to auth wizard
      if (!_isAuthenticated && mounted) {
        // Check if we"re on a screen that requires authentication
        if (_currentIndex == 1) {
          // Favorites screen
          debugPrint(
            "🔐 AppRouter: User on favorites screen but not authenticated, redirecting to auth wizard",
          );
          _redirectToAuthWizard();
        } else if (_currentIndex == 2) {
          // Messages screen
          debugPrint(
            "🔐 AppRouter: User on messages screen but not authenticated, redirecting to auth wizard",
          );
          _redirectToAuthWizard();
        } else if (_currentIndex == 3) {
          // Create Listing screen
          debugPrint(
            "🔐 AppRouter: User on create listing screen but not authenticated, redirecting to auth wizard",
          );
          _redirectToAuthWizard();
        }
      }
    } catch (e) {
      debugPrint("❌ Auth check error: $e");
      _isAuthenticated = false;
    }
  }

  // Redirect to auth wizard
  void _redirectToAuthWizard() {
    if (mounted) {
      Navigator.of(context)
          .pushReplacement(
            MaterialPageRoute(builder: (context) => const AuthWizardScreen()),
          )
          .then((_) {
            // After successful authentication, ensure we're on home screen
            if (mounted) {
              setState(() {
                _currentIndex = 0; // Navigate to home screen
              });
            }
          });
    }
  }

  // Get screens based on authentication status
  List<Widget> _getScreens() {
    final screens = [
      BlocProvider(
        create: (context) {
          final bloc = ListingsBloc(getIt<IListingService>());
          bloc.add(const ListingsEvent.searchListings(isRefresh: true));
          return bloc;
        },
        child: BlocProvider(
          create: (context) {
            final messagingBloc = MessagingBloc(getIt<IMessagingService>());
            // Initialize conversations to get unread count
            messagingBloc.add(RefreshConversations());
            return messagingBloc;
          },
          child: const HomeScreen(),
        ),
      ),
      const FavoritesScreen(),
      const MessagesInboxScreen(
        showCustomHeader: false,
      ), // Conversations screen at index 2
    ];

    // Remove authentication check - always add Create Listing screen
    screens.add(
      BlocProvider(
        create: (context) => SubwayStationsBloc(getIt<ISubwayStationService>()),
        child: BlocProvider(
          create: (context) => LocationsBloc(getIt<ILocationService>()),
          child: const CreateListingScreen(),
        ),
      ),
    );

    return screens;
  }

  // Method to navigate to a specific index (can be called from outside)
  void navigateToIndex(int index) {
    debugPrint("🧭 MainNavigation: navigateToIndex called with index $index");
    if (mounted) {
      debugPrint(
        "🧭 MainNavigation: Setting _currentIndex from $_currentIndex to $index",
      );
      setState(() {
        _currentIndex = index;
      });
      debugPrint(
        "🧭 MainNavigation: Navigation completed, new index: $_currentIndex",
      );
    } else {
      debugPrint("❌ MainNavigation: Widget not mounted, navigation ignored");
    }
  }

  // Get the appropriate title for the current screen
  Widget _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return LanguageAwareStringHelper.getText(
          "home",
          context,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
      case 1:
        return LanguageAwareStringHelper.getText(
          "favorites_title",
          context,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
      case 2:
        return LanguageAwareStringHelper.getText(
          "conversations",
          context,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
      case 3:
        return LanguageAwareStringHelper.getText(
          "create_listing_title",
          context,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        title: _getAppBarTitle(),
        actions: [
          // Profile button on the right side with proper margin
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ListenableBuilder(
              listenable: AuthenticationState(),
              builder: (context, child) {
                final isAuthenticated = AuthenticationState().isAuthenticated;

                // Show themed circle when user is not authenticated
                if (!isAuthenticated) {
                  return ListenableBuilder(
                    listenable: ThemeState(),
                    builder: (context, child) {
                      final themeState = ThemeState();
                      Color borderColor;

                      if (themeState.isPurpleTheme || themeState.isBlueTheme) {
                        borderColor =
                            Colors
                                .white; // White border for blue and purple themes
                      } else {
                        borderColor =
                            Colors.black; // Black border for light theme
                      }

                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.transparent, // No background
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context)
                                .pushReplacement(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const AuthWizardScreen(),
                                  ),
                                )
                                .then((_) {
                                  // After successful authentication, redirect to home screen
                                  if (mounted) {
                                    setState(() {
                                      _currentIndex =
                                          0; // Navigate to home screen
                                    });
                                  }
                                });
                          },
                          icon: Icon(
                            Icons.person,
                            color: borderColor, // Same color as border
                            size: 20,
                          ),
                          tooltip: LanguageAwareStringHelper.getCurrent(
                            context,
                            "profile",
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      );
                    },
                  );
                }

                // Show just the person icon (no circle) when user is authenticated
                return ListenableBuilder(
                  listenable: ThemeState(),
                  builder: (context, child) {
                    final themeState = ThemeState();
                    Color iconColor;

                    if (themeState.isPurpleTheme || themeState.isBlueTheme) {
                      iconColor =
                          Colors.white; // White icon for blue and purple themes
                    } else {
                      iconColor = Colors.black; // Black icon for light theme
                    }

                    return IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.person, color: iconColor, size: 24),
                      tooltip: LanguageAwareStringHelper.getCurrent(
                        context,
                        "profile",
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      drawer: const BurgerMenuWidget(),
      onDrawerChanged: (isOpened) {
        if (isOpened) HapticFeedback.lightImpact();
      },
      body: IndexedStack(index: _currentIndex, children: _getScreens()),
      bottomNavigationBar: ListenableBuilder(
        listenable: UnreadMessagesState(),
        builder: (context, child) {
          return CustomCurvedNavigationBar(
            currentIndex: _currentIndex,
            navigationKey: _bottomNavigationKey,
            isAuthenticated: _isAuthenticated,
            hasUnreadMessages: UnreadMessagesState().hasUnreadMessages,
            onTap: (index) {
              HapticFeedback.lightImpact();

              // Handle authentication requirements
              if ((index == 1 || index == 2) && !_isAuthenticated) {
                // Favorites and Conversations require authentication
                return; // Don"t navigate, stay on current screen
              }

              // Allow navigation to all tabs
              setState(() {
                _currentIndex = index;
              });
            },
          );
        },
      ),
    );
  }
}
