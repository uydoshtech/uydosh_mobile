import "package:flutter/foundation.dart";
import "package:pretty_dio_logger/pretty_dio_logger.dart";

final prettyDioLogger = PrettyDioLogger(
  requestHeader: false,
  requestBody: false,
  responseBody: false,
  responseHeader: false,
  compact: true,
  maxWidth: 120,
  logPrint: (e) => debugPrint(e.toString()),
  enabled: kDebugMode,
);
