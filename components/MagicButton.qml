pragma ComponentBehavior: Bound
import QtQuick

Rectangle {
    id: root
    property string text: ""
    property bool chosen: false
    property color accent: "#99bbff"
    property color foreground: "white"
    property string fontFamily: "sans-serif"
    signal clicked()
    implicitWidth: label.implicitWidth + 30
    implicitHeight: 40
    activeFocusOnTab: true
    Keys.onReturnPressed: clicked()
    Keys.onSpacePressed: clicked()
    radius: 10
    color: chosen ? Qt.alpha(accent, 0.18) : mouse.containsMouse ? Qt.alpha(foreground, 0.08) : Qt.alpha(foreground, 0.035)
    border.width: 1
    border.color: (chosen || activeFocus) ? Qt.alpha(accent, 0.65) : Qt.alpha(foreground, 0.10)
    Text { id: label; anchors.centerIn: parent; text: root.text; color: root.chosen ? root.accent : root.foreground; font.family: root.fontFamily; font.pixelSize: 13; font.weight: root.chosen ? Font.DemiBold : Font.Normal }
    MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.clicked() }
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: clicked()
}
