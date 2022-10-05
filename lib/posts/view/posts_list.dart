import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/posts/posts.dart';

class CompetitionsList extends StatefulWidget {
  const CompetitionsList({super.key});

  @override
  State<CompetitionsList> createState() => _CompetitionsListState();
}

class _CompetitionsListState extends State<CompetitionsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompetitionBloc, CompetitionState>(
      builder: (context, state) {
        switch (state.status) {
          case CompetitionStatus.failure:
            return const Center(child: Text('failed to fetch competitions'));
          case CompetitionStatus.success:
            if (state.competitions.isEmpty) {
              return const Center(child: Text('no competitions'));
            }
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return index >= state.competitions.length
                    ? const BottomLoader()
                    : CompetitionListItem(
                        competition: state.competitions[index]);
              },
              itemCount: state.hasReachedMax
                  ? state.competitions.length
                  : state.competitions.length + 1,
              controller: _scrollController,
            );
          case CompetitionStatus.initial:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<CompetitionBloc>().add(CompetitionFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
