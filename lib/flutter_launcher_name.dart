library flutter_launcher_name;

import 'dart:io';
import 'package:args/args.dart';
import 'package:flutter_launcher_name/android.dart' as android;
import 'package:flutter_launcher_name/constants.dart' as constants;
import 'package:flutter_launcher_name/ios.dart' as ios;
import 'package:yaml/yaml.dart';
const String fileOption = 'file';
const String defaultConfigFile = 'pubspec.yaml';

exec(List<String> arguments) {
  final ArgParser parser = ArgParser(allowTrailingOptions: true);
  parser.addOption(fileOption, abbr: 'f', help: 'Config file (default: $defaultConfigFile)');
  final ArgResults argResults = parser.parse(arguments);

  final newName = loadConfigFileFromArgResults(argResults)['name'];

  android.overwriteAndroidManifest(newName);
  ios.overwriteInfoPlist(newName);

  print('exit');
}

Map<String, dynamic> loadConfigFileFromArgResults(ArgResults argResults) {
  final String configFile = argResults[fileOption];

  if (configFile != null && configFile != defaultConfigFile) {
    try {
      return loadConfigFile(configFile);
    } catch (e) {
      stderr.writeln(e);

      return null;
    }
  }

  try {
    return loadConfigFile(defaultConfigFile);
  } catch (e) {
    if (configFile == null) {
      try {
        return loadConfigFile('pubspec.yaml');
      } catch (_) {}
    }

  }

  return null;
}

Map<String, dynamic> loadConfigFile(configFile) {
  final File file = File(configFile);
  final String yamlString = file.readAsStringSync();
  final Map yamlMap = loadYaml(yamlString);

  if (yamlMap == null || !(yamlMap[constants.yamlKey] is Map)) {
    throw new Exception('flutter_launcher_name was not found');
  }

  // yamlMap has the type YamlMap, which has several unwanted sideeffects
  final Map<String, dynamic> config = <String, dynamic>{};
  for (MapEntry<dynamic, dynamic> entry in yamlMap[constants.yamlKey].entries) {
    config[entry.key] = entry.value;
  }

  return config;
}
