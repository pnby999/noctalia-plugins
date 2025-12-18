import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI

Rectangle {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""

    property bool hovered: false
    property int noteCount: 0

    readonly property string barPosition: Settings.data.bar.position
    readonly property bool isVertical: barPosition === "left" || barPosition === "right"
    readonly property string notesPath: (pluginApi?.pluginDir || (Settings.configDir + "/plugins/glance-notes")) + "/notes.json"

    implicitWidth: isVertical ? Style.capsuleHeight : (noteCount > 0 ? 60 : 40) * Style.uiScaleRatio
    implicitHeight: isVertical ? (noteCount > 0 ? 60 : 40) * Style.uiScaleRatio : Style.capsuleHeight

    color: root.hovered ? Color.mHover : (noteCount > 0 ? Color.mSurfaceVariant : "transparent")
    radius: Style.radiusM

    Behavior on color {
        ColorAnimation {
            duration: Style.animationNormal
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Style.animationNormal
            easing.type: Easing.InOutQuad
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: Style.marginXS

        NIcon {
            icon: "note-multiple-symbolic"
            color: root.hovered ? Color.mOnHover : (noteCount > 0 ? Color.mPrimary : Color.mOnSurface)
            
            Behavior on color {
                ColorAnimation {
                    duration: Style.animationNormal
                    easing.type: Easing.InOutQuad
                }
            }
        }

        NText {
            visible: noteCount > 0
            text: noteCount.toString()
            pointSize: Style.fontSizeS
            font.weight: Font.Bold
            color: root.hovered ? Color.mOnHover : Color.mPrimary
            
            Behavior on color {
                ColorAnimation {
                    duration: Style.animationNormal
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (pluginApi) {
                pluginApi.openPanel(root.screen);
            }
        }

        onEntered: {
            root.hovered = true;
            var tooltip = noteCount === 0 ? "Quick Notes (empty)" : 
                         noteCount === 1 ? "1 note" :
                         noteCount + " notes";
            TooltipService.show(root, tooltip, BarService.getTooltipDirection());
        }

        onExited: {
            root.hovered = false;
            TooltipService.hide();
        }
    }

    // Check note count
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: checkNoteCount.running = true
    }

    Process {
        id: checkNoteCount
        command: ["sh", "-c", "cat '" + root.notesPath + "' 2>/dev/null || echo '[]'"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var parsed = JSON.parse(text.trim());
                    root.noteCount = Array.isArray(parsed) ? parsed.length : 0;
                } catch (e) {
                    root.noteCount = 0;
                }
            }
        }
    }

    Component.onCompleted: {
        checkNoteCount.running = true;
    }
}
