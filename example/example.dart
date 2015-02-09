import "dart:io";

import "package:msvc_locator/msvc_locator.dart";

void main() {
  for (var bits in <int>[32, 64]) {
    var msvc = new MsvcLocator(bits);
    var versions = msvc.versions;
    print("===========================");
    print("Found $bits-bits versions:");
    print("---------------------------");
    for (var version in versions.keys) {
      print("Microsoft Visual Studio C++ Compiler $version: ${versions[version]}");
    }
  }

  for (var bits in <int>[32, 64]) {
    var msvc = new MsvcLocator(bits);
    var versions = msvc.versions;
    print("===========================");
    print("Environment varibales for $bits-bits versions:");
    for (var version in versions.keys) {
      print("===========================");
      print("Microsoft Visual Studio C++ Compiler $version");
      print("---------------------------");
      var env = msvc.getEnvironment(version);
      var map = _difference(Platform.environment, env);
      for (var key in map.keys) {
        print("$key=${map[key]}");
      }
    }
  }
}

Map<String, String> _difference(Map<String, String> base, Map<String, String> sub) {
  var result = <String, String>{};
  for (var key in sub.keys) {
    var value = sub[key];
    if (!base.containsKey(key)) {
      result[key] = value;
    } else if (base[key] != value) {
      result[key] = value;
    }
  }

  return result;
}
