import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/domain/services/listing_claim_service.dart";

class TestClient extends IOAuthApiClient {
  TestClient(super.dio);
}

void main() {
  test("eligibility remains boolean and optional username supports ID-only matches", () async {
    final dio = Dio();
    final requests = <RequestOptions>[];
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      requests.add(options);
      handler.resolve(Response(requestOptions: options, data: {"eligible": true}));
    }));
    final service = ListingClaimService(TestClient(dio));
    final result = await service.eligibility(42);
    expect(result.eligible, isTrue);
    expect(result.telegramUsername, isNull);
    expect(requests.single.path, endsWith("/listings/42/claim-eligibility"));
    expect(requests.single.method, "GET");
  });

  test("claim posts without accepting a client-provided owner or username", () async {
    final dio = Dio();
    RequestOptions? request;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      request = options;
      handler.resolve(Response(requestOptions: options, data: {"listing": {"id": 42}}));
    }));
    await ListingClaimService(TestClient(dio)).claim(42);
    expect(request!.method, "POST");
    expect(request!.path, endsWith("/listings/42/claim"));
    expect(request!.data, isEmpty);
  });

  test("claim errors propagate so UI can retain retry and recheck eligibility", () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.reject(DioException(requestOptions: options,
        response: Response(requestOptions: options, statusCode: 403)));
    }));
    await expectLater(ListingClaimService(TestClient(dio)).claim(42), throwsA(isA<DioException>()));
  });
}
