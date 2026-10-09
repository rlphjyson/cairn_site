import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../../../common/constants/reaction_emoji.dart';
import '../../../core/presentation/widgets/icon_action.dart';
import '../../../domain/messages/models/message.dart';
import '../../../domain/messages/models/reaction.dart';

/// What the person picked in the message sheet.
enum MessageAction {
  /// Quote the message in the composer.
  reply,

  /// Copy its text.
  copy,

  /// Remove it from this device.
  delete,
}

/// The result of the sheet: an action, or a reaction emoji.
class MessageChoice {
  /// An action.
  const MessageChoice.action(MessageAction this.action) : emoji = null;

  /// A reaction.
  const MessageChoice.react(String this.emoji) : action = null;

  /// The action, or `null` for a reaction.
  final MessageAction? action;

  /// The emoji, or `null` for an action.
  final String? emoji;
}

/// Opens the long-press sheet of [message]: six quick reactions, then Reply,
/// Copy text (when there is text) and Delete for me.
Future<MessageChoice?> showMessageActions(
  BuildContext context, {
  required Message message,
  required String userId,
}) => showCairnSheet<MessageChoice>(
  context: context,
  side: CairnSheetSide.bottom,
  builder: (BuildContext sheetContext) {
    void choose(MessageChoice choice) => Navigator.of(sheetContext).pop(choice);
    return CairnSheet(
      side: CairnSheetSide.bottom,
      title: const Text('Message'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: <Widget>[
                for (final String emoji in reactionEmoji)
                  IconAction.glyph(
                    glyph: Text(emoji, style: const TextStyle(fontSize: 20)),
                    label: 'React with $emoji',
                    variant:
                        message.reactions.any(
                          (Reaction r) =>
                              r.emoji == emoji && r.includes(userId),
                        )
                        ? CairnButtonVariant.secondary
                        : CairnButtonVariant.ghost,
                    onPressed: () => choose(MessageChoice.react(emoji)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CairnList(
            children: <Widget>[
              CairnListItem(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () =>
                    choose(const MessageChoice.action(MessageAction.reply)),
              ),
              if (message.text.trim().isNotEmpty)
                CairnListItem(
                  leading: const Icon(Icons.copy_outlined),
                  title: const Text('Copy text'),
                  onTap: () =>
                      choose(const MessageChoice.action(MessageAction.copy)),
                ),
              CairnListItem(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete for me'),
                onTap: () =>
                    choose(const MessageChoice.action(MessageAction.delete)),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  },
);
