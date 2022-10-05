import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_infinite_list/posts/posts.dart';
import 'package:http/http.dart' as http;
import 'package:stream_transform/stream_transform.dart';

part 'post_event.dart';
part 'post_state.dart';

const _competitionLimit = 20;
const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class CompetitionBloc extends Bloc<CompetitionEvent, CompetitionState> {
  CompetitionBloc({required this.httpClient})
      : super(const CompetitionState()) {
    on<CompetitionFetched>(
      _onCompetitionFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final http.Client httpClient;

  Future<void> _onCompetitionFetched(
    CompetitionFetched event,
    Emitter<CompetitionState> emit,
  ) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == CompetitionStatus.initial) {
        final competitions = await _fetchCompetitions();
        return emit(
          state.copyWith(
            status: CompetitionStatus.success,
            competitions: competitions,
            hasReachedMax: false,
          ),
        );
      }
      final competitions = await _fetchCompetitions(state.competitions.length);
      competitions.isEmpty
          ? emit(state.copyWith(hasReachedMax: true))
          : emit(
              state.copyWith(
                status: CompetitionStatus.success,
                competitions: List.of(state.competitions)..addAll(competitions),
                hasReachedMax: false,
              ),
            );
    } catch (_) {
      emit(state.copyWith(status: CompetitionStatus.failure));
    }
  }

  Future<List<Competition>> _fetchCompetitions([int startIndex = 0]) async {
    final response = await httpClient.get(
      Uri.https(
        'https://api-d.racegorilla.com',
        '/competition',
        <String, String>{
          '_start': '$startIndex',
          '_limit': '$_competitionLimit'
        },
      ),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as List;
      return body.map((dynamic json) {
        final map = json as Map<String, dynamic>;
        return Competition(
          competitionId: map['CompetitionId'] as int,
          name: map['Name'] as String,
          location: map['Location'] as String,
        );
      }).toList();
    }

    throw Exception('error fetching competitions');
  }
}
