pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

Item {
    id: root
    required property var workspace
    required property var themeColors
    required property var style
    required property string previewMode
    required property var captureFor
    property bool selected: false
    property int duration: 180
    property string fontFamily: "sans-serif"
    signal picked()
    signal hovered()
    readonly property var windows: workspace.windows || []
    readonly property int radius: style.radius

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Qt.alpha(root.themeColors.surface, root.style.surfaceOpacity)
        border.width: root.selected ? root.style.selectedBorderWidth : root.style.borderWidth
        border.color: root.selected ? root.themeColors.accent : Qt.alpha(root.themeColors.text, root.style.borderOpacity)
        Behavior on border.color { ColorAnimation { duration: root.duration } }
    }
    Item {
        id: previewGrid
        x: root.style.padding
        y: root.style.padding
        width: parent.width - root.style.padding * 2
        height: parent.height - root.style.footerHeight - root.style.padding * 2
        Repeater {
            model: Math.min(root.windows.length, 4)
            ClippingRectangle {
                required property int index
                readonly property var windowInfo: root.windows[index]
                width: (previewGrid.width - 5) / 2
                height: (previewGrid.height - 5) / 2
                x: (index % 2) * (width + 5)
                y: Math.floor(index / 2) * (height + 5)
                radius: 5
                color: Qt.alpha(root.themeColors.text, 0.05)
                ScreencopyView {
                    id: screenshot
                    anchors.fill: parent
                    captureSource: root.captureFor(windowInfo.address)
                    live: root.previewMode === "live" || (root.previewMode === "hybrid" && root.selected)
                    constraintSize: Qt.size(parent.width, parent.height)
                    paintCursor: false
                }
                Rectangle {
                    anchors.fill: parent
                    visible: !screenshot.hasContent
                    color: Qt.alpha(root.themeColors.accent, 0.08)
                    Text { anchors.centerIn: parent; text: (windowInfo.appId || "•").slice(0, 1).toUpperCase(); color: root.themeColors.accent; font.pixelSize: 18 }
                }
            }
        }
        Text {
            anchors.centerIn: parent
            visible: root.windows.length === 0
            text: "Empty space"
            color: root.themeColors.muted
            font.family: root.fontFamily
            font.pixelSize: 12
        }
        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            visible: root.windows.length > 4
            width: moreText.implicitWidth + 14
            height: 22
            radius: 7
            color: Qt.alpha(root.themeColors.surface, 0.94)
            Text { id: moreText; anchors.centerIn: parent; text: "+" + (root.windows.length - 4); color: root.themeColors.text; font.family: root.fontFamily; font.pixelSize: 10 }
        }
    }
    Row {
        x: root.style.padding + 3
        y: parent.height - root.style.footerHeight + (root.style.footerHeight - height) / 2
        width: parent.width - root.style.padding * 2 - 6
        spacing: 8
        Rectangle {
            width: 30; height: 30; radius: 9
            color: root.workspace.active ? Qt.alpha(root.themeColors.accent, 0.2) : Qt.alpha(root.themeColors.text, 0.06)
            Text { anchors.centerIn: parent; text: String(root.workspace.id); color: root.workspace.active ? root.themeColors.accent : root.themeColors.muted; font.family: root.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold }
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 38
            Text { width: parent.width; text: root.workspace.name === String(root.workspace.id) ? "Workspace " + root.workspace.name : root.workspace.name; color: root.themeColors.text; font.family: root.fontFamily; font.pixelSize: root.style.titleSize; font.weight: Font.DemiBold; elide: Text.ElideRight }
            Text { width: parent.width; text: root.windows.length + (root.windows.length === 1 ? " window" : " windows"); color: root.themeColors.muted; font.family: root.fontFamily; font.pixelSize: root.style.subtitleSize; elide: Text.ElideRight }
        }
    }
    MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onPositionChanged: if (containsMouse) root.hovered(); onClicked: root.picked() }
    Accessible.role: Accessible.ListItem
    Accessible.name: "Workspace " + root.workspace.name + ", " + root.windows.length + " windows"
    Accessible.selected: root.selected
}
