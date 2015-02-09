# mscv_locator
Helps locate installed Microsoft Visual Studio C++ compilers. Retrieves the environment variables for the specified version of the Microsoft C++ compiler.

Example:

```dart
import "dart:io";

import "package:mscv_locator/mscv_locator.dart";

void main() {
  for (var bits in <int>[32, 64]) {
    var msvc = new MsvcLocator(bits);
    var versions = msvc.versions;
    print("===========================");
    print("Found $bits-bits versions:");
    print("---------------------------");
    for (var version in versions) {
      print("Microsoft Visual Studio VC $version");
    }
  }

  for (var bits in <int>[32, 64]) {
    var msvc = new MsvcLocator(bits);
    var versions = msvc.versions;
    print("===========================");
    print("Environment varibales for $bits-bits versions:");
    for (var version in versions) {
      print("===========================");
      print("Microsoft Visual Studio VC $version");
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
```