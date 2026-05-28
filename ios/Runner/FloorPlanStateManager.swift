import Foundation
import SceneKit

/// Stores the editable floor plan as source of truth and emits display/regeneration updates.
final class FloorPlanStateManager {
  private(set) var editableModel: EditableFloorPlanModel?

  var onDisplayModelUpdated: ((FloorPlanModel) -> Void)?
  var onRequires3DRegeneration: ((EditableFloorPlanModel) -> Void)?

  func importScan(
    scene: SCNScene,
    metrics: RoomScanMetricsResult,
    sourceScanId: String
  ) {
    editableModel = RoomPlanToEditableModelMapper.map(
      scene: scene,
      metrics: metrics,
      sourceScanId: sourceScanId
    )
    publishDisplayUpdate()
  }

  func displayModel() -> FloorPlanModel? {
    guard let editableModel else { return nil }
    return EditableFloorPlanProjector.project(editableModel)
  }

  func annotation(for dimensionId: UUID) -> EditableDimensionAnnotation? {
    editableModel?.dimensionAnnotations.first { $0.id == dimensionId }
  }

  func applyDimensionEdit(kind: DimensionEditKind, newValueMeters: Double) {
    guard var model = editableModel else { return }
    switch kind {
    case .overallWidth:
      model = FloorPlanResizeService.applyWidthChange(to: model, newWidth: newValueMeters)
    case .overallLength:
      model = FloorPlanResizeService.applyLengthChange(to: model, newLength: newValueMeters)
    case .wallSegmentLength:
      return
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
