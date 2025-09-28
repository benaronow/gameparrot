class Config {
  // Use your computer's IP address when running on a physical device
  // ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'
  static const String apiHost = 'localhost:8080';
  static const bool useSSL = false;

  static String get wsUrl => '${useSSL ? 'wss' : 'ws'}://$apiHost/ws';
  static String get httpUrl => '${useSSL ? 'https' : 'http'}://$apiHost';
}
