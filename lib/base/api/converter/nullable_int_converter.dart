/*
 * Copyright (C) 2024 Finharbor DOO. - All Rights Reserved
 *
 * Unauthorized copying or redistribution of this file in source and binary forms via any medium
 * is strictly prohibited.
 */

import "package:freezed_annotation/freezed_annotation.dart";

class NullableIntConverter implements JsonConverter<int, dynamic> {
  const NullableIntConverter();

  static int convertFromJson(dynamic json) {
    if (json == null) {
      throw Exception("Required field 'id' cannot be null");
    }
    if (json is int) {
      return json;
    }
    if (json is num) {
      return json.toInt();
    }
    if (json is String) {
      final parsed = int.tryParse(json);
      if (parsed != null) {
        return parsed;
      }
    }
    throw Exception(
      "Invalid value for 'id' field: $json (type: ${json.runtimeType})",
    );
  }

  static dynamic convertToJson(int object) => object;

  @override
  int fromJson(dynamic json) => NullableIntConverter.convertFromJson(json);

  @override
  dynamic toJson(int object) => NullableIntConverter.convertToJson(object);
}
