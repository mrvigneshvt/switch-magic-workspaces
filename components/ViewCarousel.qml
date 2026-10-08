pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../lib/Model.js" as Model

Item {
    id: root
    required property var config
    required property var themeColors
    property string fontFamily: "sans-serif"
    property real screenWidth: 1920
    property real screenHeight: 1080
    property string selectedId: "carousel"
    signal picked(string id)
    readonly property var views: Model.catalog(config)
    readonly property bool overflowing: views.length * 196 + Math.max(0, views.length - 1) * 12 > width
    implicitHeight: 208
    function revealSelected() {
        var index = views.findIndex(function(v) { return v.id === root.selectedId; });
        if (index >= 0) cards.positionViewAtIndex(index, ListView.Contain);
    }
    onSelectedIdChanged: Qt.callLater(revealSelected)
    onViewsChanged: Qt.callLater(revealSelected)
    MagicButton { visible: root.overflowing && !cards.atXBeginning; width: 32; height: 36; anchors.left: parent.left; anchors.verticalCenter: cards.verticalCenter; text: "‹"; accent: root.themeColors.accent; foreground: root.themeColors.text; onClicked: cards.contentX = Math.max(0, cards.contentX - 210) }
    ListView {
        id: cards
        x: root.overflowing ? 44 : 0; width: parent.width - (root.overflowing ? 88 : 0); height: 186; clip: true
        orientation: ListView.Horizontal; spacing: 12; boundsBehavior: Flickable.StopAtBounds
        model: root.views; snapMode: ListView.SnapToItem
        ScrollBar.horizontal: ScrollBar { }
        delegate: Rectangle {
            id: tile
            required property var modelData
            required property int index
            width: 196; height: 173; radius: 15
            color: modelData.id === root.selectedId ? Qt.alpha(root.themeColors.accent, .10) : Qt.alpha(root.themeColors.text, .025)
            border.width: 1; border.color: modelData.id === root.selectedId || activeFocus ? Qt.alpha(root.themeColors.accent, .75) : Qt.alpha(root.themeColors.text, .1)
            ViewPreview { x: 8; y: 5; width: parent.width - 16; height: 110; view: tile.modelData; themeColors: root.themeColors; fontFamily: root.fontFamily; interactive: false; heading: false; count: 6; screenWidth: root.screenWidth; screenHeight: root.screenHeight }
            Text { x: 13; y: 117; width: parent.width - 26; text: tile.modelData.name; textFormat: Text.PlainText; elide: Text.ElideRight; color: root.themeColors.text; font.family: root.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold }
            Text { x: 13; y: 142; text: Model.builtin(root.config, tile.modelData.id) ? "BUILT-IN  ·  READ-ONLY" : "CUSTOM VIEW"; color: root.themeColors.muted; font.family: root.fontFamily; font.pixelSize: 8; font.letterSpacing: .7 }
            activeFocusOnTab: true
            Keys.onReturnPressed: root.picked(modelData.id)
            Keys.onSpacePressed: root.picked(modelData.id)
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.picked(tile.modelData.id) }
            Accessible.role: Accessible.Button
            Accessible.name: modelData.name
            Accessible.onPressAction: root.picked(modelData.id)
        }
        Component.onCompleted: Qt.callLater(root.revealSelected)
    }
    MagicButton { visible: root.overflowing && !cards.atXEnd; width: 32; height: 36; anchors.right: parent.right; anchors.verticalCenter: cards.verticalCenter; text: "›"; accent: root.themeColors.accent; foreground: root.themeColors.text; onClicked: cards.contentX = Math.max(0, Math.min(cards.contentWidth - cards.width, cards.contentX + 210)) }
    Text { anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; text: root.views.length + (root.overflowing ? " views · scroll to explore" : " views"); color: root.themeColors.muted; font.family: root.fontFamily; font.pixelSize: 10 }
}
