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
    property real contentPreferredWidth: 600 * Style.uiScaleRatio
    property real contentPreferredHeight: 700 * Style.uiScaleRatio

    readonly property string notesPath: (pluginApi?.pluginDir || (Settings.configDir + "/plugins/glance-notes")) + "/notes.json"
    property var notes: []
    property int editingIndex: -1
    property string editingText: ""

    anchors.fill: parent

    Component.onCompleted: {
        Logger.i("GlanceNotes", "Panel loaded!");
        loadNotes();
    }

    function loadNotes() {
        Logger.i("GlanceNotes", "Loading notes from: " + notesPath);
        loadProcess.running = true;
    }

    function saveNotes() {
        Logger.i("GlanceNotes", "Saving notes...");
        var jsonData = JSON.stringify(root.notes, null, 2);
        saveProcess.environment = { "NOTES_JSON": jsonData };
        saveProcess.running = true;
    }

    function addNote() {
        var now = new Date();
        var newNote = {
            "id": Date.now(),
            "text": "",
            "created": now.toISOString(),
            "modified": now.toISOString()
        };
        root.notes.push(newNote);
        root.notes = root.notes; // Trigger update
        root.editingIndex = root.notes.length - 1;
        root.editingText = "";
        saveNotes();
    }

    function deleteNote(index) {
        root.notes.splice(index, 1);
        root.notes = root.notes; // Trigger update
        root.editingIndex = -1;
        saveNotes();
    }

    function startEdit(index) {
        root.editingIndex = index;
        root.editingText = root.notes[index].text;
    }

    function saveEdit() {
        if (root.editingIndex >= 0 && root.editingIndex < root.notes.length) {
            root.notes[root.editingIndex].text = root.editingText;
            root.notes[root.editingIndex].modified = new Date().toISOString();
            root.notes = root.notes; // Trigger update
            root.editingIndex = -1;
            saveNotes();
        }
    }

    function cancelEdit() {
        root.editingIndex = -1;
        root.editingText = "";
    }

    function copyToClipboard(text) {
        copyProcess.environment = { "COPY_TEXT": text };
        copyProcess.running = true;
        ToastService.show("Copied to clipboard!", ToastService.Type.Info);
    }

    function formatDate(isoString) {
        var date = new Date(isoString);
        var now = new Date();
        var diffMs = now - date;
        var diffMins = Math.floor(diffMs / 60000);
        var diffHours = Math.floor(diffMs / 3600000);
        var diffDays = Math.floor(diffMs / 86400000);

        if (diffMins < 1) return "just now";
        if (diffMins < 60) return diffMins + "m ago";
        if (diffHours < 24) return diffHours + "h ago";
        if (diffDays < 7) return diffDays + "d ago";
        
        return date.toLocaleDateString();
    }

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        color: Color.transparent

        Rectangle {
            anchors.fill: parent
            anchors.margins: Style.marginL
            color: Color.mSurface
            radius: Style.radiusL
            border.color: Color.mOutline
            border.width: Style.borderS

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.marginM
                spacing: Style.marginM

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginM

                    NIcon {
                        icon: "note-multiple-symbolic"
                        color: Color.mPrimary
                    }

                    NText {
                        text: "Quick Notes"
                        font.pointSize: Style.fontSizeXL
                        font.weight: Font.Bold
                        color: Color.mOnSurface
                    }

                    Item { Layout.fillWidth: true }

                    NText {
                        text: root.notes.length + " " + (root.notes.length === 1 ? "note" : "notes")
                        pointSize: Style.fontSizeS
                        color: Color.mOnSurfaceVariant
                    }

                    NButton {
                        text: "New Note"
                        icon: "add-symbolic"
                        onClicked: root.addNote()
                    }
                }

                // Notes list or editor
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Color.mSurfaceVariant
                    radius: Style.radiusM
                    clip: true

                    // Editing mode
                    Item {
                        visible: root.editingIndex >= 0
                        anchors.fill: parent

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Style.marginM
                            spacing: Style.marginM

                            RowLayout {
                                Layout.fillWidth: true

                                NText {
                                    text: "Editing Note"
                                    pointSize: Style.fontSizeM
                                    font.weight: Font.Bold
                                    color: Color.mPrimary
                                }

                                Item { Layout.fillWidth: true }

                                NButton {
                                    text: "Cancel"
                                    onClicked: root.cancelEdit()
                                }

                                NButton {
                                    text: "Save"
                                    highlighted: true
                                    onClicked: root.saveEdit()
                                }
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                contentWidth: availableWidth

                                TextArea {
                                    id: editArea
                                    width: parent.width
                                    text: root.editingText
                                    wrapMode: TextEdit.Wrap
                                    color: Color.mOnSurface
                                    font.pointSize: Style.fontSizeM
                                    placeholderText: "Type your note here..."
                                    placeholderTextColor: Color.mOutline
                                    background: Rectangle {
                                        color: Color.mSurface
                                        radius: Style.radiusS
                                    }

                                    onTextChanged: root.editingText = text

                                    Keys.onPressed: function(event) {
                                        if (event.modifiers & Qt.ControlModifier) {
                                            if (event.key === Qt.Key_Return) {
                                                root.saveEdit();
                                                event.accepted = true;
                                            }
                                        }
                                        if (event.key === Qt.Key_Escape) {
                                            root.cancelEdit();
                                            event.accepted = true;
                                        }
                                    }

                                    Component.onCompleted: {
                                        if (visible) forceActiveFocus();
                                    }
                                }
                            }

                            NText {
                                text: "Ctrl+Enter to save • Esc to cancel"
                                pointSize: Style.fontSizeXS
                                color: Color.mOutlineVariant
                            }
                        }
                    }

                    // List mode
                    ScrollView {
                        visible: root.editingIndex < 0
                        anchors.fill: parent
                        anchors.margins: Style.marginS
                        contentWidth: availableWidth

                        ColumnLayout {
                            width: parent.width
                            spacing: Style.marginS

                            Repeater {
                                model: root.notes

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: noteContent.implicitHeight + Style.marginM * 2
                                    color: Color.mSurface
                                    radius: Style.radiusM
                                    border.color: Color.mOutlineVariant
                                    border.width: 1

                                    ColumnLayout {
                                        id: noteContent
                                        anchors.fill: parent
                                        anchors.margins: Style.marginM
                                        spacing: Style.marginS

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: Style.marginS

                                            NText {
                                                text: root.formatDate(modelData.modified)
                                                pointSize: Style.fontSizeXS
                                                color: Color.mOutlineVariant
                                            }

                                            Item { Layout.fillWidth: true }

                                            NButton {
                                                text: "Copy"
                                                icon: "copy-symbolic"
                                                onClicked: root.copyToClipboard(modelData.text)
                                            }

                                            NButton {
                                                text: "Edit"
                                                icon: "edit-symbolic"
                                                onClicked: root.startEdit(index)
                                            }

                                            NButton {
                                                text: "Delete"
                                                icon: "delete-symbolic"
                                                onClicked: root.deleteNote(index)
                                            }
                                        }

                                        NText {
                                            Layout.fillWidth: true
                                            text: modelData.text || "<empty note>"
                                            pointSize: Style.fontSizeM
                                            color: modelData.text ? Color.mOnSurface : Color.mOutline
                                            wrapMode: Text.Wrap
                                            maximumLineCount: 10
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }

                            // Empty state
                            Item {
                                visible: root.notes.length === 0
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.preferredHeight: 300

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: Style.marginM

                                    NIcon {
                                        Layout.alignment: Qt.AlignHCenter
                                        icon: "note-multiple-symbolic"
                                        color: Color.mOutlineVariant
                                    }

                                    NText {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "No notes yet"
                                        pointSize: Style.fontSizeL
                                        color: Color.mOutlineVariant
                                    }

                                    NText {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "Click 'New Note' to get started"
                                        pointSize: Style.fontSizeS
                                        color: Color.mOutlineVariant
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Load process
    Process {
        id: loadProcess
        command: ["sh", "-c", "cat '" + root.notesPath + "' 2>/dev/null || echo '[]'"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var parsed = JSON.parse(text);
                    root.notes = Array.isArray(parsed) ? parsed : [];
                    Logger.i("GlanceNotes", "Loaded " + root.notes.length + " notes");
                } catch (e) {
                    Logger.e("GlanceNotes", "Failed to parse JSON: " + e);
                    root.notes = [];
                }
            }
        }
    }

    // Save process
    Process {
        id: saveProcess
        command: ["sh", "-c", "printf '%s' \"$NOTES_JSON\" > '" + root.notesPath + "'"]
        property var environment: ({})
        onExited: function(code, status) {
            if (code === 0) {
                Logger.i("GlanceNotes", "Notes saved successfully");
            } else {
                Logger.e("GlanceNotes", "Failed to save notes");
            }
        }
    }

    // Copy to clipboard process
    Process {
        id: copyProcess
        command: ["sh", "-c", "printf '%s' \"$COPY_TEXT\" | wl-copy || printf '%s' \"$COPY_TEXT\" | xclip -selection clipboard"]
        property var environment: ({})
    }
}
