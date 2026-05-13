/// Backend-aligned roles that may moderate listings/gigs (see `userRoles.ts`).
class ModerationStaffUtils {
  ModerationStaffUtils._();

  static bool isModerationStaff(String? role) =>
      role == "admin" || role == "moderator" || role == "manager";
}
