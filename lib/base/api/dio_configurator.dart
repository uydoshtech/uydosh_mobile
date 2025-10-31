/*
 * Copyright (C) 2024 Finharbor DOO. - All Rights Reserved
 *
 * Unauthorized copying or redistribution of this file in source and binary forms via any medium
 * is strictly prohibited.
 */

import "package:dio/dio.dart";

abstract interface class IDioConfigurator {
  Dio configure(
    Dio dio, {
    bool? useSentry,
    bool? useLogger,
    bool? useErrorInterceptor,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  });
}
