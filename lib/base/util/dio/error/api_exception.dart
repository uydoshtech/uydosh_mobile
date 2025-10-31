/*
 * Copyright (C) 2024 Finharbor DOO. - All Rights Reserved
 *
 * Unauthorized copying or redistribution of this file in source and binary forms via any medium
 * is strictly prohibited.
 */

import "package:freezed_annotation/freezed_annotation.dart";

part "api_exception.g.dart";

@JsonSerializable()
class ApiException implements Exception {
  const ApiException({
    required this.status,
    required this.message,
    required this.traceId,
  });

  factory ApiException.fromJson(Map<String, dynamic> json) =>
      _$ApiExceptionFromJson(json);

  final String status;
  final String message;
  final String traceId;

  @override
  String toString() {
    return "ApiException(status: $status, message: $message, traceId: $traceId)";
  }
}
