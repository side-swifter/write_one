class PermissionService {
  // For now, always show camera permission page after login/verification
  // This ensures users are prompted for camera access
  static Future<String> getNextRoute() async {
    return '/camera-permission'; // Always go to camera permission page
  }
}
