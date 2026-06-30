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
    final mockAnalytics = getIt<AppAnalyticsService>() as MockAppAnalyticsService;
    when(
      () => mockAnalytics.logSearchPerformed(
        listingTypeId: any(named: "listingTypeId"),
        locationId: any(named: "locationId"),
        subwayStationId: any(named: "subwayStationId"),
        subwayLineId: any(named: "subwayLineId"),
        gender: any(named: "gender"),
        hasPriceFilter: any(named: "hasPriceFilter"),
        hasGenderFilter: any(named: "hasGenderFilter"),
      ),
    ).thenAnswer((_) async {});
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
    test("loadMore keeps hasMore true when exact total exceeds loaded count", () async {
      const page1 = [
        Listing(
          id: 1,
          userId: 1,
          title: "A",
          listingTypeId: 1,
          price: 100,
          isActive: true,
          createdAt: "2024-01-01",
          updatedAt: "2024-01-01",
        ),
      ];
      const page2 = [
        Listing(
          id: 2,
          userId: 1,
          title: "B",
          listingTypeId: 1,
          price: 120,
          isActive: true,
          createdAt: "2024-01-02",
          updatedAt: "2024-01-02",
        ),
      ];

      when(
        () => mockListingService.searchListings(
          page: 1,
          limit: 1,
          isActive: true,
          gender: 2,
        ),
      ).thenAnswer(
        (_) async => const PageableResponse<Listing>(
          data: page1,
          total: 94,
          page: 1,
          limit: 1,
          totalPages: 2,
        ),
      );
      when(
        () => mockListingService.searchListings(
          page: 2,
          limit: 1,
          isActive: true,
          gender: 2,
        ),
      ).thenAnswer(
        (_) async => const PageableResponse<Listing>(
          data: page2,
          total: 2,
          page: 2,
          limit: 1,
          totalPages: 2,
        ),
      );

      final bloc = ListingsBloc(mockListingService);

      bloc.add(const ListingsEvent.searchListings(gender: 2, limit: 1));
      await bloc.stream.firstWhere(
        (state) => state.maybeMap(
          loaded: (s) => s.listings.length == 1,
          orElse: () => false,
        ),
      );

      bloc.add(const ListingsEvent.loadMore(limit: 1));
      final loaded = await bloc.stream.firstWhere(
        (state) => state.maybeMap(
          loaded: (s) => s.listings.length == 2,
          orElse: () => false,
        ),
      );

      expect(
        loaded.maybeMap(loaded: (s) => s.hasMore, orElse: () => false),
        isTrue,
      );
      expect(
        loaded.maybeMap(loaded: (s) => s.total, orElse: () => null),
        94,
      );

      bloc.close();
    });
  });
}
