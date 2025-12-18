# GlanceNotes

powerful note manager for noctalia. manage multiple timestamped notes with an intuitive interface.

## features

- **multiple notes** - create as many notes as you need
- **timestamps** - automatic creation and modification dates
- **smart formatting** - "just now", "5m ago", "2h ago", etc.
- **one-click copy** - copy any note to clipboard instantly
- **inline editing** - edit notes with a clean modal editor
- **delete notes** - remove notes you don't need anymore
- **note counter** - bar widget shows how many notes you have
- **keyboard shortcuts** - ctrl+enter to save, esc to cancel
- **json storage** - structured data storage with full history
- **empty state** - helpful placeholder when you have no notes
- **smooth animations** - polished UI that matches noctalia
- **clipboard support** - works with both wayland (wl-copy) and X11 (xclip)

## installation

this plugin is available through noctalia's plugin system.

1. open noctalia settings
2. go to plugins tab
3. add source: `https://github.com/pnby999/noctalia-plugins`
4. find "glance-notes" and enable it
5. add the widget to your bar (settings > bar)

## usage

**create a note:**
- click the "New Note" button
- start typing
- press ctrl+enter to save (or click Save)

**edit a note:**
- click the "Edit" button on any note
- make your changes
- press ctrl+enter to save

**copy a note:**
- click the "Copy" button on any note
- text is copied to your clipboard

**delete a note:**
- click the "Delete" button on any note
- note is immediately removed

**bar widget:**
- shows note count badge
- icon changes color when you have notes
- tooltip shows "X notes" or "empty"

## data format

notes are stored in `~/.config/noctalia/plugins/glance-notes/notes.json`:

```json
[
  {
    "id": 1734543210000,
    "text": "Your note content here",
    "created": "2024-12-18T16:00:00.000Z",
    "modified": "2024-12-18T16:05:00.000Z"
  }
]
```

## requirements

- noctalia 3.6.0+
- wl-copy (wayland) or xclip (X11) for clipboard support

## customization

change panel size by editing `Panel.qml`:

```qml
property real contentPreferredWidth: 600 * Style.uiScaleRatio
property real contentPreferredHeight: 700 * Style.uiScaleRatio
```

## license

MIT
