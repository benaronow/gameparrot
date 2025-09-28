import 'dart:convert';
import 'package:gameparrot/config.dart';
import 'package:gameparrot/models/user.dart';
import 'package:http/http.dart' as http;

class UserDataService {
  static Future<User> getCurrentUser(String? uid) async {
    final uri = Uri.parse('${Config.httpUrl}/currentUser?uid=${uid ?? ''}');

    final userResponse = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    return User.fromJson(jsonDecode(userResponse.body));
  }

  static void handleStatus(
    List<User> status,
    Function(List<User>) updateUsers,
  ) {
    updateUsers(status);
  }
}
