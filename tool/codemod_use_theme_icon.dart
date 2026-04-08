import "dart:io";

final _dartFile = RegExp(r"\.dart$");

void main() {
  final root = Directory.current;
  final libDir = Directory("${root.path}/lib");
  if (!libDir.existsSync()) {
    stderr.writeln("Expected to run from repo root (lib/ not found).");
    exitCode = 2;
    return;
  }

  final files = <File>[];
  for (final ent in libDir.listSync(recursive: true, followLinks: false)) {
    if (ent is! File) continue;
    if (!_dartFile.hasMatch(ent.path)) continue;
    files.add(ent);
  }

  var changed = 0;
  for (final f in files) {
    final before = f.readAsStringSync();
    var after = before;

    after = after.replaceAll("const UydoshIcon(", "const ThemeIcon(");
    after = after.replaceAll("UydoshIcon(", "ThemeIcon(");

    // Swap imports if present.
    after = after.replaceAll(
      'import "package:uy_dosh/presentation/widgets/common/uydosh_icon.dart";',
      'import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";',
    );

    if (after == before) continue;

    // If ThemeIcon is used but not imported, prefer the barrel if it exists.
    if (after.contains("ThemeIcon(") &&
        !after.contains('presentation/widgets/common/theme_icon.dart') &&
        !after.contains('presentation/widgets/common/index.dart')) {
      after = _addImport(after);
    }

    if (after != before) {
      f.writeAsStringSync(after);
      changed++;
    }
  }

  stdout.writeln("Updated $changed Dart files.");
}

String _addImport(String src) {
  const importLine =
      'import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";\n';

  final lines = src.split("\n");
  var insertAt = -1;
  for (var i = 0; i < lines.length; i++) {
    final l = lines[i];
    if (l.startsWith("import ")) {
      insertAt = i;
      continue;
    }
    if (l.trim().isEmpty) continue;
    break;
  }

  if (insertAt >= 0) {
    lines.insert(insertAt + 1, importLine.trimRight());
    return lines.join("\n");
  }

  lines.insert(0, importLine.trimRight());
  return lines.join("\n");
}

