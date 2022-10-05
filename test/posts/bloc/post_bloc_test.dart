import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_infinite_list/posts/bloc/post_bloc.dart';
import 'package:flutter_infinite_list/posts/models/post.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements http.Client {}

Uri _competitionsUrl({required int start}) {
  return Uri.https(
    'https://api-d.racegorilla.com',
    '/competition',
    <String, String>{'_start': '$start', '_limit': '20'},
  );
}

void main() {
  group('CompetitionBloc', () {
    const mockCompetitions = [
      Competition(competitionId: 1, name: 'name', location: 'location')
    ];
    const extraMockCompetitions = [
      Competition(competitionId: 2, name: 'name', location: 'location')
    ];

    late http.Client httpClient;

    setUpAll(() {
      registerFallbackValue(Uri());
    });

    setUp(() {
      httpClient = MockClient();
    });

    test('initial state is CompetitionState()', () {
      expect(CompetitionBloc(httpClient: httpClient).state,
          const CompetitionState());
    });

    group('CompetitionFetched', () {
      blocTest<CompetitionBloc, CompetitionState>(
        'emits nothing when competitions has reached maximum amount',
        build: () => CompetitionBloc(httpClient: httpClient),
        seed: () => const CompetitionState(hasReachedMax: true),
        act: (bloc) => bloc.add(CompetitionFetched()),
        expect: () => <CompetitionState>[],
      );

      blocTest<CompetitionBloc, CompetitionState>(
        'emits successful status when http fetches initial competitions',
        setUp: () {
          when(() => httpClient.get(any())).thenAnswer((_) async {
            return http.Response(
              '[{ "competitionId": 1, "name": "name", "location": "location" }]',
              200,
            );
          });
        },
        build: () => CompetitionBloc(httpClient: httpClient),
        act: (bloc) => bloc.add(CompetitionFetched()),
        expect: () => const <CompetitionState>[
          CompetitionState(
              status: CompetitionStatus.success, competitions: mockCompetitions)
        ],
        verify: (_) {
          verify(() => httpClient.get(_competitionsUrl(start: 0))).called(1);
        },
      );

      blocTest<CompetitionBloc, CompetitionState>(
        'drops new events when processing current event',
        setUp: () {
          when(() => httpClient.get(any())).thenAnswer((_) async {
            return http.Response(
              '[{ "competitionId": 1, "name": "name", "location": "location" }]',
              200,
            );
          });
        },
        build: () => CompetitionBloc(httpClient: httpClient),
        act: (bloc) => bloc
          ..add(CompetitionFetched())
          ..add(CompetitionFetched()),
        expect: () => const <CompetitionState>[
          CompetitionState(
              status: CompetitionStatus.success, competitions: mockCompetitions)
        ],
        verify: (_) {
          verify(() => httpClient.get(any())).called(1);
        },
      );

      blocTest<CompetitionBloc, CompetitionState>(
        'throttles events',
        setUp: () {
          when(() => httpClient.get(any())).thenAnswer((_) async {
            return http.Response(
              '[{ "competitionId": 1, "name": "name", "location": "location" }]',
              200,
            );
          });
        },
        build: () => CompetitionBloc(httpClient: httpClient),
        act: (bloc) async {
          bloc.add(CompetitionFetched());
          await Future<void>.delayed(Duration.zero);
          bloc.add(CompetitionFetched());
        },
        expect: () => const <CompetitionState>[
          CompetitionState(
              status: CompetitionStatus.success, competitions: mockCompetitions)
        ],
        verify: (_) {
          verify(() => httpClient.get(any())).called(1);
        },
      );

      blocTest<CompetitionBloc, CompetitionState>(
        'emits failure status when http fetches competitions and throw exception',
        setUp: () {
          when(() => httpClient.get(any())).thenAnswer(
            (_) async => http.Response('', 500),
          );
        },
        build: () => CompetitionBloc(httpClient: httpClient),
        act: (bloc) => bloc.add(CompetitionFetched()),
        expect: () => <CompetitionState>[
          const CompetitionState(status: CompetitionStatus.failure)
        ],
        verify: (_) {
          verify(() => httpClient.get(_competitionsUrl(start: 0))).called(1);
        },
      );

      blocTest<CompetitionBloc, CompetitionState>(
        'emits successful status and reaches max competitions when '
        '0 additional competitions are fetched',
        setUp: () {
          when(() => httpClient.get(any())).thenAnswer(
            (_) async => http.Response('[]', 200),
          );
        },
        build: () => CompetitionBloc(httpClient: httpClient),
        seed: () => const CompetitionState(
          status: CompetitionStatus.success,
          competitions: mockCompetitions,
        ),
        act: (bloc) => bloc.add(CompetitionFetched()),
        expect: () => const <CompetitionState>[
          CompetitionState(
            status: CompetitionStatus.success,
            competitions: mockCompetitions,
            hasReachedMax: true,
          )
        ],
        verify: (_) {
          verify(() => httpClient.get(_competitionsUrl(start: 1))).called(1);
        },
      );

      blocTest<CompetitionBloc, CompetitionState>(
        'emits successful status and does not reach max competitions '
        'when additional competitions are fetched',
        setUp: () {
          when(() => httpClient.get(any())).thenAnswer((_) async {
            return http.Response(
              '[{ "competitionId": 1, "name": "name", "location": "location" }]',
              200,
            );
          });
        },
        build: () => CompetitionBloc(httpClient: httpClient),
        seed: () => const CompetitionState(
          status: CompetitionStatus.success,
          competitions: mockCompetitions,
        ),
        act: (bloc) => bloc.add(CompetitionFetched()),
        expect: () => const <CompetitionState>[
          CompetitionState(
            status: CompetitionStatus.success,
            competitions: [...mockCompetitions, ...extraMockCompetitions],
          )
        ],
        verify: (_) {
          verify(() => httpClient.get(_competitionsUrl(start: 1))).called(1);
        },
      );
    });
  });
}
