pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

Item {
    id: root
    required property var windowInfo
    required property var themeColors
    property var captureTarget: null
    property bool selected: false
    property bool compact: false
    property bool capturing: false
    property bool hoverSelect: false
    property bool showWorkspace: true
    property string previewMode: "live"
    required property var style
    property bool sample: false
    readonly property int radius: style.radius
    readonly property string cardFont: style.fontFamily === "theme" ? fontFamily : style.fontFamily
    readonly property int titleWeight: style.titleWeight === "bold" ? Font.Bold : style.titleWeight === "semibold" ? Font.DemiBold : style.titleWeight === "medium" ? Font.Medium : Font.Normal
    readonly property real labelHeight: (style.showTitle ? style.titleSize * 1.3 : 0) + (style.showSubtitle ? style.subtitleSize * 1.3 : 0) + (style.showTitle && style.showSubtitle ? style.textSpacing : 0)
    property int duration: 180
    property string fontFamily: "sans-serif"
    signal picked()
    signal hovered()
    readonly property var desktopEntry: DesktopEntries.heuristicLookup(windowInfo.appId || "")
    readonly property string appName: desktopEntry ? desktopEntry.name : windowInfo.appId || "Application"
    readonly property string appIcon: desktopEntry && desktopEntry.icon ? Quickshell.iconPath(desktopEntry.icon, true) : ""

    // Broad, low-opacity layers give the floating cards depth without a full
    // screen-sized blur texture for each live capture.
    Repeater {
        model: root.style.shadowEnabled ? 3 : 0
        Rectangle {
            required property int index
            x: -(index + 1) * root.style.shadowSize / 3; y: 5 + index * root.style.shadowSize / 4
            width: root.width + (index + 1) * root.style.shadowSize * 2 / 3; height: root.height + (index + 1) * root.style.shadowSize / 3
            radius: root.radius + 4 + index * 4
            color: root.selected ? Qt.alpha(root.themeColors.accent, root.style.shadowOpacity * 0.8) : Qt.rgba(0, 0, 0, root.style.shadowOpacity)
        }
    }
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Qt.alpha(root.themeColors.surface, root.style.surfaceOpacity)
        border.width: root.selected ? root.style.selectedBorderWidth : root.style.borderWidth
        border.color: root.selected ? root.themeColors.accent : Qt.alpha(root.themeColors.text, root.style.borderOpacity)
        Behavior on border.color { ColorAnimation { duration: root.duration } }
        Rectangle {
            anchors.fill: parent; anchors.margins: 2; radius: Math.max(0, root.radius - 2)
            gradient: Gradient {
                GradientStop { position: 0; color: Qt.alpha(root.themeColors.accent, root.selected ? root.style.tintOpacity : root.style.tintOpacity / 4) }
                GradientStop { position: 1; color: "transparent" }
            }
        }
    }
    ClippingRectangle {
        id: preview
        x: root.style.padding; y: root.style.padding
        width: Math.max(1, root.compact ? Math.min(root.style.compactPreviewWidth, root.width * 0.45) : root.width - root.style.padding * 2)
        height: Math.max(1, root.compact ? root.height - root.style.padding * 2 : root.height - root.style.footerHeight - root.style.padding * 2)
        radius: Math.max(0, root.radius - root.style.padding)
        color: Qt.alpha(root.themeColors.text, 0.035)
        Loader {
            id: captureLoader
            anchors.fill: parent
            active: root.capturing && root.previewMode !== "icon" && !!root.captureTarget
            sourceComponent: Component {
                ScreencopyView {
                    id: capture
                    captureSource: root.captureTarget
                    live: root.previewMode === "live" || (root.previewMode === "hybrid" && root.selected)
                    constraintSize: Qt.size(preview.width, preview.height)
                    width: implicitWidth
                    height: implicitHeight
                    anchors.centerIn: parent
                    paintCursor: false
                }
            }
        }
        Item {
            anchors.fill: parent
            visible: !root.sample && (!captureLoader.item || !captureLoader.item.hasContent) || root.previewMode === "icon"
            Rectangle {
                width: Math.min(root.style.previewIconSize, parent.width - 8, parent.height - 8); height: width; radius: width * 0.26
                anchors.centerIn: parent
                color: Qt.alpha(root.themeColors.accent, 0.10)
                border.width: 1; border.color: Qt.alpha(root.themeColors.accent, 0.14)
                Image { id: largeIcon; anchors.centerIn: parent; width: parent.width * 0.62; height: width; source: root.appIcon; fillMode: Image.PreserveAspectFit; visible: status === Image.Ready }
                Text { anchors.centerIn: parent; visible: !largeIcon.visible; text: root.appName.slice(0, 1).toUpperCase(); color: root.themeColors.accent; font.pixelSize: Math.max(12, parent.width * 0.43); font.family: root.cardFont }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 12
                visible: !root.compact && root.previewMode !== "icon"
                text: root.captureTarget ? "Waiting for preview" : "Preview unavailable"
                color: root.themeColors.muted; font.pixelSize: 10; font.family: root.cardFont
            }
        }
        Item {
            anchors.fill: parent
            visible: root.sample && root.previewMode !== "icon"
            Rectangle { anchors.fill: parent; color: Qt.tint(root.themeColors.surface, Qt.alpha(root.themeColors.accent, 0.07)) }
            Rectangle { x: 0; y: 0; width: parent.width; height: 24; color: Qt.alpha(root.themeColors.text, 0.06)
                Row { x: 10; anchors.verticalCenter: parent.verticalCenter; spacing: 5
                    Repeater { model: 3; Rectangle { width: 5; height: 5; radius: 3; color: Qt.alpha(root.themeColors.accent, 0.6) } }
                }
            }
            Rectangle { x: 12; y: 38; width: parent.width * 0.22; height: Math.max(4, parent.height - 50); radius: 4; color: Qt.alpha(root.themeColors.accent, 0.06) }
            Column { id: sampleLines; x: parent.width * 0.29; y: 40; width: parent.width * 0.64; spacing: 10
                Repeater { model: 6
                    Rectangle { required property int index; width: sampleLines.width * (0.45 + (index % 3) * 0.2); height: 6; radius: 3; color: Qt.alpha(root.themeColors.accent, index === 0 ? 0.6 : 0.16) }
                }
            }
        }
        Rectangle {
            visible: root.style.showPreviewBadge && !root.compact && root.previewMode !== "icon" && (root.sample || (captureLoader.item && captureLoader.item.hasContent))
            anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 9
            width: badge.implicitWidth + 16; height: 22; radius: 6
            color: Qt.alpha(root.themeColors.surface, 0.92)
            Text { id: badge; anchors.centerIn: parent; text: root.previewMode === "live" || (root.previewMode === "hybrid" && root.selected) ? "• LIVE" : "STILL"; color: root.themeColors.accent; font.pixelSize: 9; font.letterSpacing: 1; font.family: root.cardFont }
        }
    }
    Item {
        x: root.compact ? preview.x + preview.width + root.style.padding : root.style.padding + 8
        y: root.compact ? (parent.height - root.labelHeight) / 2 : parent.height - root.style.footerHeight + (root.style.footerHeight - root.labelHeight) / 2 - root.style.padding / 2
        width: Math.max(1, parent.width - x - root.style.padding); height: root.labelHeight; clip: true
        Image { id: smallIcon; y: Math.max(0, (root.labelHeight - height) / 2); width: root.style.iconSize; height: width; visible: root.style.showIcon && !root.compact && status === Image.Ready; source: root.appIcon; fillMode: Image.PreserveAspectFit }
        Column {
            x: smallIcon.visible ? root.style.iconSize + 11 : 0; width: parent.width - x - (root.style.showWorkspace ? 38 : 0); spacing: root.style.textSpacing
            Text { visible: root.style.showTitle; width: parent.width; text: root.windowInfo.title || root.appName; elide: Text.ElideRight; color: root.themeColors.text; font.family: root.cardFont; font.pixelSize: root.style.titleSize; font.weight: root.titleWeight; textFormat: Text.PlainText }
            Text { visible: root.style.showSubtitle; width: parent.width; text: root.appName; elide: Text.ElideRight; color: root.selected ? root.themeColors.accent : root.themeColors.muted; font.family: root.cardFont; font.pixelSize: root.style.subtitleSize; textFormat: Text.PlainText }
        }
        Rectangle {
            visible: root.style.showWorkspace; anchors.right: parent.right; y: 6
            width: 30; height: 30; radius: 9; color: Qt.alpha(root.themeColors.text, 0.06)
            Text { anchors.centerIn: parent; text: root.windowInfo.workspaceName; color: root.themeColors.muted; font.pixelSize: 11; font.family: root.cardFont; elide: Text.ElideRight; width: 25; horizontalAlignment: Text.AlignHCenter; textFormat: Text.PlainText }
        }
    }
    MouseArea {
        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
        onPositionChanged: if (root.hoverSelect && containsMouse) root.hovered()
        onClicked: root.picked()
    }
    Accessible.role: Accessible.ListItem
    Accessible.name: root.appName + ": " + root.windowInfo.title
    Accessible.selected: root.selected
}
