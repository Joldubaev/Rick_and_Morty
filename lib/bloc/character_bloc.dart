import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:rick_and_morty/data/models/character.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rick_and_morty/data/repositories/character_repo.dart';

part 'character_bloc.freezed.dart';
part 'character_bloc.g.dart';
part 'character_event.dart';
part 'character_state.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState>
    with HydratedMixin {
  final CharacterRepo characterRepo;
  CharacterBloc({required this.characterRepo})
      : super(const CharacterState.loading()) {
    on<CharacterEventFetch>((event, emit) async {
      try {
        emit(const CharacterState.loading());
        Character characterLoaded = await characterRepo
            .getCharacter(event.page, event.name)
            .timeout(const Duration(seconds: 5));
        emit(CharacterState.loaded(characterLoaded: characterLoaded));
      } catch (_) {
        emit(const CharacterState.error());
        rethrow;
      }
    });
  }

  @override
  CharacterState? fromJson(Map<String, dynamic> json) =>
      CharacterState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(CharacterState state) => state.toJson();
}
