import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

/// What the composer's attach button can add.
enum AttachOption {
  /// A picture from the library.
  photo(Icons.photo_outlined, 'Photo library'),

  /// A new picture from the camera.
  camera(Icons.photo_camera_outlined, 'Camera'),

  /// Any file.
  file(Icons.insert_drive_file_outlined, 'File'),

  /// The current place.
  location(Icons.place_outlined, 'Location');

  const AttachOption(this.icon, this.label);

  /// The row's glyph.
  final IconData icon;

  /// The row's text.
  final String label;
}

/// Opens the attach sheet and resolves to the chosen option, or `null` when it
/// is dismissed.
///
/// The template only offers the choices; picking the actual photo or file is
/// up to the host app (see "Attachments upload" in `doc/index.html`).
Future<AttachOption?> showAttachSheet(BuildContext context) =>
    showCairnSheet<AttachOption>(
      context: context,
      side: CairnSheetSide.bottom,
      builder: (BuildContext sheetContext) => CairnSheet(
        side: CairnSheetSide.bottom,
        title: const Text('Attach'),
        content: CairnList(
          children: <Widget>[
            for (final AttachOption option in AttachOption.values)
              CairnListItem(
                leading: Icon(option.icon),
                title: Text(option.label),
                onTap: () => Navigator.of(sheetContext).pop(option),
              ),
          ],
        ),
      ),
    );
