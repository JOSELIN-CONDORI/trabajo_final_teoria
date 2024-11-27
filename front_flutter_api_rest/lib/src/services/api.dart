class ConfigApi {
  static const String appName = "FRANCHESCAS";
  static const String apiURL = "192.168.56.1:9090";
  static String buildUrl(String endpoint) {
    return 'http://$apiURL$endpoint';
  }
}
