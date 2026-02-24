import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:uy_dosh/domain/services/subway_station_service.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";

class MockSubwayStationService extends Mock implements ISubwayStationService {}

void main() {
  late MockSubwayStationService mockSubwayStationService;

  setUp(() {
    mockSubwayStationService = MockSubwayStationService();
  });

  group("SubwayStationsBloc", () {
    test("initial state is SubwayStationsState.initial", () {
      final bloc = SubwayStationsBloc(mockSubwayStationService);
      expect(bloc.state, const SubwayStationsState.initial());
      bloc.close();
    });

    test("emits [loading, loaded] when fetchSubwayStations succeeds", () async {
      // SubwayStationsBloc uses MetroCache.getAllStations() - static data
      // No need to mock the service; the bloc uses MetroCache directly
      final bloc = SubwayStationsBloc(mockSubwayStationService);

      bloc.add(const SubwayStationsEvent.fetchSubwayStations());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const SubwayStationsState.loading(),
          isA<SubwayStationsState>().having(
            (s) => s.map(
              initial: (_) => 0,
              loading: (_) => 0,
              loaded: (s) => s.stations.length,
              error: (_) => 0,
            ),
            "stations count",
            greaterThan(0),
          ),
        ]),
      );

      bloc.close();
    });

    test("emits [loading, loaded] when fetchSubwayStationsByLine succeeds",
        () async {
      // SubwayStationsBloc uses MetroCache.getStationsForLine() - static data
      final bloc = SubwayStationsBloc(mockSubwayStationService);

      bloc.add(const SubwayStationsEvent.fetchSubwayStationsByLine(line: 1));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const SubwayStationsState.loading(),
          isA<SubwayStationsState>().having(
            (s) => s.map(
              initial: (_) => 0,
              loading: (_) => 0,
              loaded: (s) => s.stations.length,
              error: (_) => 0,
            ),
            "stations count",
            greaterThan(0),
          ),
        ]),
      );

      bloc.close();
    });

    test("fetchSubwayStationsByLine with invalid line emits empty list", () async {
      final bloc = SubwayStationsBloc(mockSubwayStationService);

      bloc.add(const SubwayStationsEvent.fetchSubwayStationsByLine(line: 99));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const SubwayStationsState.loading(),
          isA<SubwayStationsState>().having(
            (s) => s.map(
              initial: (_) => 0,
              loading: (_) => 0,
              loaded: (s) => s.stations.length,
              error: (_) => -1,
            ),
            "stations count",
            0,
          ),
        ]),
      );

      bloc.close();
    });
  });
}
