import "dart:io" show Platform;

import "package:flutter/widgets.dart";

bool get isIOSDevice => Platform.isIOS;

/// True on iPhone-sized iOS devices (excludes typical iPad layouts via shortest side).
bool isIPhoneFormFactor(BuildContext context) {
  if (!Platform.isIOS) return false;
  return MediaQuery.sizeOf(context).shortestSide < 600;
}
