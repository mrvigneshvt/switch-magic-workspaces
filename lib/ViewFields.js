// This declarative catalogue drives the editor, validation and JSON schema.
var groups = [
    { name: "Layout & tiles", fields: [
        { path: "engine", label: "Layout engine", type: "enum", options: ["list", "grid", "carousel", "fan"] },
        { path: "geometry.width", label: "Stage width", min: 320, max: 2400, step: 10, unit: "px", engines: ["list", "carousel", "fan"] },
        { path: "geometry.cardWidth", label: "Tile width", min: 100, max: 1000, step: 1, unit: "px" },
        { path: "geometry.cardHeight", label: "Tile height", min: 64, max: 600, step: 1, unit: "px" },
        { path: "geometry.gap", label: "Gap", min: 0, max: 80, step: 1, unit: "px", engines: ["list", "grid"] },
        { path: "geometry.maxVisible", label: "Visible tiles", min: 1, max: 15, step: 1, engines: ["list", "carousel", "fan"] },
        { path: "geometry.columns", label: "Maximum columns", min: 1, max: 8, step: 1, engines: ["grid"] },
        { path: "geometry.rows", label: "Maximum rows", min: 1, max: 8, step: 1, engines: ["grid"] },
        { path: "geometry.spread", label: "Card spread", min: 0, max: 600, step: 1, unit: "px", engines: ["carousel", "fan"] },
        { path: "geometry.angle", label: "Fan angle", min: 0, max: 25, step: 1, unit: "°", engines: ["fan"] },
        { path: "geometry.depth", label: "Depth offset", min: 0, max: 100, step: 1, unit: "px", engines: ["carousel", "fan"] },
        { path: "geometry.inactiveScale", label: "Unselected scale", min: 0.4, max: 1, step: 0.01 },
        { path: "geometry.inactiveOpacity", label: "Unselected opacity", min: 0.1, max: 1, step: 0.01 }
    ]},
    { name: "Edges & surfaces", fields: [
        { path: "card.radius", label: "Corner radius", min: 0, max: 48, step: 1, unit: "px" },
        { path: "card.borderWidth", label: "Border thickness", min: 0, max: 8, step: 1, unit: "px" },
        { path: "card.selectedBorderWidth", label: "Selected border", min: 0, max: 8, step: 1, unit: "px" },
        { path: "card.borderOpacity", label: "Border opacity", min: 0, max: 1, step: 0.01 },
        { path: "card.surfaceOpacity", label: "Surface opacity", min: 0.1, max: 1, step: 0.01 },
        { path: "card.tintOpacity", label: "Accent wash", min: 0, max: 0.6, step: 0.01 },
        { path: "card.padding", label: "Inner padding", min: 4, max: 32, step: 1, unit: "px" },
        { path: "card.shadowEnabled", label: "Shadows", type: "boolean" },
        { path: "card.shadowSize", label: "Shadow spread", min: 0, max: 32, step: 1, unit: "px" },
        { path: "card.shadowOpacity", label: "Shadow opacity", min: 0, max: 0.3, step: 0.01 }
    ]},
    { name: "Typography & labels", fields: [
        { path: "card.fontFamily", label: "Font family", type: "text", hint: "theme, or a font name", maxLength: 80 },
        { path: "card.titleSize", label: "Title size", min: 8, max: 32, step: 1, unit: "px" },
        { path: "card.subtitleSize", label: "App name size", min: 8, max: 24, step: 1, unit: "px" },
        { path: "card.titleWeight", label: "Title weight", type: "enum", options: ["normal", "medium", "semibold", "bold"] },
        { path: "card.textSpacing", label: "Label spacing", min: 0, max: 16, step: 1, unit: "px" },
        { path: "card.footerHeight", label: "Label area height", min: 32, max: 140, step: 1, unit: "px" },
        { path: "card.showTitle", label: "Window title", type: "boolean" },
        { path: "card.showSubtitle", label: "Application name", type: "boolean" },
        { path: "card.showWorkspace", label: "Workspace badge", type: "boolean" }
    ]},
    { name: "Previews & icons", fields: [
        { path: "preview", label: "Default preview", type: "enum", options: ["live", "snapshot", "hybrid", "icon"] },
        { path: "card.showIcon", label: "App icon beside title", type: "boolean" },
        { path: "card.iconSize", label: "App icon size", min: 16, max: 64, step: 1, unit: "px" },
        { path: "card.previewIconSize", label: "Fallback icon size", min: 24, max: 160, step: 1, unit: "px" },
        { path: "card.compactPreviewWidth", label: "List preview width", min: 40, max: 260, step: 1, unit: "px", engines: ["list"] },
        { path: "card.showPreviewBadge", label: "Live / still badge", type: "boolean" }
    ]},
    { name: "Motion", fields: [
        { path: "animation.enabled", label: "Animations", type: "boolean" },
        { path: "animation.duration", label: "Transition duration", min: 0, max: 1000, step: 10, unit: "ms" },
        { path: "animation.easing", label: "Easing", type: "enum", options: ["outCubic", "outQuint", "outBack", "linear"] },
        { path: "animation.position", label: "Animate positions", type: "boolean" },
        { path: "animation.scale", label: "Animate scaling", type: "boolean" },
        { path: "animation.rotation", label: "Animate rotation", type: "boolean" },
        { path: "animation.opacity", label: "Animate opacity", type: "boolean" },
        { path: "animation.entryDuration", label: "Entrance duration", min: 0, max: 1000, step: 10, unit: "ms" },
        { path: "animation.entryScale", label: "Entrance scale", min: 0.6, max: 1, step: 0.01 }
    ]},
    { name: "Atmosphere & heading", fields: [
        { path: "scene.accent", label: "Accent color", type: "color", hint: "theme or #rrggbb" },
        { path: "scene.dimOpacity", label: "Backdrop dimming", min: 0, max: 1, step: 0.01 },
        { path: "scene.headerSize", label: "Logo text size", min: 12, max: 32, step: 1, unit: "px" },
        { path: "scene.headerTracking", label: "Logo letter spacing", min: 0, max: 10, step: 0.5, unit: "px" },
        { path: "scene.logoSize", label: "Logo icon size", min: 16, max: 48, step: 1, unit: "px" },
        { path: "scene.showHints", label: "Keyboard hints", type: "boolean" }
    ]}
];
if (typeof module !== "undefined") module.exports = { groups: groups };
