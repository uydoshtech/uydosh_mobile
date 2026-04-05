import "dart:io";
import "dart:typed_data";

import "package:flutter/foundation.dart" show kIsWeb;
import "package:path_provider/path_provider.dart";
import "package:share_plus/share_plus.dart";

Future<void> saveExportBytes(Uint8List bytes, String filename) async {
  if (kIsWeb) {
    throw UnsupportedError("Use web implementation");
  }
  final dir = await getTemporaryDirectory();
  final path = "${dir.path}/$filename";
  final file = File(path);
  await file.writeAsBytes(bytes, flush: true);
  await SharePlus.instance.share(
    ShareParams(files: [XFile(path)], subject: filename),
  );
}
