// ignore_for_file: prefer_const_constructors
import 'package:flutter_infinite_list/posts/posts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompetitionState', () {
    test('supports value comparison', () {
      expect(CompetitionState(), CompetitionState());
      expect(
        CompetitionState().toString(),
        CompetitionState().toString(),
      );
    });
  });
}
