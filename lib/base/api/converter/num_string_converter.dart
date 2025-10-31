/*
 * Copyright (C) 2024 Finharbor DOO. - All Rights Reserved
 *
 * Unauthorized copying or redistribution of this file in source and binary forms via any medium
 * is strictly prohibited.
 */

import "package:freezed_annotation/freezed_annotation.dart";

class NumStringConverter implements JsonConverter<String, num> {
  const NumStringConverter();

  @override
  String fromJson(dynamic json) {
    if (json is num) {
      return json.toString();
    } else if (json is String) {
      return json;
    }
    throw Exception("Invalid value, expected num or string");
  }

  @override
  num toJson(String object) => num.parse(object);
}
