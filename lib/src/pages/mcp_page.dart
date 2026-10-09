import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/links.dart';
import '../app/site_theme.dart';
import '../widgets/code_block.dart';
import '../widgets/surfaces.dart';
import '../widgets/syntax.dart';

/// The Cairn UI MCP server: what it is, how to install it and connect it to an
/// editor, and what it offers.
///
/// The server lives in its own repository; this page is its documentation on
/// the site, with copy-paste configuration for each editor.
class McpPage extends StatefulWidget {
  /// Creates the page.
  const McpPage({super.key});

  /// The server's repository.
  static const String repo = 'https://github.com/rlphjyson/cairn_ui_mcp';

  @override
  State<McpPage> createState() => _McpPageState();
}

class _Editor {
  const _Editor(this.id, this.name, this.where, this.code, this.language);

  final String id;
  final String name;
  final String where;
  final String code;
  final CodeLanguage language;
}

const List<_Editor> _editors = <_Editor>[
  _Editor(
    'claude-code',
    'Claude Code',
    'Run once in your terminal',
    'claude mcp add cairn-ui -- cairn_ui_mcp',
    CodeLanguage.shell,
  ),
  _Editor(
    'claude-desktop',
    'Claude Desktop',
    'claude_desktop_config.json',
    '''
{
  "mcpServers": {
    "cairn-ui": { "command": "cairn_ui_mcp" }
  }
}''',
    CodeLanguage.plain,
  ),
  _Editor(
    'cursor',
    'Cursor',
    '.cursor/mcp.json (or ~/.cursor/mcp.json for every project)',
    '''
{
  "mcpServers": {
    "cairn-ui": { "command": "cairn_ui_mcp" }
  }
}''',
    CodeLanguage.plain,
  ),
  _Editor('vscode', 'VS Code', '.vscode/mcp.json (GitHub Copilot)', '''
{
  "servers": {
    "cairn-ui": { "type": "stdio", "command": "cairn_ui_mcp" }
  }
}''', CodeLanguage.plain),
  _Editor('windsurf', 'Windsurf', '~/.codeium/windsurf/mcp_config.json', '''
{
  "mcpServers": {
    "cairn-ui": { "command": "cairn_ui_mcp" }
  }
}''', CodeLanguage.plain),
  _Editor('zed', 'Zed', 'settings.json', '''
{
  "context_servers": {
    "cairn-ui": { "command": { "path": "cairn_ui_mcp", "args": [] } }
  }
}''', CodeLanguage.plain),
  _Editor('cline', 'Cline', 'MCP Servers, then Configure', '''
{
  "mcpServers": {
    "cairn-ui": { "command": "cairn_ui_mcp", "args": [], "disabled": false }
  }
}''', CodeLanguage.plain),
  _Editor('codex', 'Codex', '~/.codex/config.toml', '''
[mcp_servers.cairn-ui]
command = "cairn_ui_mcp"''', CodeLanguage.plain),
];

const List<(String, String)> _tools = <(String, String)>[
  (
    'cairn_overview',
    'Start here: what Cairn is, install, the conventions, what is available.',
  ),
  (
    'search_components',
    'Find components from plain words, each with an example: '
        '"confirm before deleting", "bottom navigation".',
  ),
  (
    'list_components',
    'Every component with its widgets, category and a one-line summary.',
  ),
  (
    'get_component',
    'The full reference: quick start, variant examples and the exact API: '
        'constructors, typed parameters, defaults, enums, helpers.',
  ),
  (
    'get_tokens',
    'Colours, radius, spacing, typography, shadows, motion and tones, with '
        'values and docs.',
  ),
  (
    'get_theme',
    'The CairnTheme API, light and dark setup, copyWith and the radius scale.',
  ),
  (
    'list_blocks / get_block',
    'Composed screens (login, dashboard shell, settings, pricing, team) with '
        'full source.',
  ),
  (
    'list_templates / get_template',
    'The five whole-app templates and how to mount each.',
  ),
  (
    'get_docs',
    'The guides: installation, quick start, theming, accessibility and more.',
  ),
];

const List<(String, String)> _skills = <(String, String)>[
  (
    'cairn-ui',
    'Any Flutter UI built with Cairn: look up components and tokens, follow '
        'the rules, set up the theme. Ships the full API of every component.',
  ),
  (
    'cairn-dashboard',
    'Dashboards and admin panels: shells, KPI cards, tables, loading, empty '
        'and error states, responsive layout.',
  ),
  (
    'cairn-charts',
    'Charts with fl_chart restyled through Cairn tokens, with five working '
        'recipes.',
  ),
  (
    'cairn-templates',
    'Starting a whole app from a template, rebranding it and connecting a '
        'backend.',
  ),
];

const List<String> _prompts = <String>[
  'Use Cairn UI to build a login screen with email, password and a social '
      'button.',
  'Which Cairn component should I use for a command palette? Show me its API.',
  'Make this screen use Cairn tokens instead of hard-coded colours.',
  'Set up a Cairn theme with a 4px radius and a blue primary, light and dark.',
  'Start from the Cairn dashboard template and rename it for my product.',
];

class _McpPageState extends State<McpPage> {
  String _editor = _editors.first.id;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool wide =
        MediaQuery.sizeOf(context).width >= SiteTokens.tabletBreakpoint;
    final TextStyle muted = theme
        .textStyle(CairnTypography.sm)
        .copyWith(color: theme.mutedForeground, height: 1.55);
    final _Editor editor = _editors.firstWhere((_Editor e) => e.id == _editor);

    Widget feature(String title, String body) => SizedBox(
      width: wide ? 330 : double.infinity,
      child: CairnCard(
        children: <Widget>[
          CairnCardHeader(title: Text(title)),
          CairnCardContent(child: Text(body, style: muted)),
        ],
      ),
    );

    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const PageHeading(
            eyebrow: 'MCP',
            title: 'Cairn UI for AI assistants',
            lead:
                'A Model Context Protocol server that lets Claude, Cursor, '
                'VS Code, Windsurf, Zed and other assistants look up Cairn\'s '
                'components, exact parameters, tokens, themes, blocks and '
                'templates, instead of guessing the API from memory.',
          ),
          const SizedBox(height: CairnSpacing.s6),
          Wrap(
            spacing: CairnSpacing.s2,
            runSpacing: CairnSpacing.s2,
            children: <Widget>[
              CairnButton(
                onPressed: () => openExternal(McpPage.repo),
                child: const Text('View on GitHub'),
              ),
              CairnButton(
                variant: CairnButtonVariant.outline,
                onPressed: () => openExternal('${McpPage.repo}/releases'),
                child: const Text('Download a binary'),
              ),
              CairnButton(
                variant: CairnButtonVariant.ghost,
                onPressed: () => openExternal(siteFileUrl('llms.txt')),
                child: const Text('llms.txt'),
              ),
            ],
          ),
          const SizedBox(height: CairnSpacing.s10),
          Wrap(
            spacing: CairnSpacing.s4,
            runSpacing: CairnSpacing.s4,
            children: <Widget>[
              feature(
                'The real API',
                'Answers are generated from cairn_ui\'s own source, so '
                    'the assistant cannot describe a parameter that does not '
                    'exist.',
              ),
              feature(
                'Offline, no key',
                'Everything ships inside the binary. No network, no account, '
                    'no API key, nothing to configure.',
              ),
              feature(
                'Tokens, not guesses',
                'Colours, radius, spacing and type come from the theme, with '
                    'values and docs, so generated code follows the system.',
              ),
            ],
          ),
          const SizedBox(height: CairnSpacing.s12),
          const SectionHeading(
            'Install',
            subtitle:
                'You need the Dart SDK, which comes with Flutter. Make sure '
                'the pub cache bin folder is on your PATH.',
          ),
          const SizedBox(height: CairnSpacing.s4),
          const CodeBlock('''
dart pub global activate --source git https://github.com/rlphjyson/cairn_ui_mcp.git
cairn_ui_mcp --info''', language: CodeLanguage.shell),
          const SizedBox(height: CairnSpacing.s3),
          Text(
            'No Dart? Download a prebuilt binary for Windows, macOS or Linux '
            'from the releases page and use its full path as the command.',
            style: muted,
          ),
          const SizedBox(height: CairnSpacing.s12),
          const SectionHeading(
            'Connect your editor',
            subtitle:
                'The server speaks MCP over stdio, which is what every editor '
                'expects. There are no arguments and no environment '
                'variables.',
          ),
          const SizedBox(height: CairnSpacing.s4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: CairnTabs<String>(
              value: _editor,
              onChanged: (String v) => setState(() => _editor = v),
              tabs: <CairnTab<String>>[
                for (final _Editor e in _editors)
                  CairnTab<String>(value: e.id, label: Text(e.name)),
              ],
            ),
          ),
          const SizedBox(height: CairnSpacing.s3),
          Text(editor.where, style: muted),
          const SizedBox(height: CairnSpacing.s3),
          CodeBlock(
            editor.code,
            language: editor.language,
            filename: editor.name,
          ),
          const SizedBox(height: CairnSpacing.s12),
          const SectionHeading(
            'What it provides',
            subtitle:
                'Nine kinds of lookup, all read-only. Resources under '
                'cairn:// and three prompts (build_screen, migrate_to_cairn, '
                'review_cairn_usage) come with them.',
          ),
          const SizedBox(height: CairnSpacing.s4),
          CairnCard(
            children: <Widget>[
              CairnCardContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (int i = 0; i < _tools.length; i++) ...<Widget>[
                      if (i > 0) const CairnSeparator(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: CairnSpacing.s3,
                        ),
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: 250,
                                    child: _ToolName(_tools[i].$1),
                                  ),
                                  Expanded(
                                    child: Text(_tools[i].$2, style: muted),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: CairnSpacing.s1p5,
                                children: <Widget>[
                                  _ToolName(_tools[i].$1),
                                  Text(_tools[i].$2, style: muted),
                                ],
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: CairnSpacing.s12),
          const SectionHeading(
            'Agent skills',
            subtitle:
                'The server answers questions; a skill changes how the agent '
                'writes code. Each skill is a SKILL.md with a references/ '
                'folder, loaded on demand. Use either or both.',
          ),
          const SizedBox(height: CairnSpacing.s4),
          Wrap(
            spacing: CairnSpacing.s3,
            runSpacing: CairnSpacing.s3,
            children: <Widget>[
              for (final (String, String) k in _skills)
                SizedBox(
                  width: wide ? 330 : double.infinity,
                  child: CairnCard(
                    children: <Widget>[
                      CairnCardHeader(title: _ToolName(k.$1)),
                      CairnCardContent(child: Text(k.$2, style: muted)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: CairnSpacing.s4),
          const CodeBlock('''
cairn_ui_mcp install-skills                    # Claude Code, every project
cairn_ui_mcp install-skills --target project   # this project only
cairn_ui_mcp install-skills --target codex     # Codex
cairn_ui_mcp install-skills --dir <folder>     # any agent that reads skill folders
cairn_ui_mcp install-skills --list''', language: CodeLanguage.shell),
          const SizedBox(height: CairnSpacing.s3),
          Text(
            'Re-running the command updates the skills. It never overwrites a '
            'skill of the same name that it did not install unless you pass '
            '--force.',
            style: muted,
          ),
          const SizedBox(height: CairnSpacing.s12),
          const SectionHeading(
            'Try it',
            subtitle:
                'Mention Cairn and the assistant will reach for the tools. If '
                'it does not, say "use the cairn-ui MCP server".',
          ),
          const SizedBox(height: CairnSpacing.s4),
          Wrap(
            spacing: CairnSpacing.s3,
            runSpacing: CairnSpacing.s3,
            children: <Widget>[
              for (final String p in _prompts)
                SizedBox(
                  width: wide ? 330 : double.infinity,
                  child: CairnCard(
                    children: <Widget>[
                      CairnCardContent(
                        child: Text(
                          '“$p”',
                          style: theme
                              .textStyle(CairnTypography.sm)
                              .copyWith(color: theme.foreground, height: 1.55),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: CairnSpacing.s12),
          const SectionHeading(
            'Where the knowledge comes from',
            subtitle:
                'A generator parses cairn_ui\'s source (components, tokens, '
                'theme) and this site\'s catalogues (examples, guides, blocks, '
                'templates) into one compressed index compiled into the '
                'server. Rebuild it when either changes.',
          ),
          const SizedBox(height: CairnSpacing.s4),
          const CodeBlock('''
dart run tool/build_index.dart --cairn-ui ../cairn_ui --site ../cairn_site
dart test''', language: CodeLanguage.shell),
          const SizedBox(height: CairnSpacing.s3),
          Text(
            'The index describes one cairn_ui version, shown by '
            'cairn_ui_mcp --info. Search is keyword and synonym based, tuned '
            'for the component catalogue.',
            style: muted,
          ),
          const SizedBox(height: CairnSpacing.s16),
        ],
      ),
    );
  }
}

class _ToolName extends StatelessWidget {
  const _ToolName(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Text(
      name,
      style: theme
          .textStyle(CairnTypography.sm)
          .copyWith(
            color: theme.foreground,
            fontWeight: CairnTypography.medium,
            fontFamily: 'monospace',
            fontFamilyFallback: const <String>[
              'ui-monospace',
              'SFMono-Regular',
              'Menlo',
              'Consolas',
            ],
          ),
    );
  }
}

/// Where a file in the site's `web/` folder is served.
///
/// Mirrors the logic the template docs use: the production host in a deployed
/// build, the current origin when running locally.
String siteFileUrl(String path) {
  const String production = 'https://rlphjyson.github.io/cairn_site/';
  if (kIsWeb && Uri.base.host != 'rlphjyson.github.io') {
    return Uri.base.resolve('/$path').toString();
  }
  return '$production$path';
}
