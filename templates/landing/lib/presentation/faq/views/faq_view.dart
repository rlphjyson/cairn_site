import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/landing_actions.dart';
import '../../../core/presentation/landing_text.dart';
import '../../../core/presentation/layout.dart';
import '../../../core/presentation/widgets/content_view.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../domain/faq/models/faq_content.dart';

/// The FAQ: an accordion, with the heading beside it on desktop.
class FaqView extends StatelessWidget {
  /// Creates the view.
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) => ContentView<FaqContent>(
    loadingHeight: 560,
    builder: (BuildContext context, FaqContent content) =>
        _Faq(content: content),
  );
}

class _Faq extends StatefulWidget {
  const _Faq({required this.content});

  final FaqContent content;

  @override
  State<_Faq> createState() => _FaqState();
}

class _FaqState extends State<_Faq> {
  // Purely visual state (which rows are open), so it lives in the widget.
  Set<String> _expanded = <String>{};

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool wide = LandingViewport.of(context).isExpanded;
    final FaqContent content = widget.content;
    final ValueChanged<String> open = LandingActions.of(context).open;

    final Widget accordion = CairnAccordion(
      expanded: _expanded,
      onChanged: (Set<String> next) => setState(() => _expanded = next),
      items: <CairnAccordionItem>[
        for (final FaqItem item in content.items)
          CairnAccordionItem(
            value: item.id,
            title: Text(
              item.question,
              style: landingText(
                theme,
                CairnTypography.base,
                weight: CairnTypography.medium,
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.only(bottom: CairnSpacing.s4),
              child: Text(
                item.answer,
                style: landingText(
                  theme,
                  CairnTypography.base,
                  color: theme.mutedForeground,
                  height: 1.65,
                ),
              ),
            ),
          ),
      ],
    );

    final Widget contact = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: CairnSpacing.s1p5,
      children: <Widget>[
        Text(
          content.contactText,
          style: landingText(
            theme,
            CairnTypography.sm,
            color: theme.mutedForeground,
          ),
        ),
        CairnLink(
          onPressed: () => open(content.contact.href),
          child: Text(content.contact.label),
        ),
      ],
    );

    return SectionFrame(
      tinted: true,
      child: Reveal(
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: CairnSpacing.s16,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SectionHeader(
                          centered: false,
                          eyebrow: content.eyebrow,
                          title: content.title,
                          subtitle: content.subtitle,
                        ),
                        const SizedBox(height: CairnSpacing.s6),
                        contact,
                      ],
                    ),
                  ),
                  Expanded(flex: 7, child: accordion),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SectionHeader(
                    eyebrow: content.eyebrow,
                    title: content.title,
                    subtitle: content.subtitle,
                  ),
                  const SizedBox(height: CairnSpacing.s10),
                  accordion,
                  const SizedBox(height: CairnSpacing.s8),
                  Center(child: contact),
                ],
              ),
      ),
    );
  }
}
