import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";

/// A compact reorderable grid optimised for the listing photo tiles
/// (3-column, max ~5 items). Each tile becomes a [LongPressDraggable] and
/// a [DragTarget]; dropping onto another tile inserts the dragged item at
/// that tile's slot (shifting the rest). No dependency on external packages.
///
/// The grid is sized the same way as a regular `GridView.builder`
/// (`SliverGridDelegateWithFixedCrossAxisCount`), and the surrounding
/// layout does not need to change.
class ReorderablePhotoGrid extends StatefulWidget {
  const ReorderablePhotoGrid({
    required this.itemCount,
    required this.itemBuilder,
    required this.onReorder,
    required this.keyExtractor,
    super.key,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    this.childAspectRatio = 1,
    this.canDrag,
  });

  final int itemCount;

  /// Builds the tile for [index]. `isDragging` is true while the tile is
  /// being carried (use it to dim the source slot).
  final Widget Function(BuildContext context, int index, bool isDragging)
      itemBuilder;

  /// Called when the user drops a tile. [from]/[to] are indexes in the
  /// current visible list; callers should perform a standard `removeAt` +
  /// `insert` to reorder their source list.
  final void Function(int from, int to) onReorder;

  /// Stable identifier for each tile (e.g. file path or photo id). Used as
  /// Draggable/DragTarget key + to keep Flutter's element tree stable across
  /// reorders.
  final Object Function(int index) keyExtractor;

  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  /// Optional predicate to disable dragging on a specific tile (e.g. while
  /// it's uploading). Defaults to always-draggable.
  final bool Function(int index)? canDrag;

  @override
  State<ReorderablePhotoGrid> createState() => _ReorderablePhotoGridState();
}

class _ReorderablePhotoGridState extends State<ReorderablePhotoGrid> {
  int? _draggingIndex;
  int? _hoverIndex;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return _buildTile(context, index);
      },
    );
  }

  Widget _buildTile(BuildContext context, int index) {
    final key = ValueKey(widget.keyExtractor(index));
    final canDrag = widget.canDrag?.call(index) ?? true;
    final isDragging = _draggingIndex == index;
    final isHover = _hoverIndex == index && _draggingIndex != index;

    final tile = widget.itemBuilder(context, index, isDragging);

    // Tile as drop target. When a drag token (the source index) is dropped on
    // this tile, we reorder.
    final dropTarget = DragTarget<int>(
      onWillAcceptWithDetails: (details) {
        if (details.data == index) return false;
        setState(() => _hoverIndex = index);
        return true;
      },
      onLeave: (_) {
        if (_hoverIndex == index) {
          setState(() => _hoverIndex = null);
        }
      },
      onAcceptWithDetails: (details) {
        final from = details.data;
        final to = index;
        setState(() {
          _hoverIndex = null;
          _draggingIndex = null;
        });
        if (from != to) {
          HapticFeedbackUtils.selectionClick();
          widget.onReorder(from, to);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isHover
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Opacity(
            opacity: isDragging ? 0.35 : 1.0,
            child: tile,
          ),
        );
      },
    );

    if (!canDrag) return KeyedSubtree(key: key, child: dropTarget);

    // Feedback widget shown under the finger. We give it a fixed size matching
    // the tile; LayoutBuilder computes that from the grid constraints.
    return KeyedSubtree(
      key: key,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return LongPressDraggable<int>(
            data: index,
            delay: const Duration(milliseconds: 220),
            hapticFeedbackOnStart: false,
            onDragStarted: () {
              HapticFeedbackUtils.impact();
              setState(() => _draggingIndex = index);
            },
            onDraggableCanceled: (_, __) {
              setState(() {
                _draggingIndex = null;
                _hoverIndex = null;
              });
            },
            onDragEnd: (_) {
              if (!mounted) return;
              setState(() {
                _draggingIndex = null;
                _hoverIndex = null;
              });
            },
            feedback: _DragFeedback(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              child: widget.itemBuilder(context, index, false),
            ),
            // Keep the grid slot geometry stable while dragging. `SizedBox.shrink`
            // lets the cell report a zero footprint so siblings can overlap the
            // gap (especially noticeable after reordering to make another photo
            // primary).
            childWhenDragging: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),
            child: dropTarget,
          );
        },
      ),
    );
  }
}

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.size, required this.child});

  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Transform.scale(
        scale: 1.06,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
