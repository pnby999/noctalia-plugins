# GlanceNotes

quick notes plugin for noctalia. just a simple notepad that sits in your bar.

## what it does

- click the icon on your bar
- type whatever you need to remember
- saves automatically (1sec after you stop typing)
- notes persist between sessions

## installation

this plugin is available through the official noctalia plugins registry.

1. open noctalia settings
2. go to plugins tab
3. add source: `https://github.com/pnby999/noctalia-plugins`
4. find "glance-notes" and enable it

## requirements

- noctalia 3.6.0+

## customization

to change the panel size, edit `Panel.qml`:

```qml
property real contentPreferredWidth: 400 * Style.uiScaleRatio
property real contentPreferredHeight: 500 * Style.uiScaleRatio
```

## license

MIT
