import QtQuick 2.9

import "../components" as MangonoteComponents

TextEdit {
    color: MangonoteComponents.Style.defaultFontColor
    font.family: MangonoteComponents.Style.fontRegular.name
    selectionColor: MangonoteComponents.Style.textSelectionColor
    wrapMode: Text.Wrap
    readOnly: true
    selectByMouse: true
    // Workaround for https://bugreports.qt.io/browse/QTBUG-50587
    onFocusChanged: {
        if(focus === false)
            deselect()
    }
}
