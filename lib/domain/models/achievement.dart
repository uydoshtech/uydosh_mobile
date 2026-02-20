import "package:flutter/material.dart";

/// Represents a gamification achievement.
@immutable
class Achievement {
  const Achievement({
    required this.id,
    required this.key,
    required this.icon,
    this.category = AchievementCategory.general,
    this.isMajor = false,
  });

  final String id;
  final String key;
  final IconData icon;
  final AchievementCategory category;
  final bool isMajor;
}

enum AchievementCategory {
  onboarding,
  profile,
  browsing,
  listings,
  messaging,
  engagement,
  milestone,
  general,
}
