# Statusbar extraction TODO

## Current state

The implementation is isolated in [`frame-status.el`](./frame-status.el), but
Doom still loads it directly from [`../config.el`](../config.el). It is not yet
an installable Emacs package.

`statusbar` is the candidate package name. No MELPA recipe named `statusbar`
existed when checked on 2026-08-05.

## Before publishing

- [ ] Add a global minor mode with reliable enable/disable behavior and
      complete restoration of all changed Emacs state.
- [ ] Add standard package metadata, documentation, version, license boilerplate
      and the package footer.
- [ ] Rename the `ishovkun-` namespace.
- [ ] Declare `doom-modeline` as an explicit dependency and provide optional
      Evil, Flycheck, Flymake, Magit and perspective adapters.
- [ ] Replace private APIs such as `flymake--handle-report` and Doom's internal
      diagnostic-counting functions.
- [ ] Make the segment lists and Python/workspace behavior configurable.
- [ ] Add automated tests for minibuffer input, messages, mouse actions, window
      restoration, theme and font changes, diagnostics, and disabling.
- [ ] Move the package into a dedicated source-control repository before MELPA
      submission, as required by the
      [MELPA contribution guidelines](https://github.com/melpa/melpa/blob/master/CONTRIBUTING.org).
- [ ] Run `package-lint`, `checkdoc`, byte compilation and MELPA recipe tests.

## Initial release scope

The first release should be a focused Doom-modeline companion rather than a
supposedly universal status framework. The rendering and minibuffer transport
can become a generic backend later, after the Doom integration is stable.

Keep the dotfiles pointed at the local checkout while developing and testing
the extracted package.

## Licensing and attribution

Use GPL-3.0-or-later. The diagnostics icon geometry derives from Zed, whose
source is
[primarily GPL-3.0-or-later](https://github.com/zed-industries/zed/blob/main/README.md#licensing),
so retain attribution for those adapted icons. Add the AI-assistance attribution
requested by MELPA's current contribution guidelines.
