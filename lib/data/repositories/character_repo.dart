import 'dart:convert';

import 'package:rick_and_morty/data/models/character.dart';
import 'package:http/http.dart' as http;

class CharacterRepo {
  final baseUrl = 'https://rickandmortyapi.com/api/character';

  Future<Character> getCharacter(int page, String name) async {
    try {
      final url = "$baseUrl?name=$name&page=$page";
      var response = await http.get(Uri.parse(url));
      // print(response.body['info'][]);
      var jsonResult = json.decode(response.body);
      return Character.fromJson(jsonResult);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
