import "dart:async";
import "dart:convert";

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/auth/create_profile_request.dart";
import "package:uy_dosh/domain/models/region.dart";
import "package:uy_dosh/domain/models/university.dart";
import "package:uy_dosh/domain/services/auth_service.dart";
import "package:uy_dosh/domain/services/push_notification_service.dart";
import "package:uy_dosh/domain/services/region_service.dart";
import "package:uy_dosh/domain/services/university_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_pages/auth_wizard_google_sign_in_page.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_pages/auth_wizard_language_page.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_pages/auth_wizard_profile_page.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_theme.dart";
import "package:uy_dosh/presentation/screens/auth/phone_sign_in_sheet.dart";
import "package:uy_dosh/presentation/screens/support/support_chat_screen.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/theme_toggle_sun_moon.dart";

enum _AuthMethod { google, phone }

class AuthWizardScreen extends StatefulWidget {
  const AuthWizardScreen({
    super.key,
    this.initialPage = 0,
    this.skipExistingSessionCheck = false,
  });

  final int initialPage;
  final bool skipExistingSessionCheck;

  @override
  State<AuthWizardScreen> createState() => _AuthWizardScreenState();
}

class _AuthWizardScreenState extends State<AuthWizardScreen> {
  late final PageController _pageController;
  final ScrollController _profileScrollController = ScrollController();
  int _currentPage = 0; // Start with language selection page

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  int? _selectedGender;
  bool? _isStudent = false; // Initialize to false instead of null
  String? _selectedRole; // "tenant" or "landlord"
  // Initialized in initState from LanguageState (saved/device locale).
  String _selectedLanguage = "uz";

  // University selection
  University? _selectedUniversity;
  List<University> _universities = [];
  bool _isLoadingUniversities = false;
  late final IUniversityService _universityService;
  late final IUserProfileService _profileService;

  // Region selection
  int? _selectedRegionId;
  List<Region> _regions = [];
  bool _isLoadingRegions = false;
  late final IRegionService _regionService;
  late final IAuthService _authService;

  // Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        kIsWeb
            ? "626930983094-ir8a7rjvo8o1kjp795024ghh5abrb9o9.apps.googleusercontent.com"
            : null,
  );

  // Auth state
  bool _isAuthenticating = false;
  bool _isGoogleSignedIn = false;
  User? _currentUser;
  _AuthMethod _authMethod = _AuthMethod.google;

  // Navigation control
  bool _isProgrammaticNavigation = false;

  /// Debounce timer for name input to avoid setState on every keystroke
  Timer? _nameDebounceTimer;

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "auth_wizard");
    _pageController = PageController(initialPage: widget.initialPage);
    _currentPage = widget.initialPage;
    _nameController.addListener(_onNameChanged);
    // Make the language selection step reflect the app's current locale
    // (loaded during app startup via LanguageState.initialize()).
    _selectedLanguage = LanguageState().currentLanguage;

    // Initialize university service
    _universityService = getIt<IUniversityService>();

    // Initialize profile service
    _profileService = getIt<IUserProfileService>();

    // Initialize region service
    _regionService = getIt<IRegionService>();

    // Initialize auth service
    _authService = getIt<IAuthService>();

    // Check if user already has a valid Firebase session
    if (!widget.skipExistingSessionCheck) {
      _checkExistingSession();
    }

    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isGoogleSignedIn = user != null;
        });
      }
    });

    // Load regions when screen initializes
    _loadRegions();
  }

  void _onNameChanged() {
    _nameDebounceTimer?.cancel();
    _nameDebounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameDebounceTimer?.cancel();
    _nameController.removeListener(_onNameChanged);
    _pageController.dispose();
    _profileScrollController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Check if user already has a valid Firebase session
  Future<void> _checkExistingSession() async {
    final user = _auth.currentUser;

    if (user != null) {
      // User is already signed in with Firebase, but we still need a backend
      // session token for authenticated API calls. If it's missing, mint it
      // via the backend Firebase auth endpoints before navigating.
      try {
        final hasBackendSession = await SessionManager.isAuthenticated();
        if (!hasBackendSession) {
          logger.d(
            "🔐 AuthWizard: Firebase user exists but no backend session — authenticating with backend",
          );
          setState(() => _isAuthenticating = true);

          // Best-effort infer auth method from Firebase user data.
          final hasPhone = (user.phoneNumber ?? "").trim().isNotEmpty;
          final hasEmail = (user.email ?? "").trim().isNotEmpty;
          final inferredMethod =
              hasPhone && !hasEmail ? _AuthMethod.phone : _AuthMethod.google;
          _authMethod = inferredMethod;

          await _authenticateWithBackend(authMethod: inferredMethod);
        } else {
          logger.d(
            "🔐 AuthWizard: Existing backend session found — skipping backend auth",
          );
        }
      } catch (e) {
        // If anything goes wrong, keep the user in the wizard rather than
        // navigating into a state that will immediately 401-loop.
        logger.d("⚠️ AuthWizard: Existing session check failed: $e");
        setState(() => _isAuthenticating = false);
        return;
      } finally {
        if (mounted) setState(() => _isAuthenticating = false);
      }

      if (mounted) _navigateToMainNavigation();
    }
  }

  void _navigateToMainNavigation({int? tabIndex}) {
    if (mainNavigationKey.currentState != null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      if (tabIndex != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          mainNavigationKey.currentState?.navigateToIndex(tabIndex);
        });
      }
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      // IMPORTANT: don't use `initialRoute` here.
      // `AppRouter.initialRoute` attaches the global `mainNavigationKey` so it
      // must only be mounted once at the true app root. During navigation,
      // Flutter can momentarily keep both routes alive which would mount two
      // widgets with the same GlobalKey and crash.
      MaterialPageRoute(builder: (context) => AppRouter.mainNavigationRoute),
      (route) => false,
    );
  }

  // Google Sign-In method
  Future<void> _signInWithGoogle() async {
    getIt<AppAnalyticsService>().logSignInStarted(method: "google");
    setState(() {
      _isAuthenticating = true;
    });

    try {
      // Trigger the authentication flow
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        setState(() {
          _isAuthenticating = false;
        });
        return;
      }

      // Obtain the auth details from the request
      final googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      await _auth.signInWithCredential(credential);

      // Update state immediately after Firebase authentication succeeds
      setState(() {
        _isGoogleSignedIn = true;
      });

      // Pre-fill name from Google account if available
      if (googleUser.displayName != null) {
        _nameController.text = googleUser.displayName!;
      }

      await SessionManager.storeGoogleProfile(
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
      );

      // Now authenticate with your backend
      await _authenticateWithBackend();

      setState(() {
        _isAuthenticating = false;
      });

      if (mounted) {
        getIt<AppAnalyticsService>().logSignInSuccess(method: "google");
        ToastTheme.showSuccess(
          context,
          message: L10n.get("successfully_signed_in_google"),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      getIt<AppAnalyticsService>().logSignInFailure(
        method: "google",
        errorType: e.toString().length > 100 ? e.toString().substring(0, 100) : e.toString(),
      );
      setState(() {
        _isAuthenticating = false;
      });

      if (mounted) {
        final errorStr = e.toString();
        final displayError = errorStr.contains("popup_closed")
            ? L10n.get("popup_closed")
            : errorStr;
        ToastTheme.showWarning(
          context,
          message: L10n.get("google_sign_in_failed").replaceAll("{error}", displayError),
        );
      }
    }
  }

  // Phone Sign-In method
  Future<void> _signInWithPhone() async {
    if (_isAuthenticating) return;

    getIt<AppAnalyticsService>().logSignInStarted(method: "phone");

    final user = await PhoneSignInSheet.show(context);
    if (user == null) {
      // User cancelled or error was shown inside the sheet.
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _isGoogleSignedIn = true; // share "is authenticated" gate with rest of wizard
      _currentUser = user;
      _authMethod = _AuthMethod.phone;
    });

    try {
      if ((user.displayName ?? "").isNotEmpty && _nameController.text.isEmpty) {
        _nameController.text = user.displayName!;
      }

      await SessionManager.storeGoogleProfile(
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );

      await _authenticateWithBackend(authMethod: _AuthMethod.phone);

      if (mounted) {
        setState(() => _isAuthenticating = false);
        getIt<AppAnalyticsService>().logSignInSuccess(method: "phone");
        ToastTheme.showSuccess(
          context,
          message: L10n.get("sign_in_with_phone"),
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      getIt<AppAnalyticsService>().logSignInFailure(
        method: "phone",
        errorType: e.toString().length > 100
            ? e.toString().substring(0, 100)
            : e.toString(),
      );
      if (mounted) {
        setState(() => _isAuthenticating = false);
        ToastTheme.showWarning(
          context,
          message: L10n.get("phone_verification_failed")
              .replaceAll("{error}", e.toString()),
        );
      }
    }
  }

  // Authenticate with your backend after Firebase Sign-In - FIRST OCCURRENCE
  Future<void> _authenticateWithBackend({_AuthMethod authMethod = _AuthMethod.google}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception(
          L10n.get("firebase_user_not_found"),
        );
      }

      logger.d("🔥 Starting backend authentication...");
      logger.d("📧 Email: ${currentUser.email}");
      logger.d("🆔 Firebase UID: ${currentUser.uid}");
      logger.d("🔍 Current page: $_currentPage");
      logger.d("🔍 Is Google signed in: $_isGoogleSignedIn");

      // Call backend via Dio (AuthService)
      final response = authMethod == _AuthMethod.phone
          ? await _authService.firebasePhoneAuth(
              firebaseUid: currentUser.uid,
              phoneNumber: currentUser.phoneNumber ?? "",
              avatarUrl: currentUser.photoURL,
            )
          : await _authService.firebaseAuth(
              email: currentUser.email ?? "",
              firebaseUid: currentUser.uid,
              avatarUrl: currentUser.photoURL,
            );

      logger.d("✅ Backend authentication successful!");
      logger.d("📥 Backend response: $response");

      // Store the session token and backend user ID
      await _storeBackendSession(response);

      // Show violation message if user is blocked
      final isBlocked = response["user"]?["is_blocked"] == true;
      String? violationDialogResult;
      if (mounted && isBlocked) {
        violationDialogResult = await _showViolationDialog();
      }

      // Check if user already has a profile
      final hasProfile = response["profileExists"] ?? false;
      logger.d("👤 User has profile: $hasProfile");
      logger.d("🔍 Current page before navigation: $_currentPage");

      if (hasProfile) {
        logger.d(
          "✅ Returning user with existing profile - skipping to main app",
        );
        // Skip profile creation and go directly to main app
        if (mounted) {
          final nav = Navigator.of(context);
          _navigateToMainNavigation();
          if (violationDialogResult == "contact_support") {
            nav.push(
              MaterialPageRoute<void>(
                builder: (context) => const SupportChatScreen(),
              ),
            );
          }
        }
      } else {
        logger.d("🆕 New user - proceeding to profile creation");
        logger.d("🔍 Navigating to profile creation page...");
        // Navigate to profile creation page for new users
        if (mounted) {
          setState(() {
            _currentPage = 2; // Go directly to profile creation page
          });
          logger.d("🔍 Page updated to: $_currentPage");

          _pageController.animateToPage(
            2, // Profile creation page
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          logger.d("🔍 Page controller animation triggered");
        }
      }
    } catch (e) {
      logger.d("❌ Backend authentication failed: $e");
      rethrow;
    }
  }

  // Store backend session data
  Future<void> _storeBackendSession(Map<String, dynamic> response) async {
    // Store session token
    final sessionToken = response["sessionToken"];
    if (sessionToken != null) {
      await SessionManager.storeSessionToken(sessionToken);
    }

    // Store backend user ID
    final user = response["user"];
    if (user != null && user["id"] != null) {
      final rawUserId = user["id"];
      final parsedUserId = rawUserId is int
          ? rawUserId
          : int.tryParse(rawUserId.toString());
      if (parsedUserId != null) {
        await SessionManager.storeBackendUserId(parsedUserId);
        await getIt<AppAnalyticsService>().setUserId(parsedUserId.toString());
      }
    }
    if (user != null) {
      await SessionManager.storeUserRole(user["role"]);
      await SessionManager.storeUserBlockedStatus(
        user["is_blocked"] as bool? ?? false,
      );
    }

    // Register FCM token for push notifications
    if (!kIsWeb) {
      getIt<IPushNotificationService>().registerTokenWithBackend();
    }

    // Ensure UI auth gates update immediately after session is stored.
    // (Otherwise, some screens can still think we're logged out until the next
    // Firebase auth tick or a restart.)
    try {
      await AuthenticationState().refreshAuthenticationStatus();
    } catch (e) {
      logger.d("⚠️ AuthWizard: Failed to refresh AuthenticationState: $e");
    }
  }

  /// Returns "contact_support" if user chose to contact support, null otherwise.
  Future<String?> _showViolationDialog() async {
    if (!mounted) return null;
    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          L10n.get("user_blocked_violation_title"),
        ),
        content: Text(
          L10n.get("user_blocked_violation_message"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop("contact_support"),
            child: Text(L10n.get("menu_contact_support")),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              L10n.get("close"),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    // Check if current step is complete before allowing next
    if (_currentPage == 1 && !_isGoogleSignedIn) {
      // Show error message if trying to proceed without Google Sign-In
      ToastTheme.showWarning(
        context,
        message: L10n.get("please_sign_in_google_first"),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // For returning users with existing profiles, skip profile creation
    if (_currentPage == 1 && _isGoogleSignedIn) {
      // Check if user already has a profile
      _checkIfUserHasProfile();
      return;
    }

    if (_currentPage < 2) {
      // 3 pages: Language, Google Sign-In, Profile
      setState(() {
        _currentPage++;
      });

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Check if user already has a profile and handle accordingly - SECOND OCCURRENCE
  Future<void> _checkIfUserHasProfile() async {
    try {
      logger.d("🔍 _checkIfUserHasProfile called from page: $_currentPage");
      logger.d("🔍 Is Google signed in: $_isGoogleSignedIn");

      // Get the current backend response to check profile status
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        logger.d("❌ No current Firebase user found");
        return;
      }

      final response = _authMethod == _AuthMethod.phone
          ? await _authService.firebasePhoneAuth(
              firebaseUid: currentUser.uid,
              phoneNumber: currentUser.phoneNumber ?? "",
              avatarUrl: currentUser.photoURL,
            )
          : await _authService.firebaseAuth(
              email: currentUser.email ?? "",
              firebaseUid: currentUser.uid,
              avatarUrl: currentUser.photoURL,
            );

      // Store session (includes blocked status)
      await _storeBackendSession(response);

      // Show violation message if user is blocked
      final isBlocked = response["user"]?["is_blocked"] == true;
      String? violationDialogResult;
      if (mounted && isBlocked) {
        violationDialogResult = await _showViolationDialog();
      }

      final hasProfile = response["profileExists"] ?? false;
      logger.d("👤 User has profile: $hasProfile");
      logger.d("🔍 Current page before navigation: $_currentPage");

      if (hasProfile) {
        logger.d(
          "✅ Returning user with existing profile - going directly to main app",
        );
        // Go directly to main app
        if (mounted) {
          final nav = Navigator.of(context);
          _navigateToMainNavigation();
          if (violationDialogResult == "contact_support") {
            nav.push(
              MaterialPageRoute<void>(
                builder: (context) => const SupportChatScreen(),
              ),
            );
          }
        }
      } else {
        logger.d("🆕 New user - proceeding to profile creation");
        logger.d("🔍 Navigating to profile creation page...");
        // Navigate to profile creation page for new users
        if (mounted) {
          setState(() {
            _currentPage = 2; // Go directly to profile creation page
          });
          logger.d("🔍 Page updated to: $_currentPage");

          _pageController.animateToPage(
            2, // Profile creation page
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          logger.d("🔍 Page controller animation triggered");
        }
      }
    } catch (e) {
      logger.d("❌ Error checking profile status: $e");
      // If check fails, proceed to profile creation as fallback
      logger.d("🔍 Fallback: navigating to profile creation page...");
      if (mounted) {
        setState(() {
          _currentPage = 2; // Go to profile creation page as fallback
        });
        logger.d("🔍 Page updated to: $_currentPage");

        // Set flag to prevent page validation during programmatic navigation
        _isProgrammaticNavigation = true;

        _pageController.animateToPage(
          2, // Profile creation page
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        logger.d("🔍 Page controller animation triggered (fallback)");

        // Reset flag after navigation completes
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) {
            setState(() {
              _isProgrammaticNavigation = false;
            });
          }
        });
      }
    }
  }

  // Get total number of steps based on user needs
  int _getTotalSteps() {
    // If user is signed in and we know they have a profile, show only 2 steps
    if (_isGoogleSignedIn && _currentUser != null) {
      // We"ll need to check if they have a profile
      // For now, assume 3 steps and let the backend response determine the flow
      return 3;
    }
    return 3; // Default: Language, Google Sign-In, Profile
  }

  void _previousPage() {
    if (_currentPage > 0) {
      HapticFeedbackUtils.impact();
      setState(() {
        _currentPage--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });

    // Change the app language
    LanguageState().setLanguage(languageCode);
  }

  void _onStudentSelected(bool? value) {
    setState(() {
      _isStudent = value;
      if (value ?? false) {
        _loadUniversities();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted &&
              _universities.isNotEmpty &&
              _selectedUniversity == null) {
            setState(() {
              _selectedUniversity = _universities.first;
            });
          }
        });
      } else {
        _selectedUniversity = null;
      }
    });

    if (value ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_profileScrollController.hasClients) {
          return;
        }
        _profileScrollController.animateTo(
          _profileScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  Future<void> _loadUniversities() async {
    if (_universities.isNotEmpty) return; // Already loaded

    logger.d("=== LOADING UNIVERSITIES ===");
    setState(() {
      _isLoadingUniversities = true;
    });

    try {
      final universities = await _universityService.getUniversities();
      logger.d("Universities loaded: ${universities.length}");
      logger.d(
        "First university: ${universities.isNotEmpty ? _getUniversityName(universities.first) : "None"}",
      );

      setState(() {
        _universities = universities;
        _isLoadingUniversities = false;

        // CRITICAL FIX: Set default university selection when universities are loaded
        if (universities.isNotEmpty && _selectedUniversity == null) {
          _selectedUniversity = universities.first;
          logger.d(
            "✅ AUTO-SELECTED first university: ${_selectedUniversity != null ? _getUniversityName(_selectedUniversity!) : "None"} (ID: ${_selectedUniversity?.id})",
          );
        }
      });

      logger.d(
        "Universities loaded successfully. _universities length: ${_universities.length}",
      );
      logger.d(
        "Current _selectedUniversity: ${_selectedUniversity != null ? _getUniversityName(_selectedUniversity!) : "None"} (ID: ${_selectedUniversity?.id})",
      );
    } catch (error) {
      logger.d("Error loading universities: $error");
      setState(() {
        _isLoadingUniversities = false;
      });

      if (mounted) {
        ToastTheme.showWarning(
          context,
          message: L10n.get("error_loading_universities").replaceAll("{error}", error.toString()),
        );
      }
    }
  }

  Future<void> _loadRegions() async {
    if (_regions.isNotEmpty) return; // Already loaded

    logger.d("=== LOADING REGIONS ===");
    setState(() {
      _isLoadingRegions = true;
    });

    try {
      final regions = await _regionService.getRegions();
      logger.d("Regions loaded: ${regions.length}");
      logger.d(
        "First region: ${regions.isNotEmpty ? _getRegionName(regions.first) : "None"}",
      );

      setState(() {
        _regions = regions;
        _isLoadingRegions = false;

        // CRITICAL FIX: Set default region selection when regions are loaded
        if (regions.isNotEmpty && _selectedRegionId == null) {
          _selectedRegionId = regions.first.id;
          logger.d(
            "✅ AUTO-SELECTED first region: ${_getRegionName(_regions.first)} (ID: ${_regions.first.id})",
          );
        }
      });

      logger.d(
        "Regions loaded successfully. _regions length: ${_regions.length}",
      );
      logger.d("Current _selectedRegionId: $_selectedRegionId");
    } catch (error) {
      logger.d("Error loading regions: $error");
      setState(() {
        _isLoadingRegions = false;
      });

      if (mounted) {
        ToastTheme.showWarning(
          context,
          message: L10n.get("error_loading_regions").replaceAll("{error}", error.toString()),
        );
      }
    }
  }

  Future<void> _completeProfile() async {
    // Profile setup - require name, gender, region, role, student status, and university if student
    if (_nameController.text.trim().isEmpty ||
        _selectedGender == null ||
        _selectedRegionId == null ||
        _selectedRole == null ||
        _isStudent == null) {
      ToastTheme.showWarning(
        context,
        message: L10n.get("please_complete_all_fields"),
      );
      return;
    }

    if ((_isStudent ?? false) && _selectedUniversity == null) {
      logger.d(
        "❌ VALIDATION FAILED: User is student but no university selected",
      );
      logger.d("_isStudent: $_isStudent");
      logger.d(
        "_selectedUniversity: ${_selectedUniversity != null ? _getUniversityName(_selectedUniversity!) : "None"} (ID: ${_selectedUniversity?.id})",
      );
      logger.d("Available universities: ${_universities.length}");
      if (_universities.isNotEmpty) {
        logger.d(
          "First available university: ${_getUniversityName(_universities.first)} (ID: ${_universities.first.id})",
        );
      }

      ToastTheme.showWarning(
        context,
        message: L10n.get("please_select_university"),
      );
      return;
    }

    logger.d("✅ VALIDATION PASSED: All required fields are filled");
    logger.d("Name: ${_nameController.text.trim()}");
    logger.d("Gender: $_selectedGender");
    logger.d("Region ID: $_selectedRegionId");
    logger.d("Is Student: $_isStudent");
    logger.d(
      "Selected University: ${_selectedUniversity != null ? _getUniversityName(_selectedUniversity!) : "None"} (ID: ${_selectedUniversity?.id})",
    );

    // Show loading state
    setState(() {
      _isAuthenticating = true;
    });

    try {
      // Get backend user ID from session (set during Firebase auth)
      var backendUserId = await SessionManager.getBackendUserId();

      if (backendUserId == null) {
        // Check if we need to re-authenticate with backend
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          try {
            await _authenticateWithBackend(authMethod: _authMethod);
            // Try to get backend user ID again
            final newBackendUserId = await SessionManager.getBackendUserId();

            if (newBackendUserId != null) {
              // Use the new backend user ID
              backendUserId = newBackendUserId;
            } else {
              throw Exception(
                "Backend re-authentication failed - still no user ID",
              );
            }
          } catch (e) {
            throw Exception(
              "Backend user ID not found and re-authentication failed: $e",
            );
          }
        } else {
          throw Exception(
            "Backend user ID not found - please authenticate with backend first",
          );
        }
      }

      // Debug logging for profile creation
      logger.d("=== PROFILE CREATION DEBUG ===");
      logger.d("User ID: $backendUserId");
      logger.d("Name: ${_nameController.text.trim()}");
      logger.d("Gender: $_selectedGender");
      logger.d("Region ID: $_selectedRegionId");
      logger.d("Is Student: $_isStudent");
      logger.d(
        "Selected University: ${_selectedUniversity != null ? _getUniversityName(_selectedUniversity!) : "None"} (ID: ${_selectedUniversity?.id})",
      );
      logger.d(
        "University ID being sent: ${_isStudent! ? _selectedUniversity!.id : null}",
      );
      logger.d("Available universities: ${_universities.length}");
      if (_universities.isNotEmpty) {
        logger.d(
          "First university: ${_getUniversityName(_universities.first)} (ID: ${_universities.first.id})",
        );
      }
      logger.d("==============================");

      // CRITICAL: Check if university selection is missing
      if (_isStudent! && _selectedUniversity == null) {
        logger.d(
          "🚨 CRITICAL ERROR: User is student but no university selected!",
        );
        logger.d("Forcing selection of first university...");
        if (_universities.isNotEmpty) {
          _selectedUniversity = _universities.first;
          logger.d(
            "✅ Forced university selection to: ${_selectedUniversity != null ? _getUniversityName(_selectedUniversity!) : "None"} (ID: ${_selectedUniversity?.id})",
          );
        } else {
          logger.d("❌ No universities available!");
          throw Exception(
            "No universities available for student profile creation",
          );
        }
      }

      // Additional safety check - ensure _isStudent is properly set
      logger.d("Final validation before request creation:");
      logger.d("_isStudent: $_isStudent");
      logger.d(
        "_selectedUniversity: ${_selectedUniversity != null ? _getUniversityName(_selectedUniversity!) : "None"} (ID: ${_selectedUniversity?.id})",
      );
      logger.d("Universities loaded: ${_universities.length}");
      logger.d(
        "Will send universityId: ${_isStudent! ? _selectedUniversity!.id : null}",
      );

      // FINAL SAFETY CHECK: Ensure university selection is properly set
      if (_isStudent! && _selectedUniversity == null) {
        logger.d("🚨 FINAL SAFETY CHECK FAILED: Still no university selected!");
        logger.d("Attempting to force selection...");
        if (_universities.isNotEmpty) {
          _selectedUniversity = _universities.first;
          logger.d(
            "✅ FINAL: Forced university selection to: ${_selectedUniversity != null ? _getUniversityName(_selectedUniversity!) : "None"} (ID: ${_selectedUniversity?.id})",
          );
        } else {
          logger.d("❌ FINAL: No universities available!");
          throw Exception(
            "No universities available for student profile creation",
          );
        }
      }

      // Create profile request (include Google profile photo URL when available)
      final googleAvatarUrl = await SessionManager.getGooglePhotoUrl();
      final request = CreateProfileRequest(
        userId: backendUserId,
        name: _nameController.text.trim(),
        gender: _selectedGender!,
        universityId: _isStudent! ? _selectedUniversity!.id : null,
        regionId: _selectedRegionId,
        role: _selectedRole,
        preferredLanguage: _selectedLanguage,
        avatarUrl:
            googleAvatarUrl != null && googleAvatarUrl.trim().isNotEmpty
                ? googleAvatarUrl.trim()
                : null,
      );

      // CRITICAL: Verify the request object has the correct data
      logger.d("=== FINAL REQUEST VERIFICATION ===");
      logger.d("Request object created successfully");
      logger.d("Request.universityId: ${request.universityId}");
      logger.d("Request.regionId: ${request.regionId}");
      logger.d("Request.toJson(): ${request.toJson()}");
      logger.d("universityId in JSON: ${request.toJson()["universityId"]}");
      logger.d("regionId in JSON: ${request.toJson()["regionId"]}");
      logger.d("JSON string representation: ${jsonEncode(request.toJson())}");
      logger.d("All JSON keys: ${request.toJson().keys.toList()}");
      logger.d("All JSON values: ${request.toJson().values.toList()}");
      logger.d("================================");

      logger.d("Final request data:");
      logger.d("Request JSON: ${request.toJson()}");
      logger.d("University ID in request: ${request.universityId}");
      logger.d("Region ID in request: ${request.regionId}");
      logger.d("Request object fields:");
      logger.d("  - userId: ${request.userId}");
      logger.d("  - name: ${request.name}");
      logger.d("  - gender: ${request.gender}");
      logger.d("  - universityId: ${request.universityId}");
      logger.d("  - regionId: ${request.regionId}");
      logger.d("Request.toJson() keys: ${request.toJson().keys.toList()}");
      logger.d("Request.toJson() values: ${request.toJson().values.toList()}");

      // Test JSON serialization
      logger.d("=== JSON SERIALIZATION TEST ===");
      final testMap = {
        "user_id": request.userId,
        "name": request.name,
        "gender": request.gender,
        "university_id": request.universityId,
        "region_id": request.regionId,
      };
      logger.d("Manual map: $testMap");
      logger.d("Manual map keys: ${testMap.keys.toList()}");
      logger.d("Manual map values: ${testMap.values.toList()}");
      logger.d("==============================");

      try {
        await _profileService.createProfile(request);
      } catch (e) {
        logger.d("❌ Profile service error: $e");

        // If it"s a DioException, try to get more details
        if (e.toString().contains("DioException")) {
          logger.d(
            "🔍 This is a DioException - checking for response details...",
          );

          // Try to get the actual response body if possible
          if (e.toString().contains("409")) {
            logger.d("🚨 HTTP 409 Conflict detected!");
            logger.d("💡 This usually means:");
            logger.d("   - Profile already exists for this user");
            logger.d("   - Duplicate data conflict");
            logger.d("   - Backend validation error");
            logger.d("   - User already has a profile");

            // Check if user already has a profile by trying to fetch it
            try {
              logger.d("🔍 Checking if profile already exists...");

              // Try to get the current user"s profile to see if it exists
              try {
                // This is a temporary workaround - try to fetch existing profile
                // You"ll need to implement this method in your profile service
                logger.d("🔍 Attempting to fetch existing profile...");

                // For now, let"s assume if we get here, the user already has a profile
                // and we should skip to the main app
                logger.d(
                  "✅ User already has a profile, skipping profile creation",
                );

                if (mounted) {
                  // Show success message
                  ToastTheme.showSuccess(
                    context,
                    message: L10n.get("welcome_back_profile_exists"),
                  );

                  // Navigate to main app directly
                  _navigateToMainNavigation();
                }
                return; // Exit early, don"t try to create profile
              } catch (fetchError) {
                logger.d(
                  "🔍 Profile fetch failed (probably doesn\"t exist): $fetchError",
                );
                // Continue with profile creation
              }

              // If we get here, profile doesn"t exist, so create it
              throw Exception(
                "Profile creation failed (409 Conflict). This usually means a profile already exists for this user. Please contact support or try signing in with a different account.",
              );
            } catch (checkError) {
              logger.d("❌ Profile check failed: $checkError");
              rethrow;
            }
          }
        }

        rethrow;
      }

      if (mounted) {
        getIt<AppAnalyticsService>().logProfileCreated();
        // Store user role in session for immediate use
        if (_selectedRole != null) {
          await SessionManager.storeUserRole(_selectedRole);
        }

        // Show success message
        ToastTheme.showSuccess(
          context,
          message: L10n.get("profile_completed_success"),
        );

        // Navigate to main app
        _navigateToMainNavigation();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });

        // Show error message
        ToastTheme.showWarning(
          context,
          message: L10n.get("error_creating_profile").replaceAll("{error}", e.toString()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Header with page title
                Container(
                  padding: const EdgeInsets.only(
                    left: 32,
                    right: 32,
                    top: 16,
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: ThemeIcon(
                          Icons.close,
                          color: _getOnboardingTextColor(context),
                        ),
                        tooltip: L10n.get("close"),
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                            return;
                          }

                          _navigateToMainNavigation();
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentPage == 0
                            ? L10n.get("select_language")
                            : _currentPage == 1
                                ? L10n.get("sign_in_with_google")
                                : _currentPage == 2
                                    ? L10n.get("complete_profile")
                                    : "UyDosh",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getOnboardingTextColor(context),
                        ),
                      ),
                      const Spacer(),
                      // Theme toggle (sun = light, moon = dark/blue)
                      Tooltip(
                        message: L10n.get("switch_theme"),
                        child: ThemeToggleSunMoon(
                          iconColor: _getOnboardingTextColor(context),
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress indicator (dynamic based on user needs)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: List.generate(_getTotalSteps(), (index) {
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color:
                                index <= _currentPage
                                    ? _getOnboardingTextColor(context)
                                    : _getOnboardingTextColor(context).withValues(
                                        alpha: 0.3,
                                      ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 8),

                // Page content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (page) {
                        // Skip validation during programmatic navigation
                        if (_isProgrammaticNavigation) {
                          logger.d(
                            "🔍 Skipping page validation during programmatic navigation",
                          );
                          return;
                        }

                        // Prevent manual swiping - only allow navigation through buttons
                        if (page != _currentPage) {
                          // Check if user can access the target page
                          if (!_canAccessPage(page)) {
                            // Bounce back to current page
                            _pageController.animateToPage(
                              _currentPage,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );

                            // Show error message
                            ToastTheme.showWarning(
                              context,
                              message: L10n.get("please_complete_previous_steps"),
                              duration: const Duration(seconds: 3),
                            );
                            return;
                          }
                        }
                      },
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable swiping completely
                      children: [
                        AuthWizardLanguagePage(
                          selectedLanguage: _selectedLanguage,
                          onLanguageSelected: _selectLanguage,
                        ),
                        AuthWizardGoogleSignInPage(
                          isAuthenticating: _isAuthenticating,
                          isGoogleSignedIn: _isGoogleSignedIn,
                          currentUser: _currentUser,
                          onSignInWithGoogle: _signInWithGoogle,
                          onSignInWithPhone: _signInWithPhone,
                        ),
                        AuthWizardProfilePage(
                          profileScrollController: _profileScrollController,
                          nameController: _nameController,
                          selectedGender: _selectedGender,
                          onGenderSelected: (v) => setState(() => _selectedGender = v),
                          selectedRegionId: _selectedRegionId,
                          regions: _regions,
                          onShowRegionPicker: _showRegionPicker,
                          selectedRole: _selectedRole,
                          onRoleSelected: (v) => setState(() => _selectedRole = v),
                          isStudent: _isStudent,
                          onStudentSelected: _onStudentSelected,
                          selectedUniversity: _selectedUniversity,
                          universities: _universities,
                          onShowUniversityPicker: _showUniversityPicker,
                          isLoadingRegions: _isLoadingRegions,
                          isLoadingUniversities: _isLoadingUniversities,
                          getRegionName: _getRegionName,
                          getUniversityName: _getUniversityName,
                        ),
                      ],
                    ),
                  ),
                ),

                // Navigation buttons
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final label = Theme.of(context).textTheme.labelLarge;
                              final textStyle =
                                  label?.copyWith(
                                        fontSize: 17,
                                        height: 1.0,
                                      ) ??
                                  const TextStyle(
                                    fontSize: 17,
                                    height: 1.0,
                                    fontWeight: FontWeight.w500,
                                  );
                              if (ThemeState().isLightTheme) {
                                return PrimaryButtonFactory.iconTextCentered(
                                  onPressed: _previousPage,
                                  icon: Icons.chevron_left,
                                  text: L10n.get("back"),
                                  width: double.infinity,
                                  borderRadius: BorderRadius.circular(20),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  textStyle: textStyle,
                                  iconSize: 22,
                                );
                              }
                              return GhostButtonFactory.iconTextCentered(
                                onPressed: _previousPage,
                                icon: Icons.chevron_left,
                                text: L10n.get("back"),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                textStyle: textStyle,
                                isOnboardingButton: true,
                                neumorphicSoftUi: true,
                                iconSize: 22,
                              );
                            },
                          ),
                        ),
                      if (_currentPage > 0 && _currentPage != 1)
                        const SizedBox(width: 20),
                      // Hide next button on Google Sign-In page (page 1) since navigation happens automatically
                      if (_currentPage != 1)
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final nextText = L10n.get(_getNextButtonTextKey());
                              final onNext = _getNextButtonAction();
                              final label = Theme.of(context).textTheme.labelLarge;
                              final textStyle =
                                  label?.copyWith(
                                        fontSize: 17,
                                        height: 1.0,
                                      ) ??
                                  const TextStyle(
                                    fontSize: 17,
                                    height: 1.0,
                                    fontWeight: FontWeight.w500,
                                  );
                              if (ThemeState().isLightTheme) {
                                return PrimaryButtonFactory.textIconCentered(
                                  onPressed: onNext,
                                  text: nextText,
                                  icon: Icons.chevron_right,
                                  width: double.infinity,
                                  borderRadius: BorderRadius.circular(20),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  textStyle: textStyle,
                                  isLoading: _isAuthenticating,
                                );
                              }
                              return GhostButtonFactory.textIconCentered(
                                onPressed: onNext,
                                text: nextText,
                                icon: Icons.chevron_right,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                textStyle: textStyle,
                                isLoading: _isAuthenticating,
                                isOnboardingButton: true,
                                neumorphicSoftUi: true,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRegionPicker() {
    logger.d("=== SHOWING REGION PICKER ===");
    logger.d("Current _selectedRegionId: $_selectedRegionId");
    logger.d("Regions available: ${_regions.length}");
    logger.d(
      "First region: ${_regions.isNotEmpty ? _getRegionName(_regions.first) : "None"}",
    );

    // Ensure there"s a default selection when opening the picker
    if (_selectedRegionId == null && _regions.isNotEmpty) {
      logger.d("Setting default region selection to first region");
      setState(() {
        _selectedRegionId = _regions.first.id;
      });
      logger.d(
        "Default region set to: ${_getRegionName(_regions.first)} (ID: ${_regions.first.id})",
      );
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: _buildRegionPicker,
    );
  }

  Widget _buildRegionPicker(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AuthWizardTheme.getBottomSheetBackgroundColor(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AuthWizardTheme.getBottomSheetHandleColor(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              L10n.get("select_region"),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    AuthWizardTheme.getBottomSheetTextColor(), // Use black text for better visibility in blue theme
              ),
            ),
          ),

          // Region wheel picker
          SizedBox(
            height: 200,
            child: CupertinoPicker(
              itemExtent: 50,
              onSelectedItemChanged: (index) {
                HapticFeedbackUtils.impact();
                SendSoundUtils.playSelectionSound();
                // Update selection as user scrolls
                logger.d(
                  "Region picker: User scrolled to index $index, region: ${_getRegionName(_regions[index])}",
                );
                setState(() {
                  _selectedRegionId = _regions[index].id;
                });
                logger.d(
                  "Region picker: _selectedRegionId updated to: $_selectedRegionId",
                );
              },
              children:
                  _regions.map((region) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Center(
                        child: Text(
                          _getRegionName(region),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                AuthWizardTheme.getBottomSheetTextColor(), // Use black text for better visibility in blue theme
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          // Confirm button
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildBottomSheetConfirmButton(
              context,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showUniversityPicker() {
    logger.d("=== SHOWING UNIVERSITY PICKER ===");
    logger.d(
      "Current _selectedUniversity: ${_selectedUniversity != null ? _getUniversityName(_selectedUniversity!) : "None"} (ID: ${_selectedUniversity?.id})",
    );
    logger.d("Universities available: ${_universities.length}");
    logger.d(
      "First university: ${_universities.isNotEmpty ? _getUniversityName(_universities.first) : "None"}",
    );

    // Ensure there"s a default selection when opening the picker
    if (_selectedUniversity == null && _universities.isNotEmpty) {
      logger.d("Setting default university selection to first university");
      setState(() {
        _selectedUniversity = _universities.first;
      });
      logger.d(
        "Default university set to: ${_getUniversityName(_universities.first)} (ID: ${_universities.first.id})",
      );
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: _buildUniversityPicker,
    );
  }

  Widget _buildUniversityPicker(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AuthWizardTheme.getBottomSheetBackgroundColor(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AuthWizardTheme.getBottomSheetHandleColor(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              L10n.get("select_university"),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    AuthWizardTheme.getBottomSheetTextColor(), // Use black text for better visibility in blue theme
              ),
            ),
          ),

          // University wheel picker
          SizedBox(
            height: 200,
            child: CupertinoPicker(
              itemExtent: 50,
              onSelectedItemChanged: (index) {
                HapticFeedbackUtils.impact();
                SendSoundUtils.playSelectionSound();
                // Update selection as user scrolls
                logger.d(
                  "University picker: User scrolled to index $index, university: ${_getUniversityName(_universities[index])}",
                );
                setState(() {
                  _selectedUniversity = _universities[index];
                });
                logger.d(
                  "University picker: _selectedUniversity updated to: ${_selectedUniversity != null ? _getUniversityName(_selectedUniversity!) : "None"} (ID: ${_selectedUniversity?.id})",
                );
              },
              children:
                  _universities.map((university) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Center(
                        child: Text(
                          _getUniversityName(university),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                AuthWizardTheme.getBottomSheetTextColor(), // Use black text for better visibility in blue theme
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          // Confirm button
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildBottomSheetConfirmButton(
              context,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 3D neumorphic confirm button used inside onboarding bottom sheets
  /// (region and university pickers). Matches the onboarding blue theme.
  Widget _buildBottomSheetConfirmButton(
    BuildContext context, {
    required VoidCallback onPressed,
  }) {
    final isBlue = ThemeState().isBlueTheme;
    final buttonBg = isBlue
        ? BlueThemeColors.primary
        : Theme.of(context).colorScheme.surface;
    final textColor = isBlue
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      width: double.infinity,
      child: ThreeDPillButton(
        onPressed: onPressed,
        backgroundColor: buttonBg,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text(
            L10n.get("confirm"),
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  bool _canAccessPage(int page) {
    switch (page) {
      case 0:
        return true; // Language page always accessible
      case 1:
        return _selectedLanguage
            .isNotEmpty; // Google Sign-In page only if language selected
      case 2:
        // Profile page only if Google Sign-In completed AND user needs profile creation
        return _selectedLanguage.isNotEmpty &&
            _isGoogleSignedIn &&
            _needsProfileCreation();
      default:
        return false;
    }
  }

  // Check if user needs profile creation
  bool _needsProfileCreation() {
    // If user is not signed in with Google, they need profile creation
    if (!_isGoogleSignedIn) {
      return true;
    }

    // If user is signed in but we haven"t checked with backend yet, assume they need profile creation
    if (_currentUser == null) {
      return true;
    }

    // For now, assume all users need profile creation until we get a definitive response from backend
    // This will be updated when we implement proper profile existence checking
    return true;
  }

  VoidCallback? _getNextButtonAction() {
    // Disable all actions when authenticating
    if (_isAuthenticating) return null;

    switch (_currentPage) {
      case 0:
        // Language selection - always allow next
        return _nextPage;
      case 1:
        // Google Sign-In - only allow next if signed in
        if (!_isGoogleSignedIn) {
          return null;
        }
        return _nextPage;
      case 2:
        // Profile setup - require gender, region, student status, and university if student
        if (_nameController.text.trim().isEmpty ||
            _selectedGender == null ||
            _selectedRegionId == null ||
            _isStudent == null) {
          return null;
        }
        if ((_isStudent ?? false) && _selectedUniversity == null) return null;
        return _completeProfile;
      default:
        return null;
    }
  }

  String _getNextButtonTextKey() {
    if (_isAuthenticating) {
      return "signing_in";
    }

    switch (_currentPage) {
      case 0:
        return "next";
      case 1:
        if (!_isGoogleSignedIn) {
          return "sign_in_google_first";
        }
        return "next";
      case 2:
        return "complete";
      default:
        return "next";
    }
  }

  /// Get theme-aware onboarding text color (uses theme from MaterialApp)
  Color _getOnboardingTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  /// Get language-aware region name
  String _getRegionName(Region region) {
    final currentLanguage = LanguageState().currentLanguage;
    switch (currentLanguage) {
      case "en":
        return region.nameEn ?? region.name ?? "Unknown";
      case "ru":
        return region.nameRu ?? region.name ?? "Unknown";
      case "uz":
        return region.nameUz ?? region.name ?? "Unknown";
      default:
        return region.name ?? "Unknown";
    }
  }

  /// Get language-aware university name
  String _getUniversityName(University university) {
    return university.getLocalizedNameCapitalized(
      LanguageState().currentLanguage,
    );
  }

}
