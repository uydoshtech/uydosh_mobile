import "package:flutter/material.dart";

/// Text selection menu without iOS “Scan Text” (Live Text / camera OCR).
///
/// Flutter’s default menus include [ContextMenuButtonType.liveTextInput], which
/// opens a camera-based capture flow and competes with normal caret placement,
/// selection, and typing.
///
/// When the caret is collapsed inside non-empty text, the platform or Flutter
/// toolbar often appears over earlier lines (e.g. a lone “Select all” chip) and
/// steals taps meant to reposition the caret. In that case we show no menu;
/// long-press still selects a word and opens the full menu; paste remains
/// available when the field is empty ([TextEditingValue.text] is empty).
Widget uydoshEditableContextMenuWithoutLiveText(
  BuildContext context,
  EditableTextState editableTextState,
) {
  final value = editableTextState.textEditingValue;
  if (value.selection.isCollapsed && value.text.isNotEmpty) {
    return const SizedBox.shrink();
  }

  final withoutLive = editableTextState.contextMenuButtonItems
      .where(
        (b) => b.type != ContextMenuButtonType.liveTextInput,
      )
      .toList();

  // Always use Flutter’s toolbar: the iOS system menu can sit in awkward
  // places over multiline fields and still intercepts touches.
  return AdaptiveTextSelectionToolbar.buttonItems(
    buttonItems: withoutLive,
    anchors: editableTextState.contextMenuAnchors,
  );
}
