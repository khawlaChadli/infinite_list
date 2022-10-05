import 'package:equatable/equatable.dart';

class Competition extends Equatable {
  const Competition(
      {required this.competitionId,
      required this.name,
      required this.location});

  final int competitionId;
  final String name;
  final String location;

  @override
  List<Object> get props => [competitionId, name, location];
}
