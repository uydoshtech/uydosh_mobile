import Foundation
import SceneKit

/// Stores the editable floor plan as source of truth and emits display/regeneration updates.
final class FloorPlanStateManager {
  private(set) var editableModel: EditableFloorPlanModel?
  var objectLabels: FloorPlanObjectLabels = .englishFallback

  var onDisplayModelUpdated: ((FloorPlanModel) -> Void)?
  var onRequires3DRegeneration: ((EditableFloorPlanModel) -> Void)?

  func importScan(
    scene: SCNScene,
    metrics: RoomScanMetricsResult,
    sourceScanId: String,
    worldPlusXTrueBearingDeg: Double? = nil,
    northCorrectionDeg: Double = 0
  ) {
    editableModel = RoomPlanToEditableModelMapper.map(
      scene: scene,
      metrics: metrics,
      sourceScanId: sourceScanId,
      worldPlusXTrueBearingDeg: worldPlusXTrueBearingDeg,
      northCorrectionDeg: northCorrectionDeg
    )
    publishDisplayUpdate()
  }

  var northCorrectionDeg: Double {
    editableModel?.northCorrectionDeg ?? 0
  }

  var scanWorldPlusXBearingDeg: Double? {
    editableModel?.scanWorldPlusXBearingDeg
  }

  func previewNorthCorrection(_ correctionDeg: Double) {
    guard var model = editableModel else { return }
    FloorPlanNorthOrientation.applyTrueNorth(to: &model, correctionDeg: correctionDeg)
    editableModel = model
    publishDisplayUpdate()
  }

  func applyNorthCorrection(_ correctionDeg: Double) {
    previewNorthCorrection(correctionDeg)
  }

  func resetNorthCorrection() {
    applyNorthCorrection(0)
  }

  func displayModel() -> FloorPlanModel? {
    guard let editableModel else { return nil }
    return EditableFloorPlanProjector.project(editableModel, objectLabels: objectLabels)
  }

  func annotation(for dimensionId: UUID) -> EditableDimensionAnnotation? {
    editableModel?.dimensionAnnotations.first { $0.id == dimensionId }
  }

  func applyDimensionEdit(annotation: EditableDimensionAnnotation, newValueMeters: Double) {
    guard var model = editableModel else { return }
    switch annotation.type {
    case .overallWidth:
      model = FloorPlanResizeService.applyWidthChange(to: model, newWidth: newValueMeters)
    case .overallLength:
      model = FloorPlanResizeService.applyLengthChange(to: model, newLength: newValueMeters)
    case .wallSegmentLength:
      // Editing a wall resizes it together with its parallel wall, keeping the room rectangular.
      switch annotation.target.editType {
      case .resizeWidth:
        model = FloorPlanResizeService.applyWidthChange(to: model, newWidth: newValueMeters)
      case .resizeLength:
        model = FloorPlanResizeService.applyLengthChange(to: model, newLength: newValueMeters)
      case .wallSegmentLength:
        return
      }
    }
    editableModel = model
    publishDisplayUpdate()
    onRequires3DRegeneration?(model)
  }

  func clear() {
    editableModel = nil
  }

  private func publishDisplayUpdate() {
    guard let display = displayModel() else { return }
    onDisplayModelUpdated?(display)
  }
}
