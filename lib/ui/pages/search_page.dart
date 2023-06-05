import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rick_and_morty/bloc/character_bloc.dart';
import 'package:rick_and_morty/data/models/character.dart';
import 'package:rick_and_morty/ui/widgets/custom_list_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Character _currentCharacter;
  List<Result> _currentResult = [];
  int _currentPage = 1;
  String _currentSerchStr = '';
  final RefreshController refreshController = RefreshController();
  bool isPagination = false;
  Timer? searchDebounce;

  final _storage = HydratedBloc.storage;

  @override
  void initState() {
    if (_storage.runtimeType.toString().isEmpty) {
      if (_currentResult.isEmpty) {
        context
            .read<CharacterBloc>()
            .add(const CharacterEvent.fetch(name: '', page: 1));
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CharacterBloc>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(right: 16, left: 16, top: 15, bottom: 15),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromRGBO(86, 86, 86, 0.8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              hintText: 'Search Name',
              hintStyle: const TextStyle(color: Colors.white),
            ),
            onChanged: (value) {
              _currentPage = 1;
              _currentResult = [];
              _currentSerchStr = value;
              searchDebounce?.cancel();
              searchDebounce = Timer(const Duration(milliseconds: 500), () {
                context.read<CharacterBloc>().add(
                      CharacterEvent.fetch(
                        page: _currentPage,
                        name: value,
                      ),
                    );
              });
            },
          ),
        ),
        Expanded(
          child: state.when(
              loading: () {
                // if (!isPagination) {
                return const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      SizedBox(width: 10),
                      Text('Loaded ...'),
                    ],
                  ),
                );
                // } else {
                //   return _customListView(_currentResult);
                // }
              },
              loaded: (characterLoaded) {
                _currentCharacter = characterLoaded;
                if (isPagination) {
                  _currentResult.addAll(_currentCharacter.results);
                  refreshController.loadComplete();
                  isPagination = false;
                } else {
                  _currentResult = _currentCharacter.results;
                }
                return _currentResult.isNotEmpty
                    ? _customListView(_currentResult)
                    : const SizedBox();
              },
              error: () => const Text('Nothing found ...')),
        ),
      ],
    );
  }

  Widget _customListView(List<Result> currentResult) {
    return SmartRefresher(
      controller: refreshController,
      enablePullUp: true,
      enablePullDown: false,
      onLoading: () {
        isPagination = true;
        _currentPage++;
        if (_currentPage <= _currentCharacter.info.pages) {
          context.read<CharacterBloc>().add(
              CharacterEvent.fetch(name: _currentSerchStr, page: _currentPage));
        } else {
          refreshController.loadNoData();
        }
      },
      child: ListView.separated(
          separatorBuilder: (_, index) => const SizedBox(height: 5),
          shrinkWrap: true,
          itemCount: currentResult.length,
          itemBuilder: (context, index) {
            final result = currentResult[index];
            return Padding(
                padding: const EdgeInsets.only(
                    right: 16, left: 16, top: 3, bottom: 3),
                child: CustomListTile(
                  result: result,
                ));
          }),
    );
  }
}
