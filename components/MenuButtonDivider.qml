import QtQuick 2.9

import "." as MangonoteComponents
import "effects/" as MangonoteEffects

Rectangle {
    color: MangonoteComponents.Style.appWindowBorderColor
    height: 1

    MangonoteEffects.ColorTransition {
        targetObj: parent
        blackColor: MangonoteComponents.Style._b_appWindowBorderColor
        whiteColor: MangonoteComponents.Style._w_appWindowBorderColor
    }
}
