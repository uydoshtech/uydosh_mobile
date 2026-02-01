import "package:uy_dosh/base/logger/logger.dart";
import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/services.dart";
import "dart:async";
import "package:flutter_svg/flutter_svg.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";

import "package:uy_dosh/presentation/router/app_router.dart";
import "package:uy_dosh/domain/models/university.dart";
import "package:uy_dosh/domain/services/university_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/domain/models/auth/create_profile_request.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";

// Firebase and Google Sign-In imports
import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";

// HTTP imports for backend API calls
import "dart:convert";
import "package:http/http.dart" as http;
import "package:flutter/foundation.dart" show kIsWeb;
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/region.dart";
import "package:uy_dosh/domain/services/region_service.dart";

class AuthWizardScreen extends StatefulWidget {
  const AuthWizardScreen({super.key});

  @override
  State<AuthWizardScreen> createState() => _AuthWizardScreenState();
}

class _AuthWizardScreenState extends State<AuthWizardScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  final ScrollController _profileScrollController = ScrollController();
  int _currentPage = 0; // Start with language selection page

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  int? _selectedGender;
  bool? _isStudent = false; // Initialize to false instead of null
  String _selectedLanguage = "uz"; // Default to Uzbek

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

  // Navigation control
  bool _isProgrammaticNavigation = false;

  @override
  void initState() {
    super.initState();

    // Initialize university service
    _universityService = getIt<IUniversityService>();

    // Initialize profile service
    _profileService = getIt<IUserProfileService>();

    // Initialize region service
    _regionService = getIt<IRegionService>();

    // Set the default language to Uzbek when the screen initializes
    LanguageState().setLanguage("uz");

    // Check if user already has a valid Firebase session
    _checkExistingSession();

    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen((User? user) {
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

  @override
  void dispose() {
    _pageController.dispose();
    _profileScrollController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Check if user already has a valid Firebase session
  Future<void> _checkExistingSession() async {
    final user = _auth.currentUser;

    if (user != null) {
      // User is already signed in with Firebase, skip to main app
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AppRouter.initialRoute),
        );
      }
    }
  }

  // Google Sign-In method
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isAuthenticating = true;
    });

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        setState(() {
          _isAuthenticating = false;
        });
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
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

      // Now authenticate with your backend
      await _authenticateWithBackend();

      setState(() {
        _isAuthenticating = false;
      });

      if (mounted) {
        ToastTheme.showSuccess(
          context,
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "successfully_signed_in_google",
          ),
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
      });

      if (mounted) {
        ToastTheme.showWarning(
          context,
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "google_sign_in_failed",
          ).replaceAll("{error}", e.toString()),
        );
      }
    }
  }

  // Authenticate with your backend after Firebase Sign-In - FIRST OCCURRENCE
  Future<void> _authenticateWithBackend() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception(
          LanguageAwareStringHelper.getCurrent(
            context,
            "firebase_user_not_found",
          ),
        );
      }

      logger.d("🔥 Starting backend authentication...");
      logger.d("📧 Email: ${currentUser.email}");
      logger.d("🆔 Firebase UID: ${currentUser.uid}");
      logger.d("🔍 Current page: $_currentPage");
      logger.d("🔍 Is Google signed in: $_isGoogleSignedIn");

      // Call your backend endpoint
      final response = await _callBackendAuthEndpoint(
        email: currentUser.email ?? "",
        firebaseUid: currentUser.uid,
      );

      logger.d("✅ Backend authentication successful!");
      logger.d("📥 Backend response: $response");

      // Store the session token and backend user ID
      await _storeBackendSession(response);

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
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AppRouter.initialRoute),
          );
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

  // Call your backend Firebase auth endpoint
  Future<Map<String, dynamic>> _callBackendAuthEndpoint({
    required String email,
    required String firebaseUid,
  }) async {
    final url = "${EnvironmentUtil.basePath}/users/firebase-auth";
    final body = {"email": email, "firebase_uid": firebaseUid};

    logger.d("🌐 Calling backend: $url");
    logger.d("📤 Request body: $body");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      logger.d("📥 Response status: ${response.statusCode}");
      logger.d("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          "Backend authentication failed: ${response.statusCode}",
        );
      }
    } catch (e) {
      logger.d("❌ HTTP request failed: $e");
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
      final userId = user["id"];
      await SessionManager.storeBackendUserId(userId);
    }
  }

  void _nextPage() {
    // Check if current step is complete before allowing next
    if (_currentPage == 1 && !_isGoogleSignedIn) {
      // Show error message if trying to proceed without Google Sign-In
      ToastTheme.showWarning(
        context,
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "please_sign_in_google_first",
        ),
        duration: Duration(seconds: 3),
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

      final response = await _callBackendAuthEndpoint(
        email: currentUser.email ?? "",
        firebaseUid: currentUser.uid,
      );

      final hasProfile = response["profileExists"] ?? false;
      logger.d("👤 User has profile: $hasProfile");
      logger.d("🔍 Current page before navigation: $_currentPage");

      if (hasProfile) {
        logger.d(
          "✅ Returning user with existing profile - going directly to main app",
        );
        // Go directly to main app
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AppRouter.initialRoute),
          );
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
      HapticFeedback.lightImpact();
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

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case "en":
        return "English";
      case "ru":
        return "Русский";
      case "uz":
        return "O'zbekcha";
      default:
        return "English";
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
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "error_loading_universities",
          ).replaceAll("{error}", error.toString()),
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
      logger.d("Current _selectedRegionId: ${_selectedRegionId}");
    } catch (error) {
      logger.d("Error loading regions: $error");
      setState(() {
        _isLoadingRegions = false;
      });

      if (mounted) {
        ToastTheme.showWarning(
          context,
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "error_loading_regions",
          ).replaceAll("{error}", error.toString()),
        );
      }
    }
  }

  Future<void> _completeProfile() async {
    // Profile setup - require name, gender, region, student status, and university if student
    if (_nameController.text.trim().isEmpty ||
        _selectedGender == null ||
        _selectedRegionId == null ||
        _isStudent == null) {
      ToastTheme.showWarning(
        context,
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "please_complete_all_fields",
        ),
      );
      return;
    }

    if (_isStudent == true && _selectedUniversity == null) {
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
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "please_select_university",
        ),
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
            await _authenticateWithBackend();
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

      if (backendUserId == null) {
        // Check if we need to re-authenticate with backend
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          try {
            await _authenticateWithBackend();
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

      // Create profile request
      final request = CreateProfileRequest(
        userId: backendUserId,
        name: _nameController.text.trim(),
        gender: _selectedGender!,
        universityId: _isStudent! ? _selectedUniversity!.id : null,
        regionId: _selectedRegionId,
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
                    message: LanguageAwareStringHelper.getCurrent(
                      context,
                      "welcome_back_profile_exists",
                    ),
                  );

                  // Navigate to main app directly
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => AppRouter.initialRoute,
                    ),
                  );
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
        // Show success message
        ToastTheme.showSuccess(
          context,
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "profile_completed_success",
          ),
        );

        // Navigate to main app
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AppRouter.initialRoute),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });

        // Show error message
        ToastTheme.showWarning(
          context,
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "error_creating_profile",
          ).replaceAll("{error}", e.toString()),
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
          backgroundColor: _getOnboardingBackgroundColor(),
          body: SafeArea(
            child: Column(
              children: [
                // Header with logo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: _getOnboardingTextColor(),
                        ),
                        tooltip: LanguageAwareStringHelper.getCurrent(
                          context,
                          "close",
                        ),
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                            return;
                          }

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => AppRouter.initialRoute,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "UyDosh",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getOnboardingTextColor(),
                        ),
                      ),
                      const Spacer(),
                      // Theme switcher dropdown
                      PopupMenuButton<String>(
                        onSelected: (String themeName) async {
                          await ThemeState().changeTheme(themeName);
                          setState(() {}); // Force rebuild
                        },
                        itemBuilder:
                            (BuildContext context) => [
                              PopupMenuItem<String>(
                                value: AppTheme.lightTheme,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.light_mode,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      LanguageAwareStringHelper.getCurrent(
                                        context,
                                        "light_theme",
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: AppTheme.blueTheme,
                                child: Row(
                                  children: [
                                    Icon(Icons.water_drop, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      LanguageAwareStringHelper.getCurrent(
                                        context,
                                        "blue_theme",
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: AppTheme.purpleTheme,
                                child: Row(
                                  children: [
                                    Icon(Icons.palette, color: Colors.purple),
                                    const SizedBox(width: 8),
                                    Text(
                                      LanguageAwareStringHelper.getCurrent(
                                        context,
                                        "purple_theme",
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                        child: Icon(
                          Icons.palette,
                          color: _getOnboardingTextColor(),
                        ),
                        tooltip: LanguageAwareStringHelper.getCurrent(
                          context,
                          "switch_theme",
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
                                    ? _getOnboardingTextColor()
                                    : _getOnboardingTextColor().withOpacity(
                                      0.3,
                                    ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 32),

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
                              message: LanguageAwareStringHelper.getCurrent(
                                context,
                                "please_complete_previous_steps",
                              ),
                              duration: Duration(seconds: 3),
                            );
                            return;
                          }
                        }
                      },
                      physics:
                          NeverScrollableScrollPhysics(), // Disable swiping completely
                      children: [
                        _buildLanguageSelectionPage(),
                        _buildGoogleSignInPage(),
                        _buildProfileSetupPage(),
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
                          child: GhostButtonFactory.text(
                            onPressed: _previousPage,
                            text: LanguageAwareStringHelper.getCurrent(
                              context,
                              "back",
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            isOnboardingButton: true,
                          ),
                        ),
                      if (_currentPage > 0 && _currentPage != 1)
                        const SizedBox(width: 20),
                      // Hide next button on Google Sign-In page (page 1) since navigation happens automatically
                      if (_currentPage != 1)
                        Expanded(
                          child: GhostButtonFactory.text(
                            onPressed: _getNextButtonAction(),
                            text: LanguageAwareStringHelper.getCurrent(
                              context,
                              _getNextButtonTextKey(),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            isLoading: _isAuthenticating,
                            isOnboardingButton: true,
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

  Widget _buildLanguageSelectionPage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LanguageAwareStringHelper.getText(
            "select_language",
            context,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _getOnboardingTextColor(),
            ),
          ),
          const SizedBox(height: 40),

          // Language options with flags
          Column(
            children: [
              _buildLanguageOption("uz", "🇺🇿", "O'zbekcha", "Uzbek"),
              const SizedBox(height: 20),
              _buildLanguageOption("ru", "🇷🇺", "Русский", "Russian"),
              const SizedBox(height: 20),
              _buildLanguageOption("en", "🇺🇸", "English", "English"),
            ],
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    String languageCode,
    String flag,
    String nativeName,
    String englishName,
  ) {
    final isSelected = _selectedLanguage == languageCode;
    return GestureDetector(
      onTap: () => _selectLanguage(languageCode),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? _getSelectedButtonBackgroundColor()
                  : _getUnselectedButtonBackgroundColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? _getSelectedButtonBorderColor()
                    : _getUnselectedButtonBorderColor(),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: TextStyle(
                fontSize: 32,
                color:
                    isSelected
                        ? _getOnboardingTextColor()
                        : _getUnselectedButtonTextColor(),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected
                              ? _getOnboardingTextColor()
                              : _getUnselectedButtonTextColor(),
                    ),
                  ),
                  Text(
                    englishName,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isSelected
                              ? _getOnboardingTextSecondaryColor()
                              : _getUnselectedButtonTextColor().withOpacity(
                                0.7,
                              ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: _getOnboardingTextColor(),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleSignInPage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LanguageAwareStringHelper.getText(
            "sign_in_with_google",
            context,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _getOnboardingTextColor(),
            ),
          ),
          const SizedBox(height: 16),
          LanguageAwareStringHelper.getText(
            "sign_in_with_google_description",
            context,
            style: TextStyle(
              fontSize: 16,
              color: _getOnboardingTextSecondaryColor(),
            ),
          ),
          const SizedBox(height: 40),

          // Google Sign-In button
          if (!_isGoogleSignedIn) ...[
            Center(
              child: Container(
                width: 199,
                height: 44,
                child: InkWell(
                  onTap: _isAuthenticating ? null : _signInWithGoogle,
                  borderRadius: BorderRadius.circular(22),
                  child: ListenableBuilder(
                    listenable: ThemeState(),
                    builder: (context, child) {
                      final currentTheme = ThemeState().currentTheme;
                      final svgAsset =
                          currentTheme == AppTheme.lightTheme
                              ? "assets/images/ios_dark_rd_ctn.svg" // Black for light theme
                              : "assets/images/ios_neutral_rd_ctn.svg"; // Neutral for purple and blue themes

                      return SvgPicture.asset(svgAsset, width: 199, height: 44);
                    },
                  ),
                ),
              ),
            ),
          ],

          // User info display when signed in
          if (_isGoogleSignedIn) ...[
            if (_currentUser != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getOnboardingTextColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          _currentUser!.photoURL != null
                              ? NetworkImage(_currentUser!.photoURL!)
                              : null,
                      child:
                          _currentUser!.photoURL == null
                              ? Icon(
                                Icons.person,
                                size: 30,
                                color: _getOnboardingTextColor(),
                              )
                              : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser!.displayName ?? "User",
                            style: TextStyle(
                              color: _getOnboardingTextColor(),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _currentUser!.email ?? "",
                            style: TextStyle(
                              color: _getOnboardingTextSecondaryColor(),
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

            //const SizedBox(height: 100),
          ],

          // Loading indicator
          if (_isAuthenticating) ...[
            const SizedBox(height: 24),
            CenteredHouseLoadingIndicator(
              text: LanguageAwareStringHelper.getCurrent(context, "signing_in"),
              textStyle: TextStyle(
                color: _getOnboardingTextSecondaryColor(),
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileSetupPage() {
    return SingleChildScrollView(
      controller: _profileScrollController,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LanguageAwareStringHelper.getText(
              "complete_profile",
              context,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _getOnboardingTextColor(),
              ),
            ),
            const SizedBox(height: 32),

            // Name input
            LanguageAwareStringHelper.getText(
              "full_name",
              context,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _getOnboardingTextColor(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: _getOnboardingCardColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _nameController,
                keyboardType: TextInputType.text,
                style: TextStyle(
                  color:
                      _getInputTextColor(), // Use black text for better visibility in blue/purple themes
                ),
                decoration: InputDecoration(
                  hintText: LanguageAwareStringHelper.getCurrent(
                    context,
                    "full_name_hint",
                  ),
                  hintStyle: TextStyle(
                    color: _getOnboardingTextSecondaryColor().withOpacity(0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.cardBorder,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.cardBorder,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.cardBorder.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: Icon(
                    Icons.person,
                    color: _getOnboardingTextSecondaryColor(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Gender selection
            LanguageAwareStringHelper.getText(
              "gender",
              context,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _getOnboardingTextColor(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: _buildGenderOption(
                    1,
                    LanguageAwareStringHelper.getCurrent(context, "male"),
                    Icons.male,
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: _buildGenderOption(
                    2,
                    LanguageAwareStringHelper.getCurrent(context, "female"),
                    Icons.female,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Region selection
            LanguageAwareStringHelper.getText(
              "select_region",
              context,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _getOnboardingTextColor(),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoadingRegions)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getOnboardingTextColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CenteredHouseLoadingIndicator(
                  text: LanguageAwareStringHelper.getCurrent(
                    context,
                    "loading_regions",
                  ),
                  textStyle: TextStyle(
                    color: _getOnboardingTextColor(),
                    fontSize: 16,
                  ),
                  size: 20,
                ),
              )
            else if (_regions.isNotEmpty)
              _buildRegionSelector()
            else if (!_isLoadingRegions)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getOnboardingTextColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  LanguageAwareStringHelper.getCurrent(
                    context,
                    "no_regions_available",
                  ),
                  style: TextStyle(
                    color: _getOnboardingTextSecondaryColor(),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 32),

            // Student status
            LanguageAwareStringHelper.getText(
              "are_you_student",
              context,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _getOnboardingTextColor(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: _buildStudentOption(
                    true,
                    LanguageAwareStringHelper.getCurrent(
                      context,
                      "yes_student",
                    ),
                    Icons.school,
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: _buildStudentOption(
                    false,
                    LanguageAwareStringHelper.getCurrent(context, "no_student"),
                    Icons.work,
                  ),
                ),
              ],
            ),

            // University selection (only shown when user is a student)
            if (_isStudent == true) ...[
              const SizedBox(height: 32),

              if (_isLoadingUniversities)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getOnboardingTextColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CenteredHouseLoadingIndicator(
                    text: LanguageAwareStringHelper.getCurrent(
                      context,
                      "loading_universities",
                    ),
                    textStyle: TextStyle(
                      color: _getOnboardingTextColor(),
                      fontSize: 16,
                    ),
                    size: 20,
                  ),
                )
              else if (_universities.isNotEmpty)
                _buildUniversitySelector()
              else if (!_isLoadingUniversities)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getOnboardingTextColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    LanguageAwareStringHelper.getCurrent(
                      context,
                      "no_universities_available",
                    ),
                    style: TextStyle(
                      color: _getOnboardingTextSecondaryColor(),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 100),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(int gender, String label, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? _getSelectedButtonBackgroundColor()
                  : _getOnboardingTextColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? _getSelectedButtonTextColor() : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? _getSelectedButtonTextColor()
                        : _getOnboardingTextColor(),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color:
                  isSelected
                      ? _getSelectedButtonTextColor()
                      : _getOnboardingTextColor(),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionSelector() {
    return Container(
      decoration: BoxDecoration(
        color:
            _selectedRegionId != null
                ? _getSelectedButtonBackgroundColor()
                : _getOnboardingCardColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _selectedRegionId != null
                  ? _getSelectedButtonBorderColor()
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: _showRegionPicker,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(
                Icons.public,
                color:
                    _selectedRegionId != null
                        ? _getSelectedButtonTextColor()
                        : _getOnboardingTextSecondaryColor(),
                size: 24,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedRegionId != null) ...[
                      Text(
                        _getRegionName(
                          _regions.firstWhere(
                            (r) => r.id == _selectedRegionId,
                          )!,
                        ),
                        style: TextStyle(
                          color: _getSelectedButtonTextColor(),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      LanguageAwareStringHelper.getText(
                        "selected",
                        context,
                        style: TextStyle(
                          color: _getSelectedButtonTextColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      Text(
                        LanguageAwareStringHelper.getCurrent(
                          context,
                          "tap_to_select_region",
                        ),
                        style: TextStyle(
                          color: _getOnboardingTextSecondaryColor(),
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                _selectedRegionId != null
                    ? Icons.check_circle
                    : Icons.arrow_drop_down,
                color:
                    _selectedRegionId != null
                        ? _getSelectedButtonTextColor()
                        : _getOnboardingTextSecondaryColor(),
                size: 24,
              ),
            ],
          ),
        ),
      ),
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
      builder: (context) => _buildRegionPicker(),
    );
  }

  Widget _buildRegionPicker() {
    return Container(
      decoration: BoxDecoration(
        color: _getBottomSheetBackgroundColor(),
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
              color: _getBottomSheetHandleColor(),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              LanguageAwareStringHelper.getCurrent(context, "select_region"),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    _getBottomSheetTextColor(), // Use black text for better visibility in blue/purple themes
              ),
            ),
          ),

          // Region wheel picker
          Container(
            height: 200,
            child: CupertinoPicker(
              itemExtent: 50,
              onSelectedItemChanged: (index) {
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
                                _getBottomSheetTextColor(), // Use black text for better visibility in blue/purple themes
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
            child: SizedBox(
              width: double.infinity,
              child: GhostButtonFactory.text(
                onPressed: () {
                  Navigator.pop(context);
                },
                text: LanguageAwareStringHelper.getCurrent(context, "confirm"),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textColor: _getBottomSheetTextColor(),
                borderColor: _getBottomSheetTextColor(),
                isOnboardingButton: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentOption(bool isStudent, String label, IconData icon) {
    final isSelected = _isStudent == isStudent;
    return GestureDetector(
      onTap: () {
        logger.d("=== STUDENT OPTION SELECTED ===");
        logger.d("Selected isStudent: $isStudent");
        logger.d("Previous _isStudent: $_isStudent");
        logger.d(
          "Previous _selectedUniversity: ${_selectedUniversity != null ? _getUniversityName(_selectedUniversity!) : "None"} (ID: ${_selectedUniversity?.id})",
        );

        setState(() {
          _isStudent = isStudent;
          if (isStudent) {
            // Load universities when user selects "I"m a student"
            logger.d("Loading universities for student...");
            _loadUniversities();

            // Ensure university selection is maintained after loading
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted &&
                  _universities.isNotEmpty &&
                  _selectedUniversity == null) {
                logger.d(
                  "🔄 Delayed check: Setting university selection after loading",
                );
                setState(() {
                  _selectedUniversity = _universities.first;
                });
                logger.d(
                  "✅ Delayed university selection set to: ${_selectedUniversity != null ? _getUniversityName(_selectedUniversity!) : "None"} (ID: ${_selectedUniversity?.id})",
                );
              }
            });
          } else {
            // Clear university selection when user selects "I"m not a student"
            logger.d("Clearing university selection for non-student");
            _selectedUniversity = null;
          }
        });

        if (isStudent) {
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

        logger.d("After setState:");
        logger.d("_isStudent: $_isStudent");
        logger.d(
          "_selectedUniversity: ${_selectedUniversity != null ? _getUniversityName(_selectedUniversity!) : "None"} (ID: ${_selectedUniversity?.id})",
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? _getSelectedButtonBackgroundColor()
                  : _getOnboardingTextColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? _getSelectedButtonTextColor() : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? _getSelectedButtonTextColor()
                        : _getOnboardingTextColor(),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color:
                  isSelected
                      ? _getSelectedButtonTextColor()
                      : _getOnboardingTextColor(),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUniversitySelector() {
    return Container(
      decoration: BoxDecoration(
        color:
            _selectedUniversity != null
                ? _getSelectedButtonBackgroundColor()
                : _getOnboardingCardColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _selectedUniversity != null
                  ? _getSelectedButtonBorderColor()
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: _showUniversityPicker,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(
                Icons.school,
                color:
                    _selectedUniversity != null
                        ? _getSelectedButtonTextColor()
                        : _getOnboardingTextSecondaryColor(),
                size: 24,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedUniversity != null) ...[
                      Text(
                        _getUniversityName(_selectedUniversity!),
                        style: TextStyle(
                          color: _getSelectedButtonTextColor(),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      LanguageAwareStringHelper.getText(
                        "selected",
                        context,
                        style: TextStyle(
                          color: _getSelectedButtonTextColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      Text(
                        LanguageAwareStringHelper.getCurrent(
                          context,
                          "tap_to_select_university",
                        ),
                        style: TextStyle(
                          color: _getOnboardingTextSecondaryColor(),
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                _selectedUniversity != null
                    ? Icons.check_circle
                    : Icons.arrow_drop_down,
                color:
                    _selectedUniversity != null
                        ? _getSelectedButtonTextColor()
                        : _getOnboardingTextSecondaryColor(),
                size: 24,
              ),
            ],
          ),
        ),
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
      builder: (context) => _buildUniversityPicker(),
    );
  }

  Widget _buildUniversityPicker() {
    return Container(
      decoration: BoxDecoration(
        color: _getBottomSheetBackgroundColor(),
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
              color: _getBottomSheetHandleColor(),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              LanguageAwareStringHelper.getCurrent(
                context,
                "select_university",
              ),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    _getBottomSheetTextColor(), // Use black text for better visibility in blue/purple themes
              ),
            ),
          ),

          // University wheel picker
          Container(
            height: 200,
            child: CupertinoPicker(
              itemExtent: 50,
              onSelectedItemChanged: (index) {
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
                                _getBottomSheetTextColor(), // Use black text for better visibility in blue/purple themes
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
            child: SizedBox(
              width: double.infinity,
              child: GhostButtonFactory.text(
                onPressed: () {
                  Navigator.pop(context);
                },
                text: LanguageAwareStringHelper.getCurrent(context, "confirm"),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textColor: _getBottomSheetTextColor(),
                borderColor: _getBottomSheetTextColor(),
                isOnboardingButton: true,
              ),
            ),
          ),
        ],
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
        if (_selectedGender == null ||
            _selectedRegionId == null ||
            _isStudent == null)
          return null;
        if (_isStudent == true && _selectedUniversity == null) return null;
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

  // Theme-dependent color helper methods
  Color _getPrimaryColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.primary;
    } else if (ThemeState().isLightTheme) {
      return LightThemeColors.primary;
    } else {
      return AppColors.primary;
    }
  }

  /// Get theme-aware onboarding text color
  Color _getOnboardingTextColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.onboardingText;
    } else if (ThemeState().isLightTheme) {
      return LightThemeColors.onboardingText;
    } else {
      // Purple theme (default) - ensure white text for proper contrast
      return Colors.white;
    }
  }

  /// Get theme-aware onboarding secondary text color
  Color _getOnboardingTextSecondaryColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.onboardingTextSecondary;
    } else if (ThemeState().isLightTheme) {
      return LightThemeColors.onboardingTextSecondary;
    } else {
      return AppColors.onboardingTextSecondary;
    }
  }

  /// Get theme-aware onboarding card color
  Color _getOnboardingCardColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.onboardingCard;
    } else if (ThemeState().isLightTheme) {
      return LightThemeColors.onboardingCard;
    } else {
      return AppColors.onboardingCard;
    }
  }

  /// Get theme-aware success color
  Color _getSuccessColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.success;
    } else if (ThemeState().isLightTheme) {
      return LightThemeColors.success;
    } else {
      return AppColors.success;
    }
  }

  /// Get theme-aware onboarding background color
  Color _getOnboardingBackgroundColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.onboardingBackground;
    } else if (ThemeState().isLightTheme) {
      return LightThemeColors.onboardingBackground;
    } else {
      return AppColors.onboardingBackground;
    }
  }

  /// Get theme-aware selected button background color with proper contrast
  Color _getSelectedButtonBackgroundColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.primary; // Blue background
    } else if (ThemeState().isLightTheme) {
      return Colors.transparent; // Transparent background for light theme
    } else {
      return AppColors.primary; // Purple background
    }
  }

  /// Get theme-aware selected button text color with proper contrast
  Color _getSelectedButtonTextColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white; // White text on blue
    } else if (ThemeState().isLightTheme) {
      return Colors.black; // Black text on transparent background
    } else {
      return Colors.white; // White text on purple
    }
  }

  /// Get theme-aware selected button border color
  Color _getSelectedButtonBorderColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white; // White border for blue theme
    } else if (ThemeState().isLightTheme) {
      return Colors.black; // Black border for light theme
    } else {
      return Colors.white; // White border for purple theme
    }
  }

  /// Get theme-aware unselected button background color
  Color _getUnselectedButtonBackgroundColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.primary; // Blue background for blue theme
    } else if (ThemeState().isLightTheme) {
      return Colors.transparent; // Transparent background for light theme
    } else {
      return AppColors.primary; // Purple background for purple theme
    }
  }

  /// Get theme-aware unselected button border color
  Color _getUnselectedButtonBorderColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white; // White border for blue theme
    } else if (ThemeState().isLightTheme) {
      return Colors.grey.shade300; // Light grey border for light theme
    } else {
      return Colors.white; // White border for purple theme
    }
  }

  /// Get theme-aware unselected button text color
  Color _getUnselectedButtonTextColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white; // White text on blue
    } else if (ThemeState().isLightTheme) {
      return Colors.black; // Black text on transparent background
    } else {
      return Colors.white; // White text on purple
    }
  }

  /// Get theme-aware input text color for better visibility
  Color _getInputTextColor() {
    if (ThemeState().isBlueTheme) {
      return Colors
          .black; // Black text on white/light blue background for better visibility
    } else if (ThemeState().isLightTheme) {
      return Colors.black; // Black text on white background
    } else {
      return Colors
          .black; // Black text on white background for better visibility in purple theme
    }
  }

  /// Get theme-aware bottom sheet background color
  Color _getBottomSheetBackgroundColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white; // White background for blue theme
    } else if (ThemeState().isLightTheme) {
      return LightThemeColors.onboardingCard;
    } else {
      return AppColors.onboardingCard;
    }
  }

  /// Get theme-aware bottom sheet text color
  Color _getBottomSheetTextColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.black; // Black text on white background for blue theme
    } else if (ThemeState().isLightTheme) {
      return Colors.black; // Black text on white background
    } else {
      return Colors
          .black; // Black text on white background for better visibility in purple theme
    }
  }

  /// Get theme-aware bottom sheet handle bar color
  Color _getBottomSheetHandleColor() {
    if (ThemeState().isBlueTheme) {
      return Colors
          .grey
          .shade400; // Light grey handle on white background for blue theme
    } else if (ThemeState().isLightTheme) {
      return _getOnboardingTextSecondaryColor().withOpacity(0.3);
    } else {
      return _getOnboardingTextSecondaryColor().withOpacity(0.3);
    }
  }

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

  /// Get language-aware region short name
  String _getRegionShortName(Region region) {
    final currentLanguage = LanguageState().currentLanguage;
    switch (currentLanguage) {
      case "en":
        return region.shortNameEn ?? region.shortName ?? "";
      case "ru":
        return region.shortNameRu ?? region.shortName ?? "";
      case "uz":
        return region.shortNameUz ?? region.shortName ?? "";
      default:
        return region.shortName ?? "";
    }
  }

  /// Get language-aware university short name
  String _getUniversityShortName(University university) {
    return university.getLocalizedShortName(LanguageState().currentLanguage);
  }
}
