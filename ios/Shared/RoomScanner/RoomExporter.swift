import Foundation
#if canImport(RoomPlan)
import RoomPlan
#endif

/// Exports a captured room into the upload artifacts: USDZ + normalized JSON.
/// Files are written to a per-session temporary directory that survives until
/// `RoomScanArtifacts.cleanUp()` after a confirmed upload.
public enum RoomExporter {
    public enum ExportError: Error {
        case usdzExportFailed(String)
    }

    public static func sessionDirectory(scanSessionId: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("scan-\(scanSessionId)", isDirectory: true)
    }

    #if canImport(RoomPlan)
    @available(iOS 17.0, *)
    public static func export(_ room: CapturedRoom, scanSessionId: String) throws -> RoomScanArtifacts {
        let dir = sessionDirectory(scanSessionId: scanSessionId)
        // A retried scan overwrites the previous attempt's files.
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let usdzURL = dir.appendingPathComponent("room.usdz")
        do {
            // Parametric gives clean geometry; fall back to the raw mesh for
            // scans the parametric exporter cannot represent.
            try room.export(to: usdzURL, exportOptions: .parametric)
        } catch {
            do {
                try room.export(to: usdzURL, exportOptions: .mesh)
            } catch {
                throw ExportError.usdzExportFailed(String(describing: error))
            }
        }

        let normalized = RoomNormalizer.normalize(room)
        let jsonURL = try writeNormalizedJSON(normalized, to: dir)

        return RoomScanArtifacts(
            usdzURL: usdzURL,
            jsonURL: jsonURL,
            previewJPEGURL: nil,
            normalizedRoom: normalized,
            metadata: ScanUploadResult.Metadata(
                roomsCount: max(room.floors.count, 1),
                areaSquareMeters: normalized.estimatedFloorAreaSquareMeters,
                heightMeters: RoomNormalizer.estimatedHeightMeters(of: room)
            )
        )
    }
    #endif

    public static func writeNormalizedJSON(_ room: NormalizedRoom, to directory: URL) throws -> URL {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let jsonURL = directory.appendingPathComponent("room.json")
        try encoder.encode(room).write(to: jsonURL, options: .atomic)
        return jsonURL
    }

    /// Attaches a JPEG preview snapshot (taken on the review screen) to the
    /// artifacts. Best effort — failures leave the preview absent.
    public static func writePreview(jpegData: Data, for artifacts: RoomScanArtifacts) -> RoomScanArtifacts {
        var updated = artifacts
        let url = artifacts.usdzURL.deletingLastPathComponent().appendingPathComponent("preview.jpg")
        do {
            try jpegData.write(to: url, options: .atomic)
            updated.previewJPEGURL = url
        } catch {
            updated.previewJPEGURL = nil
        }
        return updated
    }
}
