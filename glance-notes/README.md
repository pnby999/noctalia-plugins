# GlanceNotes

powerful yet minimal notes plugin for noctalia. your personal sticky note with all the features you need.

## features

- **auto-save** - saves 1 second after you stop typing
- **word & character count** - real-time stats as you write
- **keyboard shortcuts** - ctrl+s to save instantly
- **visual feedback** - see when notes are saving or unsaved
- **smart bar widget** - shows indicator when you have notes
- **smooth animations** - polished UI that matches noctalia
- **clear button** - wipe notes when you're done
- **monospace font** - clean, readable text
- **persistent** - notes survive restarts

## installation

this plugin is available through noctalia's plugin system.

1. open noctalia settings
2. go to plugins tab
3. add source: `https://github.com/pnby999/noctalia-plugins`
4. find "glance-notes" and enable it
5. add the widget to your bar (settings > bar)

## usage

**open notes:**
- click the notes icon in your bar

**save notes:**
- automatic after 1 second of no typing
- or press `ctrl+s` to save immediately

**clear notes:**
- click the "clear all" button in the panel

**bar indicator:**
- icon changes when you have notes
- small dot appears next to icon
- tooltip shows if notes are empty or have content

## customization

change panel size by editing `Panel.qml`:

```qml
property real contentPreferredWidth: 500 * Style.uiScaleRatio
property real contentPreferredHeight: 600 * Style.uiScaleRatio
```

## requirements

- noctalia 3.6.0+

## license

MIT
