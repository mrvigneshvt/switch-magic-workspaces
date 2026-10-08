pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property color color: "white"
    implicitWidth: 48
    implicitHeight: 48
    // Vector recreation of the supplied icon: stacked windows and a spark.
    Shape {
        width: 100; height: 102
        scale: Math.min(root.width / width, root.height / height)
        transformOrigin: Item.TopLeft
        x: (root.width - width * scale) / 2
        y: (root.height - height * scale) / 2
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeWidth: -1; fillColor: root.color
            PathSvg { path: "M0 32 C0 28 3 26 7 26 L12 26 L12 77 L6 77 C2 77 0 74 0 70 Z" }
        }
        ShapePath {
            strokeWidth: -1; fillColor: root.color
            PathSvg { path: "M17.5 23 C17.5 16 23 11.5 29 13.5 L36 16 C39 17 39.5 19 39.5 22 L39.5 80 C39.5 83 38 85 35 86 L28 88 C22 90 17.5 86 17.5 80 Z" }
        }
        ShapePath {
            strokeWidth: -1; fillColor: root.color
            PathSvg { path: "M37.5 5 C37.5 1 40 -1 44 0.5 L94 18 C98 19.5 100 22 100 26 L100 77 C100 81 98 83 94 84.5 L44 100 C39 102 37 99 37 96 L37 93 C37 90 39 88 42 87 L88 73 C90 72.5 90.5 72 90.5 70 L90.5 29 C90.5 27.5 90 27 88 26.5 L41 12 C38 11 37.5 9.5 37.5 7 Z" }
        }
        ShapePath {
            strokeWidth: -1; fillColor: root.color
            PathSvg { path: "M65 35 C63 44 61 48 50 50 C60 53 63 57 65 66 C67 57 70 53 80 50 C70 48 67 44 65 35 Z" }
        }
    }
}
