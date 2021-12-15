import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Window 2.12
import QtQuick.Shapes 1.12
import Mycroft 1.0 as Mycroft
import org.kde.kirigami 2.9 as Kirigami

Button {
    id: control
    property bool currentSelection

    background: Rectangle {
        Kirigami.Theme.colorSet: Kirigami.Theme.Button
        color: currentSelection ? Kirigami.Theme.linkColor : Kirigami.Theme.backgroundColor
        border.color: Kirigami.Theme.disabledTextColor
        border.width: 1
        radius: 3
    }
    contentItem: Item {
        Item {
            anchors.fill: parent

            Kirigami.Icon {
                id: btnIcon
                height: parent.height - (Kirigami.Units.largeSpacing * 2)
                width: height
                source: control.icon.name
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: btnLabel.left
                anchors.rightMargin: Kirigami.Units.smallSpacing / 2
            }

            Label {
                id: btnLabel
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: btnIcon.width / 2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: height * 0.375
                text: control.text
            }
        }
    }
}
