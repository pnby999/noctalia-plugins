import QtQuick
import QtQuick.Layouts
import Quickshell
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
    property bool hasNotes: false

    readonly property string barPosition: Settings.data.bar.position
    readonly property bool isVertical: barPosition === "left" || barPosition === "right"
    readonly property string notesPath: (pluginApi?.pluginDir || (Settings.configDir + "/plugins/glance-notes")) + "/notes.txt"

    implicitWidth: isVertical ? Style.capsuleHeight : (hasNotes ? 50 : 40) * Style.uiScaleRatio
    implicitHeight: isVertical ? (hasNotes ? 50 : 40) * Style.uiScaleRatio : Style.capsuleHeight

    color: root.hovered ? Color.mHover : (hasNotes ? Color.mSurfaceVariant : "transparent")
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
            icon: hasNotes ? "draft-symbolic" : "edit-symbolic"
            color: root.hovered ? Color.mOnHover : (hasNotes ? Color.mPrimary : Color.mOnSurface)
            
            Behavior on color {
                ColorAnimation {
                    duration: Style.animationNormal
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            visible: hasNotes
            Layout.preferredWidth: 4
            Layout.preferredHeight: 4
            radius: 2
            color: Color.mPrimary
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
            var tooltip = hasNotes ? "Quick Notes (has content)" : "Quick Notes (empty)";
            TooltipService.show(root, tooltip, BarService.getTooltipDirection());
        }

        onExited: {
            root.hovered = false;
            TooltipService.hide();
        }
    }

    // Check if notes file has content
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: checkNotesExist.running = true
    }

    Process {
        id: checkNotesExist
        command: ["sh", "-c", "test -s '" + root.notesPath + "' && echo 'yes' || echo 'no'"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.hasNotes = text.trim() === "yes";
            }
        }
    }

    Component.onCompleted: {
        checkNotesExist.running = true;
    }
}
