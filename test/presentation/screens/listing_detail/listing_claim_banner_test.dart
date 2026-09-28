import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/l10n/app_localizations.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_claim_banner.dart";

class TestClient extends IOAuthApiClient { TestClient(super.dio); }

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;
  late bool eligible;
  late int claims;
  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({"user_id": 7});
    AuthenticationState().setAuthenticationStatus(true);
    eligible = true;
    claims = 0;
    dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (options.method == "POST") claims++;
      handler.resolve(Response(requestOptions: options,
        data: {"eligible": eligible, "telegramUsername": "alice"}));
    }));
    getIt.registerSingleton<IOAuthApiClient>(TestClient(dio));
  });
  tearDown(() async { await getIt.reset(); });

  Widget app(int listingId) => MaterialApp(
    locale: const Locale("en"),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: ListingClaimBanner(listingId: listingId, onClaimed: () {})),
  );

  testWidgets("Later keeps the banner and does not reopen automatically", (tester) async {
    await tester.pumpWidget(app(101));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining("@alice"), findsNWidgets(2));
    await tester.tap(find.text("Later"));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text("Add to my listings"), findsOneWidget);
    expect(claims, 0);
    expect((await SharedPreferences.getInstance()).getBool("uydosh.claimPrompt.v1.7.101"), isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app(101));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.text("Add to my listings"));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text("Later"));
    await tester.pumpAndSettle();
  });

  testWidgets("ineligible viewer sees no ownership UI", (tester) async {
    eligible = false;
    await tester.pumpWidget(app(102));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text("Add to my listings"), findsNothing);
    expect(claims, 0);
  });

  testWidgets("logout while confirmation is open prevents a claim", (tester) async {
    await tester.pumpWidget(app(103));
    await tester.pumpAndSettle();
    AuthenticationState().setAuthenticationStatus(false);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, "Add to my listings").last);
    await tester.pumpAndSettle();
    expect(claims, 0);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
