/*
 * Copyright (C) 2024 Finharbor DOO. - All Rights Reserved
 *
 * Unauthorized copying or redistribution of this file in source and binary forms via any medium
 * is strictly prohibited.
 */

import "package:freezed_annotation/freezed_annotation.dart";

class DateTimeConverter<T> implements JsonConverter<DateTime, T> {
  const DateTimeConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is int) {
      return DateTime.fromMicrosecondsSinceEpoch(json);
    } else if (json is String) {
      return DateTime.parse(json);
    } else if (json is DateTime) {
      return json;
    }
    throw Exception("Invalid value, expected int or DateTime");
  }

  @override
  T toJson(DateTime object) {
    if (T == String) return object.toIso8601String() as T;
    if (T == int) return object.microsecondsSinceEpoch as T;
    throw Exception("Invalid type, expected String or int");
  }
}
