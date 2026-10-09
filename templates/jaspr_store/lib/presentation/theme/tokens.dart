/// Design tokens: the Cairn design language as CSS custom properties.
///
/// The values are copied from `cairn_ui` (`lib/src/tokens/`): the neutral
/// OKLCH palette in `colors.dart`, the radius multipliers in `radius.dart`, the
/// 4px spacing grid in `spacing.dart`, the type scale in `typography.dart` and
/// the shadow ramp in `shadows.dart`. Components read `var(--token)`, so the
/// light/dark switch is a re-declaration of `:root`, not a duplicated rule set.
library;

/// CSS `var()` references. Using these constants instead of string literals
/// means a renamed token is a compile error rather than a silently broken style.
abstract final class Tok {
  static const background = 'var(--background)';
  static const foreground = 'var(--foreground)';
  static const card = 'var(--card)';
  static const primary = 'var(--primary)';
  static const primaryForeground = 'var(--primary-foreground)';
  static const secondary = 'var(--secondary)';
  static const muted = 'var(--muted)';
  static const mutedForeground = 'var(--muted-foreground)';
  static const accent = 'var(--accent)';
  static const destructive = 'var(--destructive)';
  static const destructiveForeground = 'var(--destructive-foreground)';
  static const success = 'var(--success)';
  static const warning = 'var(--warning)';
  static const star = 'var(--star)';
  static const border = 'var(--border)';
  static const input = 'var(--input)';
  static const ring = 'var(--ring)';

  static const radiusSm = 'var(--radius-sm)';
  static const radiusMd = 'var(--radius-md)';
  static const radiusLg = 'var(--radius-lg)';
  static const radiusXl = 'var(--radius-xl)';

  static const shadowXs = 'var(--shadow-xs)';
  static const shadowSm = 'var(--shadow-sm)';
  static const shadowMd = 'var(--shadow-md)';
  static const shadowLg = 'var(--shadow-lg)';

  /// The 4px grid: `Tok.space(4)` is `1rem`.
  static String space(num step) => 'var(--space-${_key(step)})';
  static String _key(num s) => s == s.roundToDouble() ? s.toInt().toString() : s.toString().replaceAll('.', 'p');
}

/// Tokens shared by both themes: radius, spacing, type, motion.
const Map<String, String> sharedTokens = {
  '--radius': '0.625rem',
  '--radius-sm': 'calc(var(--radius) * 0.6)',
  '--radius-md': 'calc(var(--radius) * 0.8)',
  '--radius-lg': 'var(--radius)',
  '--radius-xl': 'calc(var(--radius) * 1.4)',
  // 4px grid, as in CairnSpacing.
  '--space-0p5': '0.125rem',
  '--space-1': '0.25rem',
  '--space-1p5': '0.375rem',
  '--space-2': '0.5rem',
  '--space-2p5': '0.625rem',
  '--space-3': '0.75rem',
  '--space-3p5': '0.875rem',
  '--space-4': '1rem',
  '--space-5': '1.25rem',
  '--space-6': '1.5rem',
  '--space-8': '2rem',
  '--space-10': '2.5rem',
  '--space-12': '3rem',
  '--space-16': '4rem',
  '--space-20': '5rem',
  '--space-24': '6rem',
  '--font-sans': 'ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
  '--font-mono': 'ui-monospace, SFMono-Regular, Menlo, Consolas, monospace',
  '--text-xs': '0.75rem',
  '--text-sm': '0.875rem',
  '--text-base': '1rem',
  '--text-lg': '1.125rem',
  '--text-xl': '1.25rem',
  '--text-2xl': '1.5rem',
  '--text-3xl': '1.875rem',
  '--text-4xl': '2.25rem',
  '--container': '80rem',
  '--ease': 'cubic-bezier(0.4, 0, 0.2, 1)',
};

/// Light theme: `CairnColors.light*`.
const Map<String, String> lightTokens = {
  'color-scheme': 'light',
  '--background': 'oklch(1 0 0)',
  '--foreground': 'oklch(0.145 0 0)',
  '--card': 'oklch(1 0 0)',
  '--primary': 'oklch(0.205 0 0)',
  '--primary-foreground': 'oklch(0.985 0 0)',
  '--secondary': 'oklch(0.97 0 0)',
  '--muted': 'oklch(0.97 0 0)',
  '--muted-foreground': 'oklch(0.556 0 0)',
  '--accent': 'oklch(0.97 0 0)',
  '--destructive': 'oklch(0.577 0.245 27.325)',
  '--destructive-foreground': 'oklch(1 0 0)',
  '--success': 'oklch(0.527 0.154 150.069)',
  '--warning': 'oklch(0.555 0.163 48.998)',
  '--star': 'oklch(0.769 0.188 70.08)',
  '--border': 'oklch(0.922 0 0)',
  '--input': 'oklch(0.922 0 0)',
  '--ring': 'oklch(0.708 0 0)',
  // CairnShadows.xs / sm / md / lg
  '--shadow-xs': '0 1px 2px 0 rgb(0 0 0 / 0.05)',
  '--shadow-sm': '0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)',
  '--shadow-md': '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)',
  '--shadow-lg': '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
};

/// Dark theme: `CairnColors.dark*`. Borders are translucent white, exactly as
/// in the Flutter library.
const Map<String, String> darkTokens = {
  'color-scheme': 'dark',
  '--background': 'oklch(0.145 0 0)',
  '--foreground': 'oklch(0.985 0 0)',
  '--card': 'oklch(0.205 0 0)',
  '--primary': 'oklch(0.922 0 0)',
  '--primary-foreground': 'oklch(0.205 0 0)',
  '--secondary': 'oklch(0.269 0 0)',
  '--muted': 'oklch(0.269 0 0)',
  '--muted-foreground': 'oklch(0.708 0 0)',
  '--accent': 'oklch(0.269 0 0)',
  '--destructive': 'oklch(0.704 0.191 22.216)',
  '--destructive-foreground': 'oklch(0.145 0 0)',
  '--success': 'oklch(0.792 0.209 151.711)',
  '--warning': 'oklch(0.828 0.189 84.429)',
  '--star': 'oklch(0.828 0.189 84.429)',
  '--border': 'oklch(1 0 0 / 10%)',
  '--input': 'oklch(1 0 0 / 15%)',
  '--ring': 'oklch(0.556 0 0)',
  '--shadow-xs': '0 1px 2px 0 rgb(0 0 0 / 0.3)',
  '--shadow-sm': '0 1px 3px 0 rgb(0 0 0 / 0.4), 0 1px 2px -1px rgb(0 0 0 / 0.4)',
  '--shadow-md': '0 4px 6px -1px rgb(0 0 0 / 0.4), 0 2px 4px -2px rgb(0 0 0 / 0.4)',
  '--shadow-lg': '0 10px 15px -3px rgb(0 0 0 / 0.5), 0 4px 6px -4px rgb(0 0 0 / 0.5)',
};
