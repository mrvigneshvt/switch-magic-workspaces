pragma ComponentBehavior: Bound
import QtQuick

Column {
    id: root
    required property var themeColors
    property string fontFamily: "sans-serif"
    property int textSize: 18
    property real tracking: 0
    property int sparkleSize: 30
    property bool showCredit: true
    spacing: 2
    width: wordmark.implicitWidth
    Row {
        id: wordmark
        spacing: 12
        BrandIcon { width: root.sparkleSize * 1.6; height: width; color: root.themeColors.accent }
        Text { text: "Switch Magic"; color: root.themeColors.text; font.family: root.fontFamily; font.pixelSize: root.textSize * 1.25; font.weight: Font.DemiBold; font.letterSpacing: root.tracking / 4; anchors.verticalCenter: parent.verticalCenter }
    }
    Text {
        visible: root.showCredit
        anchors.right: parent.right
        text: "by @renanmt"
        color: root.themeColors.muted
        font.family: root.fontFamily
        font.pixelSize: 10
        font.letterSpacing: 0.4
    }
}
