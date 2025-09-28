import 'dart:convert';

dynamic safeJsonDecode(String source) {
  try {
    return jsonDecode(source);
  } catch (e) {
    return source;
  }
}
