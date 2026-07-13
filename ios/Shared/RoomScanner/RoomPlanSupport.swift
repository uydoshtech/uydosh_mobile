import Foundation
#if canImport(RoomPlan)
import RoomPlan
#endif

/// Device capability check for Apple RoomPlan (requires LiDAR).
public enum RoomPlanSupport {
    /// Whether the scanning flow may proceed. On the simulator this can be
    /// forced with `SCAN_CLIP_FORCE_SUPPORTED=1` so the mocked flow can be
    /// exercised end to end from Xcode.
    public static var isSupported: Bool {
        #if targetEnvironment(simulator)
        return ProcessInfo.processInfo.environment["SCAN_CLIP_FORCE_SUPPORTED"] == "1"
        #else
        return isHardwareSupported
        #endif
    }

    /// True only when real RoomPlan capture can run (LiDAR present).
    /// Never overridden by environment variables.
    public static var isHardwareSupported: Bool {
        #if canImport(RoomPlan) && !targetEnvironment(simulator)
        return RoomCaptureSession.isSupported
        #else
        return false
        #endif
    }
}
