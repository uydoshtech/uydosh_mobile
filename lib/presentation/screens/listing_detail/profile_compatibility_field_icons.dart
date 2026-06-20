import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

/// Lifestyle field icons shared by compatibility UI and member profile tiles.
class ProfileCompatibilityFieldIcons {
  ProfileCompatibilityFieldIcons._();

  static IconData iconFor(String labelKey) {
    switch (labelKey) {
      case "wakeup_time":
        return Icons.wb_sunny;
      case "sleep_time":
      case "sleep_schedule":
        return Icons.bedtime;
      case "work":
      case "employed":
        return Icons.work;
      case "cleanliness":
        return Icons.cleaning_services;
      case "noise_level":
        return Icons.volume_up;
      case "sociability":
        return Icons.people;
      case "guests":
      case "guests_allowed":
        return Icons.group_add;
      case "smoking_preference":
        return Icons.smoking_rooms;
      case "alcohol_preference":
        return Icons.local_bar;
      case "cooking_habits":
        return Icons.restaurant;
      case "pets_preference":
        return Icons.pets;
      case "same_region":
      case "region":
        return Icons.location_on;
      case "language":
        return CupertinoIcons.globe;
      case "same_university":
      case "both_students":
      case "university":
        return Icons.school;
      default:
        return Icons.info_outline;
    }
  }
}
