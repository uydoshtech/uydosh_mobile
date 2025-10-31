/*
 * Copyright (C) 2024 Finharbor DOO. - All Rights Reserved
 *
 * Unauthorized copying or redistribution of this file in source and binary forms via any medium
 * is strictly prohibited.
 */

import "package:decimal/decimal.dart";
import "package:freezed_annotation/freezed_annotation.dart";

class NumDecimalConverter implements JsonConverter<Decimal, num> {
  const NumDecimalConverter();

  @override
  Decimal fromJson(dynamic json) {
    return Decimal.parse(json.toString());
  }

  @override
  num toJson(Decimal object) => num.parse(object.toJson());
}
