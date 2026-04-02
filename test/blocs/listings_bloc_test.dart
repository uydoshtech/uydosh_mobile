import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/pageable_response.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_event.dart";
import "package:uy_dosh/presentation/blocs/listings_state.dart";

class MockListingService extends Mock implements IListingService {}

class MockAppAnalyticsService extends Mock implements AppAnalyticsService {}

void main() {
  late MockListingService mockListingService;

  setUpAll(() {
    registerFallbackValue(const ListingsEvent.fetchListings());
    // Register mock analytics for tests that trigger search/location/subway
    if (!getIt.isRegistered<AppAnalyticsService>()) {
      getIt.registerSingleton<AppAnalyticsService>(MockAppAnalyticsService());
    }
  });

  setUp(() {
    mockListingService = MockListingService();
  });

  group("ListingsBloc", () {
    test("initial state is ListingsState.initial", () {
      final bloc = ListingsBloc(mockListingService);
      expect(bloc.state, const ListingsState.initial());
      bloc.close();
    });

    test("emits [loading, loaded] when fetchListings succeeds", () async {
      const listings = [
        Listing(
          id: 1,
          userId: 1,
          title: "Test",
          listingTypeId: 1,
          price: 100,
          isActive: true,
          createdAt: "2024-01-01",
          updatedAt: "2024-01-01",
        ),
      ];
      when(() => mockListingService.getListings(
            page: any(named: "page"),
            limit: any(named: "limit"),
            isActive: any(named: "isActive"),
          )).thenAnswer((_) async => const PageableResponse<Listing>(
                data: listings,
                total: 1,
                page: 1,
                limit: 10,
                totalPages: 1,
              ));

      final bloc = ListingsBloc(mockListingService);

      bloc.add(const ListingsEvent.fetchListings());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ListingsState>().having(
            (s) => s.map(
              initial: (_) => "initial",
              loading: (_) => "loading",
              loaded: (_) => "loaded",
              error: (_) => "error",
            ),
            "state",
            "loading",
          ),
          isA<ListingsState>().having(
            (s) => s.map(
              initial: (_) => 0,
              loading: (_) => 0,
              loaded: (s) => s.listings.length,
              error: (_) => 0,
            ),
            "listings count",
            1,
          ),
        ]),
      );

      bloc.close();
    });

    test("emits [loading, error] when fetchListings fails", () async {
      when(() => mockListingService.getListings(
            page: any(named: "page"),
            limit: any(named: "limit"),
            isActive: any(named: "isActive"),
          )).thenThrow(Exception("Network error"));

      final bloc = ListingsBloc(mockListingService);

      bloc.add(const ListingsEvent.fetchListings());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ListingsState>(),
          isA<ListingsState>().having(
            (s) => s.map(
              initial: (_) => false,
              loading: (_) => false,
              loaded: (_) => false,
              error: (_) => true,
            ),
            "is error",
            true,
          ),
        ]),
      );

      bloc.close();
    });

    test("emits [loading, loaded] when fetchUserListings succeeds", () async {
      const listings = [
        Listing(
          id: 2,
          userId: 1,
          title: "My Listing",
          listingTypeId: 1,
          price: 200,
          isActive: true,
          createdAt: "2024-01-01",
          updatedAt: "2024-01-01",
        ),
      ];
      when(() => mockListingService.getUserListings(
            page: any(named: "page"),
            limit: any(named: "limit"),
          )).thenAnswer((_) async => const PageableResponse<Listing>(
                data: listings,
                total: 1,
                page: 1,
                limit: 10,
                totalPages: 1,
              ));

      final bloc = ListingsBloc(mockListingService);

      bloc.add(const ListingsEvent.fetchUserListings());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ListingsState>(),
          isA<ListingsState>().having(
            (s) => s.map(
              initial: (_) => 0,
              loading: (_) => 0,
              loaded: (s) => s.listings.length,
              error: (_) => 0,
            ),
            "listings count",
            1,
          ),
        ]),
      );

      bloc.close();
    });
  });
}
