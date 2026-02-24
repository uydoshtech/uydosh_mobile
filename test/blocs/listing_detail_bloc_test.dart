import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";

class MockListingService extends Mock implements IListingService {}

void main() {
  late MockListingService mockListingService;

  setUp(() {
    mockListingService = MockListingService();
  });

  group("ListingDetailBloc", () {
    test("initial state is ListingDetailState.initial", () {
      final bloc = ListingDetailBloc(mockListingService);
      expect(bloc.state, const ListingDetailState.initial());
      bloc.close();
    });

    test("emits [loading, loaded] when fetchListingDetail succeeds", () async {
      const listingDetail = ListingDetail(
        id: 1,
        userId: 1,
        title: "Test Listing",
        listingTypeId: 1,
        price: 100,
        isActive: true,
        createdAt: "2024-01-01",
        updatedAt: "2024-01-01",
        user: UserDetail(id: 1, createdAt: "2024-01-01"),
        listingType: ListingTypeDetail(
          id: 1,
          nameUz: "Room",
          nameRu: "Room",
          nameEn: "Room",
          code: "room",
        ),
      );

      when(() => mockListingService.getListingDetail(1)).thenAnswer(
        (_) async => listingDetail,
      );

      final bloc = ListingDetailBloc(mockListingService);

      bloc.add(const ListingDetailEvent.fetchListingDetail(id: 1));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const ListingDetailState.loading(),
          ListingDetailState.loaded(listingDetail: listingDetail),
        ]),
      );

      bloc.close();
    });

    test("emits [loading, error] when fetchListingDetail fails", () async {
      when(() => mockListingService.getListingDetail(999))
          .thenThrow(Exception("Not found"));

      final bloc = ListingDetailBloc(mockListingService);

      bloc.add(const ListingDetailEvent.fetchListingDetail(id: 999));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const ListingDetailState.loading(),
          isA<ListingDetailState>().having(
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

    test("emits [loaded] when updateListingDetail is added", () async {
      const listingDetail = ListingDetail(
        id: 1,
        userId: 1,
        title: "Updated Listing",
        listingTypeId: 1,
        price: 150,
        isActive: true,
        createdAt: "2024-01-01",
        updatedAt: "2024-01-02",
        user: UserDetail(id: 1, createdAt: "2024-01-01"),
        listingType: ListingTypeDetail(
          id: 1,
          nameUz: "Room",
          nameRu: "Room",
          nameEn: "Room",
          code: "room",
        ),
      );

      final bloc = ListingDetailBloc(mockListingService);

      bloc.add(ListingDetailEvent.updateListingDetail(listingDetail: listingDetail));

      await expectLater(
        bloc.stream,
        emits(ListingDetailState.loaded(listingDetail: listingDetail)),
      );

      bloc.close();
    });
  });
}
