import Foundation
#if canImport(RoomPlan)
import RoomPlan
#endif

/// Device capability check for Apple RoomPlan (requires LiDAR).
public enum RoomPlanSupport {
    public static var isSupported: Bool {
        #if targetEnvironment(simulator)
        // The simulator has no LiDAR; allow forcing "supported" so the
        // placeholder flow can be exercised end to end from Xcode.
        if ProcessInfo.processInfo.environment["SCAN_CLIP_FORCE_SUPPORTED"] == "1" {
            return true
        }
        return false
        #elseif canImport(RoomPlan)
        return RoomCaptureSession.isSupported
        #else
        return false
        #endif
    }
}
