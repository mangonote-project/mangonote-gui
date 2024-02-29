import QtQuick 2.9
import QtQuick.Controls 2.2

import FontAwesome 1.0
import "../components" as MangonoteComponents

MouseArea {
    signal cut()
    signal copy()
    signal paste()
    signal remove()
    signal selectAll()

    id: root
    acceptedButtons: Qt.RightButton
    anchors.fill: parent
    onClicked: {
        if (mouse.button === Qt.RightButton) {
            root.parent.persistentSelection = true;
            contextMenu.open()
            root.parent.cursorVisible = true;
        }
    }

    Menu {
        id: contextMenu

        background: Rectangle {
            border.color: MangonoteComponents.Style.buttonBackgroundColorDisabledHover
            border.width: 1
            radius: 2
            color: MangonoteComponents.Style.blackTheme ? MangonoteComponents.Style.buttonBackgroundColorDisabled : "#E5E5E5"
        }

        padding: 1
        width: 110
        x: root.mouseX
        y: root.mouseY

        onClosed: {
            if (!root.parent.activeFocus) {
                root.parent.cursorVisible = false;
            }
            root.parent.persistentSelection = false;
            root.parent.forceActiveFocus()
        }

        MangonoteComponents.ContextMenuItem {
            enabled: root.parent.selectedText != "" && !root.parent.readOnly
            onTriggered: root.cut()
            text: qsTr("Cut") + translationManager.emptyString
        }

        MangonoteComponents.ContextMenuItem {
            enabled: root.parent.selectedText != ""
            onTriggered: root.copy()
            text: qsTr("Copy") + translationManager.emptyString
        }

        MangonoteComponents.ContextMenuItem {
            enabled: root.parent.canPaste === true
            onTriggered: root.paste()
            text: qsTr("Paste") + translationManager.emptyString
        }

        MangonoteComponents.ContextMenuItem {
            enabled: root.parent.selectedText != "" && !root.parent.readOnly
            onTriggered: root.remove()
            text: qsTr("Delete") + translationManager.emptyString
        }

        MangonoteComponents.ContextMenuItem {
            enabled: root.parent.text != ""
            onTriggered: root.selectAll()
            text: qsTr("Select All") + translationManager.emptyString
        }
    }
}
