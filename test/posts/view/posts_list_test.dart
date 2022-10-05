// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/posts/posts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCompetitionBloc extends MockBloc<CompetitionEvent, CompetitionState>
    implements CompetitionBloc {}

extension on WidgetTester {
  Future<void> pumpCompetitionsList(CompetitionBloc competitionBloc) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: competitionBloc,
          child: CompetitionsList(),
        ),
      ),
    );
  }
}

void main() {
  final mockCompetitions = List.generate(
    5,
    (i) => Competition(competitionId: i, name: 'name', location: 'location'),
  );

  late CompetitionBloc competitionBloc;

  setUp(() {
    competitionBloc = MockCompetitionBloc();
  });

  group('CompetitionsList', () {
    testWidgets(
        'renders CircularProgressIndicator '
        'when competition status is initial', (tester) async {
      when(() => competitionBloc.state).thenReturn(const CompetitionState());
      await tester.pumpCompetitionsList(competitionBloc);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'renders no competitions text '
        'when competition status is success but with 0 competitions',
        (tester) async {
      when(() => competitionBloc.state).thenReturn(
        const CompetitionState(
            status: CompetitionStatus.success, hasReachedMax: true),
      );
      await tester.pumpCompetitionsList(competitionBloc);
      expect(find.text('no competitions'), findsOneWidget);
    });

    testWidgets(
        'renders 5 competitions and a bottom loader when competition max is not reached yet',
        (tester) async {
      when(() => competitionBloc.state).thenReturn(
        CompetitionState(
          status: CompetitionStatus.success,
          competitions: mockCompetitions,
        ),
      );
      await tester.pumpCompetitionsList(competitionBloc);
      expect(find.byType(CompetitionListItem), findsNWidgets(5));
      expect(find.byType(BottomLoader), findsOneWidget);
    });

    testWidgets('does not render bottom loader when competition max is reached',
        (tester) async {
      when(() => competitionBloc.state).thenReturn(
        CompetitionState(
          status: CompetitionStatus.success,
          competitions: mockCompetitions,
          hasReachedMax: true,
        ),
      );
      await tester.pumpCompetitionsList(competitionBloc);
      expect(find.byType(BottomLoader), findsNothing);
    });

    testWidgets('fetches more competitions when scrolled to the bottom',
        (tester) async {
      when(() => competitionBloc.state).thenReturn(
        CompetitionState(
          status: CompetitionStatus.success,
          competitions: List.generate(
            10,
            (i) => Competition(
                competitionId: i, name: 'name', location: 'location'),
          ),
        ),
      );
      await tester.pumpCompetitionsList(competitionBloc);
      await tester.drag(find.byType(CompetitionsList), const Offset(0, -500));
      verify(() => competitionBloc.add(CompetitionFetched())).called(1);
    });
  });
}
