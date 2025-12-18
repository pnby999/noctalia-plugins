import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root
    property var pluginApi: null
    property ShellScreen screen

    // SmartPanel properties
    readonly property var geometryPlaceholder: panelContainer
    readonly property bool allowAttach: true
    property real contentPreferredWidth: 500 * Style.uiScaleRatio
    property real contentPreferredHeight: 600 * Style.uiScaleRatio

    readonly property string notesPath: (pluginApi?.pluginDir || (Settings.configDir + "/plugins/glance-notes")) + "/notes.txt"
    property bool isSaving: false
    property bool hasUnsavedChanges: false
    property int wordCount: 0
    property int charCount: 0

    anchors.fill: parent

    function saveNotes() {
        isSaving = true;
        saveProcess.running = true;
    }

    function loadNotes() {
        loadProcess.running = true;
    }

    function clearNotes() {
        notesArea.text = "";
        saveNotes();
    }

    function updateStats() {
        var text = notesArea.text.trim();
        root.charCount = notesArea.text.length;
        root.wordCount = text.length > 0 ? text.split(/\s+/).length : 0;
    }

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            anchors.margins: Style.marginL
            color: Color.mSurface
            radius: Style.radiusL
            border.color: Color.mOutline
            border.width: Style.borderS
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.marginM
                spacing: Style.marginM

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginM

                    NIcon {
                        icon: "draft-symbolic"
                        color: Color.mPrimary
                    }

                    NText {
                        text: "Quick Notes"
                        font.pointSize: Style.fontSizeXL
                        font.weight: Font.Bold
                        color: Color.mOnSurface
                    }

                    Item { Layout.fillWidth: true }

                    // Save indicator
                    RowLayout {
                        visible: root.hasUnsavedChanges || root.isSaving
                        spacing: Style.marginXS

                        Rectangle {
                            Layout.preferredWidth: 6
                            Layout.preferredHeight: 6
                            radius: 3
                            color: root.isSaving ? Color.mPrimary : Color.mTertiary

                            SequentialAnimation on opacity {
                                running: root.isSaving
                                loops: Animation.Infinite
                                NumberAnimation { from: 1; to: 0.3; duration: 500 }
                                NumberAnimation { from: 0.3; to: 1; duration: 500 }
                            }
                        }

                        NText {
                            text: root.isSaving ? "Saving..." : "Unsaved"
                            pointSize: Style.fontSizeXS
                            color: root.isSaving ? Color.mPrimary : Color.mTertiary
                        }
                    }
                }

                // Stats bar
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginM

                    Rectangle {
                        Layout.preferredWidth: 3
                        Layout.preferredHeight: 16
                        radius: 1.5
                        color: Color.mPrimary
                    }

                    NText {
                        text: root.wordCount + " words"
                        pointSize: Style.fontSizeS
                        color: Color.mOnSurfaceVariant
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 12
                        color: Color.mOutlineVariant
                    }

                    NText {
                        text: root.charCount + " characters"
                        pointSize: Style.fontSizeS
                        color: Color.mOnSurfaceVariant
                    }

                    Item { Layout.fillWidth: true }
                }

                // Text area
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Color.mSurfaceVariant
                    radius: Style.radiusM
                    border.color: notesArea.activeFocus ? Color.mPrimary : Color.mOutlineVariant
                    border.width: notesArea.activeFocus ? 2 : Style.borderS
                    clip: true

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Style.animationFast
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Behavior on border.width {
                        NumberAnimation {
                            duration: Style.animationFast
                            easing.type: Easing.InOutQuad
                        }
                    }

                    ScrollView {
                        id: scrollView
                        anchors.fill: parent
                        anchors.margins: Style.marginS
                        contentWidth: availableWidth
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            width: 8
                            
                            contentItem: Rectangle {
                                implicitWidth: 8
                                radius: 4
                                color: Color.mOutlineVariant
                                opacity: scrollView.ScrollBar.vertical.active ? 1 : 0.5
                                
                                Behavior on opacity {
                                    NumberAnimation { duration: 200 }
                                }
                            }
                        }

                        TextArea {
                            id: notesArea
                            width: scrollView.availableWidth
                            wrapMode: TextEdit.Wrap
                            color: Color.mOnSurfaceVariant
                            font.pointSize: Style.fontSizeM
                            font.family: "monospace"
                            selectedTextColor: Color.mOnPrimary
                            selectionColor: Color.mPrimary
                            placeholderText: "Start typing your notes here...\n\nTip: Your notes are automatically saved as you type."
                            placeholderTextColor: Color.mOutline

                            background: null

                            onTextChanged: {
                                root.hasUnsavedChanges = true;
                                root.updateStats();
                                autoSaveTimer.restart();
                            }

                            Keys.onPressed: function(event) {
                                if (event.modifiers & Qt.ControlModifier) {
                                    if (event.key === Qt.Key_S) {
                                        root.saveNotes();
                                        event.accepted = true;
                                    }
                                }
                            }
                        }
                    }
                }

                // Action buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginS

                    NButton {
                        text: "Clear All"
                        icon: "delete-symbolic"
                        onClicked: {
                            if (notesArea.text.trim().length > 0) {
                                // Simple confirmation - just clear
                                root.clearNotes();
                                ToastService.show("Notes cleared", ToastService.Type.Info);
                            }
                        }
                    }

                    NButton {
                        text: "Save Now"
                        icon: "save-symbolic"
                        highlighted: root.hasUnsavedChanges
                        onClicked: {
                            root.saveNotes();
                        }
                    }

                    Item { Layout.fillWidth: true }

                    NText {
                        text: "Ctrl+S to save"
                        pointSize: Style.fontSizeXS
                        color: Color.mOutlineVariant
                    }
                }
            }
        }
    }

    // Auto-save timer (1 second after last keystroke)
    Timer {
        id: autoSaveTimer
        interval: 1000
        repeat: false
        onTriggered: {
            root.saveNotes();
        }
    }

    // Load process
    Process {
        id: loadProcess
        command: ["sh", "-c", "cat '" + root.notesPath + "' 2>/dev/null || echo ''"]
        stdout: StdioCollector {
            onStreamFinished: {
                notesArea.text = text;
                root.hasUnsavedChanges = false;
                root.updateStats();
            }
        }
    }

    // Save process
    Process {
        id: saveProcess
        command: ["sh", "-c", "printf '%s' \"$NOTES_CONTENT\" > '" + root.notesPath + "'"]
        environment: {
            "NOTES_CONTENT": notesArea.text
        }
        onExited: function(code, status) {
            root.isSaving = false;
            if (code === 0) {
                root.hasUnsavedChanges = false;
            } else {
                Logger.e("GlanceNotes", "Failed to save notes");
                ToastService.show("Failed to save notes", ToastService.Type.Error);
            }
        }
    }

    Component.onCompleted: {
        root.loadNotes();
        notesArea.forceActiveFocus();
    }
}
