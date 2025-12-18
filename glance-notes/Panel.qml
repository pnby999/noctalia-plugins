import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets

Item {
    id: root
    property var pluginApi: null
    property ShellScreen screen

    // SmartPanel properties
    readonly property var geometryPlaceholder: panelContainer
    readonly property bool allowAttach: true
    property real contentPreferredWidth: 400 * Style.uiScaleRatio
    property real contentPreferredHeight: 500 * Style.uiScaleRatio

    readonly property string notesPath: (pluginApi?.pluginDir || (Settings.configDir + "/plugins/glance-notes")) + "/notes.txt"

    anchors.fill: parent

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
                spacing: Style.marginS

                NText {
                    text: "Quick Notes"
                    font.pointSize: Style.fontSizeL
                    font.weight: Font.Bold
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Color.mSurfaceVariant
                    radius: Style.radiusM
                    border.color: Color.mOutlineVariant
                    border.width: Style.borderS
                    clip: true

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: Style.marginS
                        contentWidth: availableWidth

                        TextArea {
                            id: notesArea
                            width: parent.width
                            wrapMode: TextEdit.Wrap
                            color: Color.mOnSurfaceVariant
                            font.pointSize: Style.fontSizeM
                            selectedTextColor: Color.mOnPrimary
                            selectionColor: Color.mPrimary
                            placeholderText: "Type your notes here..."
                            placeholderTextColor: Color.mOutline

                            background: null

                            onTextChanged: {
                                saveTimer.restart();
                            }
                        }
                    }
                }
            }
        }
    }

    // Persistence Logic
    Process {
        id: readProcess
        command: ["cat", root.notesPath]
        stdout: StdioCollector {
            onStreamFinished: {
                notesArea.text = text;
            }
        }
    }

    Process {
        id: writeProcess
        // We use a temporary file to ensure atomic-like write or just redirect
        command: ["sh", "-c", "cat > '" + root.notesPath + "'"]
        stdin: StdioSource {
            id: writeStdin
        }
    }

    Timer {
        id: saveTimer
        interval: 1000
        repeat: false
        onTriggered: {
            writeStdin.write(notesArea.text);
            writeStdin.close();
            writeProcess.running = true;
        }
    }

    Component.onCompleted: {
        readProcess.running = true;
    }
}

