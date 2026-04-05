// ignore: avoid_web_libraries_in_flutter
import "dart:html" as html;
import "dart:typed_data";

Future<void> saveExportBytes(Uint8List bytes, String filename) async {
  final blob = html.Blob(<Object>[bytes], "text/plain;charset=utf-8");
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute("download", filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
