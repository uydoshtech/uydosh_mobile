import "package:flutter/widgets.dart";

bool get isIOSDevice => false;

/// Non-iOS / web stub: never a phone form factor for 3D badge purposes.
bool isIPhoneFormFactor(BuildContext context) => false;
