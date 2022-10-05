import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/posts/posts.dart';
import 'package:flutter_infinite_list/posts/view/posts_list.dart';
import 'package:http/http.dart' as http;

class CompetitionsPage extends StatelessWidget {
  const CompetitionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Competitions')),
      body: BlocProvider(
        create: (_) => CompetitionBloc(httpClient: http.Client())
          ..add(CompetitionFetched()),
        child: const CompetitionsList(),
      ),
    );
  }
}
