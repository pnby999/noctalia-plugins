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

    readonly property string barPosition: Settings.data.bar.position
    readonly property bool isVertical: barPosition === "left" || barPosition === "right"

    implicitWidth: isVertical ? Style.capsuleHeight : 40 * Style.uiScaleRatio
    implicitHeight: isVertical ? 40 * Style.uiScaleRatio : Style.capsuleHeight

    color: root.hovered ? Color.mHover : "transparent"
    radius: Style.radiusM

    NIcon {
        anchors.centerIn: parent
        icon: "edit-symbolic"
        color: root.hovered ? Color.mOnHover : Color.mOnSurface
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
            TooltipService.show(root, "Notes", BarService.getTooltipDirection());
        }

        onExited: {
            root.hovered = false;
            TooltipService.hide();
        }
    }
}

