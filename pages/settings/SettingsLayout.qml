// Copyright (c) 2024, The Mangonote developers
// Copyright (c) 2014-2018, The Monero Project
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
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2

import "../../js/Utils.js" as Utils
import "../../js/Windows.js" as Windows
import "../../components" as MangonoteComponents

Rectangle {
    color: "transparent"
    Layout.fillWidth: true
    property alias layoutHeight: settingsUI.height

    ColumnLayout {
        id: settingsUI
        property int itemHeight: 60
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        anchors.topMargin: 0
        spacing: 6

        MangonoteComponents.CheckBox {
            id: customDecorationsCheckBox
            checked: persistentSettings.customDecorations
            onClicked: Windows.setCustomWindowDecorations(checked)
            text: qsTr("Custom decorations") + translationManager.emptyString
        }

        MangonoteComponents.CheckBox {
            id: checkForUpdatesCheckBox
            enabled: !disableCheckUpdatesFlag
            checked: persistentSettings.checkForUpdates && !disableCheckUpdatesFlag
            onClicked: persistentSettings.checkForUpdates = !persistentSettings.checkForUpdates
            text: qsTr("Check for updates periodically") + translationManager.emptyString
        }

        MangonoteComponents.CheckBox {
            checked: persistentSettings.displayWalletNameInTitleBar
            onClicked: persistentSettings.displayWalletNameInTitleBar = !persistentSettings.displayWalletNameInTitleBar
            text: qsTr("Display wallet name in title bar") + translationManager.emptyString
        }

        MangonoteComponents.CheckBox {
            id: hideBalanceCheckBox
            checked: persistentSettings.hideBalance
            onClicked: {
                persistentSettings.hideBalance = !persistentSettings.hideBalance
                appWindow.updateBalance();
            }
            text: qsTr("Hide balance") + translationManager.emptyString
        }

        MangonoteComponents.CheckBox {
            id: themeCheckbox
            checked: !MangonoteComponents.Style.blackTheme
            text: qsTr("Light theme") + translationManager.emptyString
            toggleOnClick: false
            onClicked: {
                MangonoteComponents.Style.blackTheme = !MangonoteComponents.Style.blackTheme;
            }
        }
        
        MangonoteComponents.CheckBox {
            checked: persistentSettings.askPasswordBeforeSending
            text: qsTr("Ask for password before sending a transaction") + translationManager.emptyString
            toggleOnClick: false
            onClicked: {
                if (persistentSettings.askPasswordBeforeSending) {
                    passwordDialog.onAcceptedCallback = function() {
                        if (appWindow.walletPassword === passwordDialog.password){
                            persistentSettings.askPasswordBeforeSending = false;
                        } else {
                            passwordDialog.showError(qsTr("Wrong password"));
                        }
                    }
                    passwordDialog.onRejectedCallback = null;
                    passwordDialog.open()
                } else {
                    persistentSettings.askPasswordBeforeSending = true;
                }
            }
        }

        MangonoteComponents.CheckBox {
            checked: persistentSettings.autosave
            onClicked: persistentSettings.autosave = !persistentSettings.autosave
            text: qsTr("Autosave") + translationManager.emptyString
        }

        MangonoteComponents.Slider {
            Layout.fillWidth: true
            Layout.leftMargin: 35
            Layout.topMargin: 6
            visible: persistentSettings.autosave
            from: 1
            stepSize: 1
            to: 60
            value: persistentSettings.autosaveMinutes
            text: "%1 %2 %3".arg(qsTr("Every")).arg(value).arg(qsTr("minute(s)")) + translationManager.emptyString
            onMoved: persistentSettings.autosaveMinutes = value
        }

        MangonoteComponents.CheckBox {
            id: userInActivityCheckbox
            checked: persistentSettings.lockOnUserInActivity
            onClicked: persistentSettings.lockOnUserInActivity = !persistentSettings.lockOnUserInActivity
            text: qsTr("Lock wallet on inactivity") + translationManager.emptyString
        }

        MangonoteComponents.Slider {
            visible: userInActivityCheckbox.checked
            Layout.fillWidth: true
            Layout.topMargin: 6
            Layout.leftMargin: 35
            from: 1
            stepSize: 1
            to: 60
            value: persistentSettings.lockOnUserInActivityInterval
            text: {
                var minutes = value > 1 ? qsTr("minutes") : qsTr("minute");
                return qsTr("After ") + value + " " + minutes + translationManager.emptyString;
            }
            onMoved: persistentSettings.lockOnUserInActivityInterval = value
        }

        MangonoteComponents.CheckBox {
            checked: persistentSettings.askStopLocalNode
            onClicked: persistentSettings.askStopLocalNode = !persistentSettings.askStopLocalNode
            text: qsTr("Ask to stop local node during program exit") + translationManager.emptyString
        }

        //! Manage pricing
        RowLayout {
            MangonoteComponents.CheckBox {
                id: enableConvertCurrency
                text: qsTr("Enable displaying balance in other currencies") + translationManager.emptyString
                checked: persistentSettings.fiatPriceEnabled
                onCheckedChanged: {
                    if (!checked) {
                        console.log("Disabled price conversion");
                        persistentSettings.fiatPriceEnabled = false;
                    }
                }
            }
        }

        GridLayout {
            visible: enableConvertCurrency.checked
            columns: 2
            Layout.fillWidth: true
            Layout.leftMargin: 36
            columnSpacing: 32

            MangonoteComponents.StandardDropdown {
                id: fiatPriceProviderDropDown
                Layout.maximumWidth: 200
                labelText: qsTr("Price source") + translationManager.emptyString
                labelFontSize: 14
                dataModel: fiatPriceProvidersModel
                onChanged: {
                    var obj = dataModel.get(currentIndex);
                    persistentSettings.fiatPriceProvider = obj.data;

                    if(persistentSettings.fiatPriceEnabled)
                        appWindow.fiatApiRefresh();
                }
            }

            MangonoteComponents.StandardDropdown {
                id: fiatPriceCurrencyDropdown
                Layout.maximumWidth: 100
                labelText: qsTr("Currency") + translationManager.emptyString
                labelFontSize: 14
                currentIndex: persistentSettings.fiatPriceCurrency === "mnnusd" ? 0 : 1
                dataModel: fiatPriceCurrencyModel
                onChanged: {
                    var obj = dataModel.get(currentIndex);
                    persistentSettings.fiatPriceCurrency = obj.data;

                    if(persistentSettings.fiatPriceEnabled)
                        appWindow.fiatApiRefresh();
                }
            }

            z: parent.z + 1
        }

        ColumnLayout {
            // Feature needs to be double enabled for security purposes (miss-clicks)
            visible: enableConvertCurrency.checked && !persistentSettings.fiatPriceEnabled
            spacing: 0
            Layout.topMargin: 5
            Layout.leftMargin: 36

            MangonoteComponents.WarningBox {
                text: qsTr("Enabling price conversion exposes your IP address to the selected price source.") + translationManager.emptyString;
            }

            MangonoteComponents.StandardButton {
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                small: true
                text: qsTr("Confirm and enable") + translationManager.emptyString

                onClicked: {
                    console.log("Enabled price conversion");
                    persistentSettings.fiatPriceEnabled = true;
                }
            }
        }

        MangonoteComponents.CheckBox {
            id: proxyCheckbox
            Layout.topMargin: 6
            enabled: !socksProxyFlagSet
            checked: socksProxyFlagSet ? socksProxyFlag : persistentSettings.proxyEnabled
            onClicked: {
                persistentSettings.proxyEnabled = !persistentSettings.proxyEnabled;
            }
            text: qsTr("Socks5 proxy (%1%2)")
                .arg(appWindow.walletMode >= 2 ? qsTr("remote node connections, ") : "")
                .arg(qsTr("updates downloading, fetching price sources")) + translationManager.emptyString
        }

        MangonoteComponents.RemoteNodeEdit {
            id: proxyEdit
            enabled: proxyCheckbox.enabled
            Layout.leftMargin: 36
            Layout.topMargin: 6
            Layout.minimumWidth: 100
            placeholderFontSize: 15
            visible: proxyCheckbox.checked

            daemonAddrLabelText: qsTr("IP address") + translationManager.emptyString
            daemonPortLabelText: qsTr("Port") + translationManager.emptyString

            initialAddress: socksProxyFlagSet ? socksProxyFlag : persistentSettings.proxyAddress
            onEditingFinished: {
                persistentSettings.proxyAddress = proxyEdit.getAddress();
            }
        }

        MangonoteComponents.StandardButton {
            visible: !persistentSettings.customDecorations
            Layout.topMargin: 10
            small: true
            text: qsTr("Change language") + translationManager.emptyString

            onClicked: {
                appWindow.toggleLanguageView();
            }
        }
    }

    ListModel {
        id: fiatPriceProvidersModel
    }

    ListModel {
        id: fiatPriceCurrencyModel
        ListElement {
            data: "mnnusd"
            column1: "USD"
        }
        ListElement {
            data: "mnneur"
            column1: "EUR"
        }
    }

    Component.onCompleted: {
        // Dynamically fill fiatPrice dropdown based on `appWindow.fiatPriceAPIs`
        var apis = appWindow.fiatPriceAPIs;
        fiatPriceProvidersModel.clear();

        var i = 0;
        for (var api in apis){
            if (!apis.hasOwnProperty(api))
               continue;

            fiatPriceProvidersModel.append({"column1": Utils.capitalize(api), "data": api});

            if(api === persistentSettings.fiatPriceProvider)
                fiatPriceProviderDropDown.currentIndex = i;
            i += 1;
        }

        console.log('SettingsLayout loaded');
    }
}

