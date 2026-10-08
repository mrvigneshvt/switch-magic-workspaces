pragma ComponentBehavior: Bound
import QtQuick
import "../lib/Model.js" as Model

Item {
    id: root
    required property var view
    required property var themeColors
    property string fontFamily: "sans-serif"
    property int selected: 2
    property int count: view.engine === "grid" ? Math.min(64, view.geometry.columns * view.geometry.rows) : 5
    property real screenWidth: 1920
    property real screenHeight: 1080
    property bool interactive: true
    property bool heading: true
    readonly property var colors: ({surface: themeColors.surface, text: themeColors.text, muted: themeColors.muted, accent: view.scene.accent === "theme" ? themeColors.accent : view.scene.accent})
    readonly property var metrics: {
        var grid = view.engine === "grid";
        var m = Model.metrics(view.engine, view.geometry, count,
            grid ? Math.max(280, screenWidth - 100) : Math.max(view.geometry.width, view.geometry.cardWidth),
            grid ? Math.max(180, screenHeight - 300) : Math.max(800, count * (view.geometry.cardHeight + view.geometry.gap)));
        m.scale = Math.min(m.scale, Math.max(1, width - 24) / m.width, Math.max(1, height - (heading ? 100 : 16)) / m.height);
        return m;
    }
    onCountChanged: selected = Math.max(0, Math.min(selected, count - 1))
    readonly property int duration: view.animation.enabled ? view.animation.duration : 0
    readonly property int curve: view.animation.easing === "outBack" ? Easing.OutBack : view.animation.easing === "outQuint" ? Easing.OutQuint : view.animation.easing === "linear" ? Easing.Linear : Easing.OutCubic
    Brand { visible: root.heading; anchors.horizontalCenter: parent.horizontalCenter; y: 10; themeColors: root.colors; fontFamily: root.fontFamily; textSize: root.view.scene.headerSize; sparkleSize: root.view.scene.logoSize; tracking: root.view.scene.headerTracking; scale: 0.68; transformOrigin: Item.Top }
    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.heading ? 70 : 8
        width: root.metrics.width; height: root.metrics.height
        scale: root.metrics.scale; transformOrigin: Item.Top
        Repeater {
            model: root.count
            WindowCard {
                required property int index
                readonly property var position: Model.placement(root.view.engine, root.view.geometry, index, Math.min(root.selected, root.count - 1), root.count, root.metrics)
                x: position.x; y: position.y; width: position.width; height: position.height
                rotation: position.rotation; scale: position.scale; z: position.z; opacity: position.opacity
                visible: opacity > 0.01; enabled: root.interactive && position.visible
                transformOrigin: Item.Bottom
                windowInfo: ({ title: ["Design notes", "The next big idea", "Something wonderful", "A little inspiration", "Your next adventure"][index % 5], appId: ["org.gnome.TextEditor", "code", "firefox", "org.gnome.Nautilus", "com.mitchellh.ghostty"][index % 5], workspaceName: String(index + 1) })
                themeColors: root.colors; style: root.view.card; fontFamily: root.fontFamily
                compact: root.view.engine === "list"; selected: index === Math.min(root.selected, root.count - 1)
                previewMode: root.view.preview; sample: true; duration: root.duration
                onPicked: root.selected = index
                Behavior on x { NumberAnimation { duration: root.view.animation.position ? root.duration : 0; easing.type: root.curve } }
                Behavior on y { NumberAnimation { duration: root.view.animation.position ? root.duration : 0; easing.type: root.curve } }
                Behavior on rotation { NumberAnimation { duration: root.view.animation.rotation ? root.duration : 0; easing.type: root.curve } }
                Behavior on scale { NumberAnimation { duration: root.view.animation.scale ? root.duration : 0; easing.type: root.curve } }
                Behavior on opacity { NumberAnimation { duration: root.view.animation.opacity ? root.duration : 0 } }
            }
        }
    }
    Text { visible: root.heading && root.view.scene.showHints; anchors.bottom: parent.bottom; anchors.bottomMargin: 5; anchors.horizontalCenter: parent.horizontalCenter; text: "Design preview · click a card to switch"; color: root.themeColors.muted; font.family: root.fontFamily; font.pixelSize: 10 }
}
