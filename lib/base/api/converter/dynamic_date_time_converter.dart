/*
 * Copyright (C) 2024 Finharbor DOO. - All Rights Reserved
 *
 * Unauthorized copying or redistribution of this file in source and binary forms via any medium
 * is strictly prohibited.
 */

import "package:freezed_annotation/freezed_annotation.dart";
import "package:intl/intl.dart";

const _reverseDateFormat = "dd-MM-yyyy";

class DynamicDateTimeConverter implements JsonConverter<DateTime, Object> {
  const DynamicDateTimeConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    } else if (json is String) {
      final value = int.tryParse(json);
      if (value != null) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else {
        return DateTime.tryParse(json) ??
            DateFormat(_reverseDateFormat).parse(json);
      }
    } else if (json is DateTime) {
      return json;
    }
    throw Exception("Invalid value, expected int or String, got $json");
  }

  @override
  Object toJson(DateTime object) {
    return object.toUtc().toIso8601String();
  }
}
