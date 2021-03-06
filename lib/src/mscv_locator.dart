part of msvc_locator;

class MsvcLocator {
  Map<String, String> _scripts;

  Map<String, String> _versions;

  MsvcLocator(int bits) {
    if (bits != 32 && bits != 64) {
      throw new ArgumentError('bits: $bits');
    }

    _versions = <String, String>{};
    _scripts = <String, String>{};
    _getEnvironmentScripts(bits);
    _versions = new UnmodifiableMapView<String, String>(_versions);
    _scripts = new UnmodifiableMapView<String, String>(_scripts);
  }

  Map<String, String> get scripts => _scripts;

  Map<String, String> get versions => _versions;

  void _getEnvironmentScripts(int bits) {
    var key = r'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio';
    if (SysInfo.kernelBitness == 64) {
      key = r'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\VisualStudio';
    }

    var reg = _WindowsRegistry.queryAllKeys(key);
    if (reg == null) {
      return;
    }

    var regVC7 = reg[r'SxS\VC7'];
    if (regVC7 == null) {
      return;
    }

    var versions = <String, String>{};
    for (var version in reg.keys.keys) {
      if (regVC7.values.containsKey(version)) {
        versions[version] = regVC7.values[version].value;
      }
    }

    if (versions.length == 0) {
      return;
    }

    var scriptName = 'vcvars32.bat';
    switch (bits) {
      case 64:
        switch (SysInfo.kernelArchitecture) {
          case "AMD64":
            scriptName = 'amd64\\vcvars64.bat';
            break;
          case "IA64":
            scriptName = 'ia64\\vcvars64.bat';
            break;
          default:
            return null;
        }

        break;
    }

    for (var version in versions.keys) {
      var vc7Path = versions[version];
      try {
        var file = new File('${vc7Path}bin\\$scriptName');
        if (file.existsSync()) {
          _scripts[version] = file.path;
          _versions[version] = vc7Path;
        }

      } catch (s) {
      }
    }
  }

  Map<String, String> getEnvironment(String version) {
    if (version == null) {
      throw new ArgumentError.notNull("version");
    }

    var script = _scripts[version];
    if (script == null) {
      return null;
    }

    var executable = '"$script" && set';
    var result = Process.runSync(executable, []);
    if (result != null && result.exitCode == 0) {
      var env = new Map<String, String>();
      var exp = new RegExp(r'(^\S+)=(.*)$', multiLine: true);
      var matches = exp.allMatches(result.stdout);
      for (var match in matches) {
        env[match.group(1)] = match.group(2);
      }

      return env;
    }

    return null;
  }
}
