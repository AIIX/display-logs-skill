import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Window 2.12
import QtQuick.Shapes 1.12
import Mycroft 1.0 as Mycroft
import org.kde.kirigami 2.9 as Kirigami
import org.kde.kitemmodels 1.0 as KItemModels

Mycroft.Delegate {
    property int currentIndex: 0
    property var skillsLogModel: sessionData.skills_log_model.logs
    skillBackgroundColorOverlay: "#222"
    leftPadding: 0
    bottomPadding: 0
    topPadding: 0
    rightPadding: 0

    onSkillsLogModelChanged: {
        toListModel(sessionData.skills_log_model.logs)
        ksortModel.sourceModel = logModel
    }

    function toListModel(items) {
        for (var i=0; i<items.length; i++) {
            logModel.append(items[i])
        }
    }

    ListModel {
        id: logModel
        onCountChanged: {
            repeaterView.positionViewAtIndex(count - 1, ListView.End)
        }
    }

    Rectangle {
        id: searchBox
        color: "#313131"
        height: Mycroft.Units.gridUnit * 4
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Mycroft.Units.gridUnit * 2
        anchors.leftMargin: Mycroft.Units.gridUnit * 2
        anchors.rightMargin: Mycroft.Units.gridUnit * 2
        anchors.bottomMargin: 0

        ComboBox {
            id: logFilterSelector
            textRole: "text"
            valueRole: "text"
            model: ListModel {
                ListElement { text: "timestamp" }
                ListElement { text: "type" }
                ListElement { text: "intentid" }
                ListElement { text: "intent" }
                ListElement { text: "content" }
            }
            displayText: " Filter: " + currentText
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: Mycroft.Units.gridUnit * 0.5

            onCurrentIndexChanged: {
                ksortModel.filterRole = textAt(currentIndex)
            }
        }

        TextField {
            id: searchField
            anchors.left: logFilterSelector.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: refreshBtn.left
            anchors.margins: Mycroft.Units.gridUnit * 0.5
            placeholderText: "Search Filter"
        }

        Button {
            id: refreshBtn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: firsSept.left
            anchors.margins: Mycroft.Units.gridUnit * 0.5
            icon.name: "view-refresh"
            width: Mycroft.Units.gridUnit * 8
            text: "Refresh"

            onClicked: {
                triggerGuiEvent("logger.skill.refresh.log", {log: sessionData.currentLog})
            }
        }

        Kirigami.Separator {
            width: 1
            id: firsSept
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: autoRefLogBtn.left
            color: Kirigami.Theme.backgroundColor
        }

        Button {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: Mycroft.Units.gridUnit * 0.5
            id: autoRefLogBtn
            width: Mycroft.Units.gridUnit * 2
            icon.name: "draw-circle"
            icon.color: timerRunning ? "red" : "white"
            property bool timerRunning: false

            onClicked: {
                if(!timerRunning) {
                    timerRunning = true
                    triggerGuiEvent("logger.skill.enable.auto.refresh", {})
                } else {
                    timerRunning = false
                    triggerGuiEvent("logger.skill.disable.auto.refresh", {})
                }
            }
        }
    }

    Rectangle {
        id: selectorBox
        color: "#313131"
        height: Mycroft.Units.gridUnit * 4
        anchors.top: searchBox.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 0
        anchors.leftMargin: Mycroft.Units.gridUnit * 2
        anchors.rightMargin: Mycroft.Units.gridUnit * 2

        RowLayout {
            anchors.fill: parent
            anchors.margins: Mycroft.Units.gridUnit * 0.5

            SelectorButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: busLogBtn
                icon.name: "document-preview"
                text: "Bus"
                currentSelection: sessionData.currentLog == "bus" ? 1 : 0

                onClicked: {
                    triggerGuiEvent("logger.skill.select.log", {selected: "bus"})
                }
            }
            SelectorButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: skillsLogBtn
                icon.name: "document-preview"
                text: "Skills"
                currentSelection: sessionData.currentLog == "skills" ? 1 : 0

                onClicked: {
                    triggerGuiEvent("logger.skill.select.log", {selected: "skills"})
                }
            }
            SelectorButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: voiceLogBtn
                icon.name: "document-preview"
                text: "Voice"
                currentSelection: sessionData.currentLog == "voice" ? 1 : 0

                onClicked: {
                    triggerGuiEvent("logger.skill.select.log", {selected: "voice"})
                }
            }
            SelectorButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: audioLogBtn
                icon.name: "document-preview"
                text: "Audio"
                currentSelection: sessionData.currentLog == "audio" ? 1 : 0

                onClicked: {
                    triggerGuiEvent("logger.skill.select.log", {selected: "audio"})
                }
            }
            SelectorButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: enclousreLogBtn
                icon.name: "document-preview"
                text: "Enclosure"
                currentSelection: sessionData.currentLog == "enclosure" ? 1 : 0

                onClicked: {
                    triggerGuiEvent("logger.skill.select.log", {selected: "enclosure"})
                }
            }

            Kirigami.Separator {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: Kirigami.Theme.backgroundColor
            }

            SelectorButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: exitLogBtn
                icon.name: "window-close-symbolic"
                text: "Exit"

                onClicked: {
                    triggerGuiEvent("logger.skill.close.logs", {})
                }
            }
        }
    }

    ListView {
        id: repeaterView
        anchors.top: selectorBox.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Mycroft.Units.gridUnit * 2
        spacing: 0
        model: KItemModels.KSortFilterProxyModel {
            id: ksortModel
            filterCaseSensitivity: Qt.CaseSensitive
            filterRole: "type"
            filterRegularExpression: {
                if (searchField.text === "") return new RegExp()
                return new RegExp("%1".arg(searchField.text), "i")
            }
        }
        ScrollBar.vertical: ScrollBar {
            active: true
        }
        delegate: Item {
            width: repeaterView.width
            height: textAre.paintedHeight

            Text {
                id: textAre
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Kirigami.Units.largeSpacing * 2
                text: model.timestamp + " | " + model.type + " | " + model.intentid + " | " + model.intent + " | " + model.content
                color: "white"
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }
        }

        clip: true

        onCountChanged: {
            positionViewAtIndex(count - 1, ListView.End)
        }
    }
}
