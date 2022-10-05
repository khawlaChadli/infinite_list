part of 'post_bloc.dart';

enum CompetitionStatus { initial, success, failure }

class CompetitionState extends Equatable {
  const CompetitionState({
    this.status = CompetitionStatus.initial,
    this.competitions = const <Competition>[],
    this.hasReachedMax = false,
  });

  final CompetitionStatus status;
  final List<Competition> competitions;
  final bool hasReachedMax;

  CompetitionState copyWith({
    CompetitionStatus? status,
    List<Competition>? competitions,
    bool? hasReachedMax,
  }) {
    return CompetitionState(
      status: status ?? this.status,
      competitions: competitions ?? this.competitions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''CompetitionState { status: $status, hasReachedMax: $hasReachedMax, competitions: ${competitions.length} }''';
  }

  @override
  List<Object> get props => [status, competitions, hasReachedMax];
}
