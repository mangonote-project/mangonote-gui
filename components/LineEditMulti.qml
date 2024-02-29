// Copyright (c) 2024, The Mangonote developers
// Copyright (c) 2014-2019, The Monero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.9
import QtQuick.Layouts 1.1

import "../components" as MangonoteComponents

ColumnLayout {
    id: item

    Layout.fillWidth: true

    default property alias content: inlineButtons.children

    property alias text: input.text
    property alias labelText: inputLabel.text
    property alias labelButtonText: labelButton.text
    property alias placeholderText: placeholderLabel.text

    property int inputPaddingLeft: 10
    property int inputPaddingRight: 10
    property int inputPaddingTop: 10
    property int inputPaddingBottom: 10
    property int inputRadius: 4

    property bool placeholderCenter: false
    property string placeholderFontFamily: MangonoteComponents.Style.fontRegular.name
    property bool placeholderFontBold: false
    property int placeholderFontSize: 18
    property string placeholderColor: MangonoteComponents.Style.defaultFontColor
    property real placeholderOpacity: 0.35

    property bool borderDisabled: false
    property string borderColor: {
        if(input.error && input.text !== ""){
            return MangonoteComponents.Style.inputBorderColorInvalid;
        } else if(input.activeFocus){
            return MangonoteComponents.Style.inputBorderColorActive;
        } else {
            return MangonoteComponents.Style.inputBorderColorInActive;
        }
    }

    property alias error: input.error
    property alias cursorPosition: input.cursorPosition

    property string labelFontColor: MangonoteComponents.Style.defaultFontColor
    property bool labelFontBold: false
    property int labelFontSize: 16
    property bool labelButtonVisible: false

    property string fontColor: MangonoteComponents.Style.defaultFontColor
    property string fontFamily: MangonoteComponents.Style.fontRegular.name
    property bool fontBold: false
    property int fontSize: 16

    property bool mouseSelection: true
    property alias readOnly: input.readOnly
    property bool copyButton: false
    property bool pasteButton: false
    property bool showingHeader: labelText != "" || copyButton || pasteButton
    property var wrapMode: Text.NoWrap
    property alias addressValidation: input.addressValidation
    property string backgroundColor: "" // mock

    signal labelButtonClicked();
    signal inputLabelLinkActivated();
    signal editingFinished();
    signal returnPressed();
    signal enterPressed();

    onActiveFocusChanged: activeFocus && input.forceActiveFocus()

    spacing: 0
    Rectangle {
        id: inputLabelRect
        color: "transparent"
        Layout.fillWidth: true
        height: (inputLabel.height + 10)
        visible: showingHeader ? true : false

        MangonoteComponents.TextPlain {
            id: inputLabel
            anchors.top: parent.top
            anchors.left: parent.left
            font.family: MangonoteComponents.Style.fontRegular.name
            font.pixelSize: item.labelFontSize
            font.bold: labelFontBold
            textFormat: Text.RichText
            color: item.labelFontColor
            onLinkActivated: inputLabelLinkActivated()

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }

        RowLayout {
            anchors.right: parent.right
            spacing: 16

            MangonoteComponents.LabelButton {
                id: labelButton
                onClicked: labelButtonClicked()
                visible: labelButtonVisible
            }

            MangonoteComponents.LabelButton {
                id: copyButtonId
                visible: copyButton && input.text !== ""
                text: qsTr("Copy") + translationManager.emptyString
                onClicked: {
                    if (input.text.length > 0) {
                        console.log("Copied to clipboard");
                        clipboard.setText(input.text);
                        appWindow.showStatusMessage(qsTr("Copied to clipboard"), 3);
                    }
                }
            }

            MangonoteComponents.LabelButton {
                id: pasteButtonId
                onClicked: {
                    input.clear();
                    input.paste();
                }
                text: qsTr("Paste") + translationManager.emptyString
                visible: pasteButton
            }
        }
    }

    MangonoteComponents.InputMulti {
        id: input
        readOnly: false
        addressValidation: false
        KeyNavigation.backtab: item.KeyNavigation.backtab
        KeyNavigation.priority: KeyNavigation.BeforeItem
        KeyNavigation.tab: item.KeyNavigation.tab
        Layout.fillWidth: true

        leftPadding: item.inputPaddingLeft
        rightPadding: (inlineButtons.width > 0 ? inlineButtons.width + inlineButtons.spacing : 0) + inputPaddingRight
        topPadding: item.inputPaddingTop
        bottomPadding: item.inputPaddingBottom

        wrapMode: item.wrapMode
        font.family: item.fontFamily
        fontSize: item.fontSize
        fontBold: item.fontBold
        fontColor: item.fontColor
        mouseSelection: item.mouseSelection
        onEditingFinished: item.editingFinished()
        Keys.onReturnPressed: item.returnPressed()
        Keys.onEnterPressed: item.enterPressed()

        MangonoteComponents.TextPlain {
            id: placeholderLabel
            visible: input.text ? false : true
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            opacity: item.placeholderOpacity
            color: item.placeholderColor
            font.family: item.placeholderFontFamily
            font.bold: item.placeholderFontBold
            font.pixelSize: item.placeholderFontSize
            text: ""
            z: 3
        }

        Rectangle {
            color: "transparent"
            border.width: 1
            border.color: item.borderColor
            radius: item.inputRadius
            anchors.fill: parent
            visible: !item.borderDisabled
        }

        RowLayout {
            id: inlineButtons
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: inputPaddingRight
            spacing: 4
        }
    }
}
