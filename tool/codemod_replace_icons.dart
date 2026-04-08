import "dart:io";

final _dartFile = RegExp(r"\.dart$");
final _rawIconCall = RegExp(r"(?<![\w$])Icon\(");
final _rawConstIconCall = RegExp(r"(?<![\w$])const\s+Icon\(");

void main(List<String> args) {
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

    // Replace const Icon(…) and Icon(…) with UydoshIcon(…)
    after = after.replaceAll(_rawConstIconCall, "const UydoshIcon(");
    after = after.replaceAll(_rawIconCall, "UydoshIcon(");

    if (after == before) continue;

    // Add import if needed.
    if (after.contains("UydoshIcon(") &&
        !after.contains("uydosh_icon.dart") &&
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
      'import "package:uy_dosh/presentation/widgets/common/uydosh_icon.dart";\n';

  final lines = src.split("\n");

  // Find the last contiguous import line at the top of the file.
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

  // If there are no imports, insert after library/part directives if present.
  var headerEnd = 0;
  for (var i = 0; i < lines.length; i++) {
    final l = lines[i];
    if (l.startsWith("library ") || l.startsWith("part ") || l.startsWith("part of ")) {
      headerEnd = i + 1;
      continue;
    }
    if (l.trim().isEmpty) {
      headerEnd = i + 1;
      continue;
    }
    break;
  }
  lines.insert(headerEnd, importLine.trimRight());
  return lines.join("\n");
}

