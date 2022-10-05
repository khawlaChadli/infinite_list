import 'package:flutter/material.dart';
import 'package:flutter_infinite_list/posts/models/post.dart';
import 'package:flutter_infinite_list/posts/posts.dart';

class CompetitionListItem extends StatelessWidget {
  const CompetitionListItem({super.key, required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      child: ListTile(
        leading: Text('${competition.competitionId}', style: textTheme.caption),
        title: Text(competition.name),
        isThreeLine: true,
        subtitle: Text(competition.location),
        dense: true,
      ),
    );
  }
}
