import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

/// Utility class for getting amenity icons based on amenity codes
class AmenityIconHelper {
  /// Returns the appropriate icon for a given amenity code
  static IconData getIcon(String code) {
    // Convert to lowercase for case-insensitive matching
    final normalizedCode = code.toLowerCase();

    switch (normalizedCode) {
      case "wifi":
        return Icons.wifi;
      case "parking":
        return Icons.local_parking;
      case "bed":
        return CupertinoIcons.bed_double;
      case "air_conditioning":
        return Icons.ac_unit;
      case "tv":
        return Icons.tv;
      case "microwave":
        return Icons.microwave;
      case "washing_machine":
        return Icons.local_laundry_service;
      case "refrigerator":
        return Icons.kitchen; // 🧊 Refrigerator icon
      case "gas_stove":
        return Icons.local_fire_department; // 🔥 Gas stove icon
      case "stove":
        return Icons.local_fire_department; // 🔥 Alternative stove icon
      case "oven":
        return Icons.local_dining; // 🍽️ Oven icon
      case "furniture":
        return Icons.chair;
      case "internet":
        return Icons.wifi;
      case "kitchen_appliances":
        return Icons.kitchen;
      case "shower":
        return Icons.shower;
      case "pets":
        return Icons.pets;
      case "no_smoking":
        return Icons.smoke_free;
      default:
        return Icons.check;
    }
  }

  /// Returns a list of all supported amenity codes
  static List<String> getSupportedCodes() {
    return [
      "wifi",
      "parking",
      "bed",
      "air_conditioning",
      "tv",
      "microwave",
      "washing_machine",
      "refrigerator",
      "gas_stove",
      "stove",
      "oven",
      "furniture",
      "internet",
      "kitchen_appliances",
      "shower",
      "pets",
      "no_smoking",
    ];
  }

  /// Checks if an amenity code has a specific icon (not default checkmark)
  static bool hasSpecificIcon(String code) {
    return getSupportedCodes().contains(code);
  }
}
