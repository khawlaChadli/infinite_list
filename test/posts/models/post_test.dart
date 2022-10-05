// ignore_for_file: prefer_const_constructors
import 'package:flutter_infinite_list/posts/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Competition', () {
    test('supports value comparison', () {
      expect(
        Competition(competitionId: 1, name: 'Name', location: 'location'),
        Competition(competitionId: 1, name: 'Name', location: 'location'),
      );
    });
  });
}
