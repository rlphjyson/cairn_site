import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../../../common/constants/chat_limits.dart';
import '../../../core/presentation/chat_text.dart';
import '../../../core/presentation/widgets/icon_action.dart';
import '../../../domain/messages/models/message.dart';
import '../../../domain/messages/use_cases/send_message.dart';

/// The bar at the bottom of a thread: attach, a multiline field that grows to
/// five lines, and a send button that stays disabled until there is something
/// to send. While you are answering a message, its quote sits above the field.
class MessageComposer extends StatefulWidget {
  /// Creates the composer.
  const MessageComposer({
    super.key,
    required this.onSend,
    required this.onAttach,
    required this.onCancelReply,
    this.replyTo,
    this.replyAuthor,
  });

  /// Called with the text when the person sends.
  final ValueChanged<String> onSend;

  /// Called when the attach button is pressed.
  final VoidCallback onAttach;

  /// Called when the reply quote is dismissed.
  final VoidCallback onCancelReply;

  /// The message being answered, if any.
  final Message? replyTo;

  /// Who wrote [replyTo].
  final String? replyAuthor;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void didUpdateWidget(MessageComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.replyTo != null && widget.replyTo?.id != oldWidget.replyTo?.id) {
      _focus.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _canSend => SendMessage.canSend(_controller.text);

  void _send() {
    if (!_canSend) return;
    widget.onSend(_controller.text);
    _controller.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Message? reply = widget.replyTo;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.background,
        border: Border(top: BorderSide(color: theme.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (reply != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 0, 4),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: theme.primary, width: 3),
                          ),
                        ),
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Replying to ${widget.replyAuthor ?? 'message'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: chatText(
                                theme,
                                theme.textStyle(CairnTypography.xs),
                                weight: CairnTypography.semibold,
                              ),
                            ),
                            Text(
                              reply.preview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: chatText(
                                theme,
                                theme.textStyle(CairnTypography.xs),
                                color: theme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconAction(
                      icon: Icons.close,
                      label: 'Cancel reply',
                      onPressed: widget.onCancelReply,
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                IconAction(
                  icon: Icons.add,
                  label: 'Attach',
                  onPressed: widget.onAttach,
                ),
                Expanded(
                  child: CairnTextarea(
                    controller: _controller,
                    focusNode: _focus,
                    placeholder: 'Message',
                    semanticLabel: 'Message',
                    autoGrow: false,
                    minLines: 1,
                    maxLines: ChatLimits.composerMaxLines,
                  ),
                ),
                IconAction(
                  icon: Icons.send,
                  label: 'Send message',
                  variant: CairnButtonVariant.primary,
                  onPressed: _canSend ? _send : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
