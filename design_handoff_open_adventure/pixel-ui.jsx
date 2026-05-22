/* eslint-disable */
// pixel-ui.jsx — shared atoms for Open Adventure design system
// Pixel-art chrome, sans-serif body. Dark cave aesthetic with lantern accent.

// ───────────────────────────────────────────────────────────
// ICONOGRAPHY · Tiny pixel-style icons drawn as SVG rect grids
// 16x16 viewBox, 1px = 1 pixel. Use currentColor.
// ───────────────────────────────────────────────────────────
const PixIcon = ({ d, size = 16, color = "currentColor", style = {} }) => {
  // d = array of [x,y] coordinates of filled pixels in a 16x16 grid
  return (
    <svg width={size} height={size} viewBox="0 0 16 16"
         style={{ display: "block", shapeRendering: "crispEdges", ...style }}
         className="pixelated">
      {d.map(([x, y, w = 1, h = 1], i) => (
        <rect key={i} x={x} y={y} width={w} height={h} fill={color} />
      ))}
    </svg>
  );
};

// Icon library — chunky pixel pictograms
const ICONS = {
  // Compass arrow (north)
  north:  [[7,2,2,1],[6,3,4,1],[5,4,6,1],[7,5,2,1],[7,6,2,1],[7,7,2,1],[7,8,2,1],[7,9,2,1],[7,10,2,1],[7,11,2,1],[7,12,2,1],[7,13,2,1]],
  south:  [[7,2,2,12],[7,2,2,1],[5,11,6,1],[6,12,4,1],[7,13,2,1]],
  east:   [[2,7,12,2],[10,5,1,6],[11,6,1,4],[12,7,1,2],[13,7,1,2]],
  west:   [[2,7,12,2],[5,5,1,6],[4,6,1,4],[3,7,1,2],[2,7,1,2]],
  back:   [[3,7,10,2],[5,5,2,2],[4,6,2,2],[3,7,2,2],[10,4,1,2],[11,5,1,2],[12,6,1,4]],
  up:     [[7,2,2,1],[6,3,4,1],[5,4,6,1],[4,5,8,1],[7,6,2,8]],
  down:   [[7,2,2,8],[4,10,8,1],[5,11,6,1],[6,12,4,1],[7,13,2,1]],
  // Lantern (signature icon)
  lamp: [
    [6,2,4,1],[7,3,2,1],
    [5,4,6,1],[5,5,1,1],[10,5,1,1],
    [5,6,1,4],[10,6,1,4],
    [4,10,8,1],[4,11,1,1],[11,11,1,1],
    [5,12,6,1],
    // flame inside
    [7,6,2,1],[6,7,4,1],[6,8,4,1],[7,9,2,1]
  ],
  // Inventory bag
  bag: [
    [6,2,4,1],[5,3,1,1],[10,3,1,1],
    [4,4,8,1],
    [3,5,10,1],[3,6,1,7],[12,6,1,7],
    [4,12,8,1],
  ],
  // Map
  map: [
    [2,3,4,10],[6,4,4,9],[10,3,4,10],
    [3,5,1,1],[4,7,1,1],[3,9,1,1],
    [7,5,2,1],[7,8,2,1],[7,11,2,1],
    [11,5,1,1],[12,7,1,1],[11,10,1,1],
  ],
  // Book / Journal
  book: [
    [3,3,10,1],[3,4,1,9],[12,4,1,9],[3,13,10,1],
    [5,5,6,1],[5,7,6,1],[5,9,4,1],[5,11,5,1],
  ],
  // Menu / dots
  menu: [[3,7,2,2],[7,7,2,2],[11,7,2,2]],
  // Plus
  plus: [[7,3,2,10],[3,7,10,2]],
  // Eye / observe
  eye: [
    [4,6,8,1],[3,7,10,1],[2,8,12,1],[3,9,10,1],[4,10,8,1],
    [6,7,4,1,],[6,7,4,3],[5,8,6,1],
    [7,8,2,2]
  ],
  // Coin / score
  coin: [
    [5,3,6,1],[3,4,2,1],[11,4,2,1],
    [3,5,1,7],[12,5,1,7],
    [3,12,2,1],[11,12,2,1],[5,13,6,1],
    [6,6,1,1],[8,6,1,1],[7,7,2,1],[7,8,2,1],[7,9,2,1],[6,10,4,1]
  ],
  // Key
  key: [
    [3,6,1,4],[4,5,1,1],[4,10,1,1],[5,6,1,4],[6,5,1,1],[6,10,1,1],
    [4,6,3,1],[4,9,3,1],
    [7,7,7,1],[7,8,7,1],
    [11,9,1,1],[13,9,1,1]
  ],
  // Heart / health
  heart: [
    [3,3,3,1],[10,3,3,1],
    [2,4,5,1],[9,4,5,1],
    [2,5,12,1],[2,6,12,1],
    [3,7,10,1],[4,8,8,1],[5,9,6,1],[6,10,4,1],[7,11,2,1]
  ],
  // Pin / location
  pin: [
    [6,2,4,1],[5,3,1,1],[10,3,1,1],[4,4,1,4],[11,4,1,4],
    [5,8,1,1],[10,8,1,1],[6,9,1,1],[9,9,1,1],[7,10,2,1],[7,11,2,1],
    [6,4,4,1],[6,5,1,1],[9,5,1,1],[6,6,1,1],[9,6,1,1],[6,7,4,1]
  ],
  // Settings (gear, simplified)
  gear: [
    [7,2,2,2],[7,12,2,2],[2,7,2,2],[12,7,2,2],
    [3,3,2,2],[11,3,2,2],[3,11,2,2],[11,11,2,2],
    [5,5,6,6],[6,5,4,1],[6,10,4,1],[5,6,1,4],[10,6,1,4],
    [7,7,2,2]
  ],
  // Check
  check: [
    [12,4,1,1],[11,5,2,1],[10,6,2,1],[9,7,2,1],[8,8,2,1],
    [3,7,2,1],[4,8,2,1],[5,9,3,1],[6,10,2,1],[7,9,2,1]
  ],
  // X / close
  close: [
    [3,3,2,2],[12,3,1,2],[12,3,2,1],
    [11,4,2,2],[4,4,2,2],
    [5,5,2,2],[10,5,2,2],
    [6,6,4,4],
    [5,9,2,2],[10,9,2,2],
    [4,10,2,2],[11,10,2,2],
    [3,11,2,2],[12,11,2,2]
  ],
  // Drop / put down
  drop: [
    [3,3,10,2],[3,5,1,5],[12,5,1,5],
    [5,7,1,1],[7,7,1,1],[9,7,1,1],
    [5,11,6,1],[6,12,4,1],[7,13,2,1]
  ],
  // Take / pickup
  take: [
    [7,2,2,7],[5,4,1,1],[10,4,1,1],[4,5,1,2],[11,5,1,2],
    [3,10,10,1],[3,11,1,3],[12,11,1,3],[3,13,10,1]
  ],
  // ── inventory items ────────────────────────────────────
  // Rod (3-ft black with rusty star tip)
  rod: [
    [2,7,12,2],
    // star tip
    [13,5,1,1],[12,6,1,1],[14,6,1,1],
    [13,9,1,1],[12,10,1,1],[14,10,1,1],
  ],
  // Cage (wicker, square w/ vertical bars)
  cage: [
    [3,3,10,1],[3,12,10,1],
    [3,4,1,8],[12,4,1,8],
    [5,4,1,8],[7,4,1,8],[9,4,1,8],[11,4,1,8],
    [3,7,10,1],
  ],
  // Bottle (with liquid level — used as base for water/oil/empty)
  bottle: [
    [7,2,2,1],
    [6,3,4,1],
    [5,4,6,1],
    [4,5,8,1],
    [4,6,1,7],[11,6,1,7],
    [5,8,6,4],[5,12,6,1],
    [5,13,6,1],
  ],
  // Food (loaf / ration)
  food: [
    [4,5,8,1],[3,6,10,1],
    [3,7,10,4],
    [4,11,8,1],[5,12,6,1],
    // crust marks
    [6,8,1,1],[9,8,1,1],[7,10,2,1],
  ],
  // Bird (small silhouette)
  bird: [
    [6,3,3,1],[5,4,5,1],[10,5,1,1],
    [4,5,7,1],[3,6,9,1],[3,7,10,1],
    [4,8,9,1],[5,9,7,1],[6,10,5,1],
    [4,11,2,1],[10,11,2,1],
  ],
  // Lamp variants for status — on/off/dim share lamp shape, vary inside
  lamp_off: [
    [6,2,4,1],[7,3,2,1],
    [5,4,6,1],[5,5,1,1],[10,5,1,1],
    [5,6,1,4],[10,6,1,4],
    [4,10,8,1],[4,11,1,1],[11,11,1,1],
    [5,12,6,1],
  ],
  lamp_dim: [
    [6,2,4,1],[7,3,2,1],
    [5,4,6,1],[5,5,1,1],[10,5,1,1],
    [5,6,1,4],[10,6,1,4],
    [4,10,8,1],[4,11,1,1],[11,11,1,1],
    [5,12,6,1],
    // tiny flame
    [7,7,2,1],[7,8,2,1],
  ],
  // Magic spark / incantation
  magic: [
    [7,2,2,12],
    [2,7,12,2],
    [4,4,2,2],[10,4,2,2],[4,10,2,2],[10,10,2,2],
    [6,6,4,4],
  ],
  // Sprite tile for "treasure" generic gem
  gem: [
    [6,3,4,1],[5,4,6,1],
    [4,5,8,1],[3,6,10,1],
    [3,7,10,1],[4,8,8,1],
    [5,9,6,1],[6,10,4,1],
    [7,11,2,1],
    // facets
    [6,6,1,1],[9,6,1,1],[7,8,1,1],[8,8,1,1],
  ],
  // Sound / speaker
  speak: [
    [4,5,2,6],[6,4,2,8],[8,3,1,10],[9,3,2,1],[9,12,2,1],
    [11,4,2,1],[13,5,1,1],[11,11,2,1],[13,10,1,1],
    [12,6,1,4],[14,6,1,4],
  ],
  // Star (special marker)
  star: [
    [7,2,2,2],[7,4,2,1],
    [3,4,3,1],[10,4,3,1],
    [4,5,2,1],[10,5,2,1],
    [5,6,2,1],[9,6,2,1],
    [6,7,4,1],
    [5,8,2,1],[9,8,2,1],
    [4,9,3,1],[9,9,3,1],
    [3,10,3,1],[10,10,3,1],
  ],
  // ── creatures (encounters) ──────────────────────────────
  // Dwarf — small with peaked hat
  dwarf: [
    [7,2,2,1],[6,3,4,1],[5,4,6,1],
    [4,5,8,1],[5,6,6,2],
    [6,8,4,3],[4,9,8,1],
    [5,12,2,2],[9,12,2,2],
  ],
  // Troll — burlier with club
  troll: [
    [6,2,4,2],[5,4,6,1],
    [3,5,10,1],[4,6,8,3],
    [3,9,10,2],
    [4,11,3,3],[9,11,3,3],
    [12,3,2,7],
  ],
  // Pirate — wide hat, sack on back
  pirate: [
    [3,2,10,1],[5,3,6,1],
    [6,4,4,2],[5,6,6,1],
    [4,7,8,4],[11,7,3,4],
    [4,11,4,3],[9,11,3,3],
  ],
};

const Icon = ({ name, size = 16, color = "currentColor", style }) => {
  const d = ICONS[name] || ICONS.menu;
  return <PixIcon d={d} size={size} color={color} style={style} />;
};


// ───────────────────────────────────────────────────────────
// SCENE PLACEHOLDER · pixel-art slot 16:9.
// If `src` is given, render the real image (with optional lamp halo overlay).
// Otherwise, fall back to the abstract placeholder (stripes, silhouettes).
// ───────────────────────────────────────────────────────────
const ScenePlaceholder = ({
  label = "scene.webp",
  brief = "320×180 · pixel-art",
  lampGlow = true,
  height = 180,
  src,
}) => {
  if (src) {
    return (
      <div style={{
        position: "relative",
        width: "100%",
        aspectRatio: "16 / 9",
        background: "var(--c-ink-void)",
        borderTop: "var(--b-2) solid var(--c-ink-line)",
        borderBottom: "var(--b-2) solid var(--c-ink-line)",
        overflow: "hidden",
      }}>
        <img
          src={src}
          alt={label}
          className="pixelated"
          style={{
            position: "absolute", inset: 0,
            width: "100%", height: "100%",
            objectFit: "cover",
            imageRendering: "pixelated",
          }}
        />
        {lampGlow && (
          <div style={{
            position: "absolute", left: "50%", top: "55%", transform: "translate(-50%,-50%)",
            width: "85%", height: "120%",
            background: "radial-gradient(ellipse at center, rgba(240,160,64,0.18) 0%, rgba(240,160,64,0.06) 35%, transparent 70%)",
            pointerEvents: "none",
            mixBlendMode: "screen",
          }} />
        )}
      </div>
    );
  }

  return (
    <div style={{
      position: "relative",
      width: "100%",
      aspectRatio: "16 / 9",
      background: "var(--c-ink-deep)",
      borderTop: "var(--b-2) solid var(--c-ink-line)",
      borderBottom: "var(--b-2) solid var(--c-ink-line)",
      overflow: "hidden",
      imageRendering: "pixelated",
    }}>
      {/* diagonal stripe pattern */}
      <div style={{
        position: "absolute", inset: 0,
        backgroundImage: "repeating-linear-gradient(45deg, transparent 0 14px, rgba(90,143,168,0.08) 14px 16px)",
      }} />
      {/* horizon line */}
      <div style={{
        position: "absolute", left: 0, right: 0, top: "62%",
        height: 1, background: "rgba(90,143,168,0.3)",
      }} />
      {/* faux silhouette blocks */}
      <div style={{
        position: "absolute", left: "10%", bottom: "38%", width: "18%", height: "22%",
        background: "rgba(13,29,45,0.7)",
      }} />
      <div style={{
        position: "absolute", right: "14%", bottom: "38%", width: "26%", height: "32%",
        background: "rgba(13,29,45,0.65)",
      }} />
      <div style={{
        position: "absolute", left: "32%", bottom: "38%", width: "30%", height: "14%",
        background: "rgba(13,29,45,0.5)",
      }} />
      {/* lamp glow */}
      {lampGlow && (
        <div style={{
          position: "absolute", left: "50%", top: "55%", transform: "translate(-50%,-50%)",
          width: "85%", height: "120%",
          background: "radial-gradient(ellipse at center, rgba(240,160,64,0.32) 0%, rgba(240,160,64,0.12) 35%, transparent 70%)",
          pointerEvents: "none",
        }} />
      )}
      {/* caption */}
      <div style={{
        position: "absolute", left: 10, bottom: 8,
        fontFamily: "var(--f-mono)",
        fontSize: 10,
        color: "var(--c-paper-faded)",
        background: "rgba(6,16,26,0.7)",
        padding: "3px 6px",
        letterSpacing: "0.04em",
      }}>
        ◇ {label}
      </div>
      <div style={{
        position: "absolute", right: 10, top: 8,
        fontFamily: "var(--f-caps)",
        fontSize: 9,
        color: "var(--c-paper-ink)",
        letterSpacing: "0.1em",
      }}>
        {brief}
      </div>
    </div>
  );
};

// ───────────────────────────────────────────────────────────
// STATUS BAR (faux phone status — battery, time, signal)
// ───────────────────────────────────────────────────────────
const FakeStatusBar = ({ time = "21:47", tint = "var(--c-paper-warm)" }) => (
  <div style={{
    height: 28,
    padding: "0 16px",
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    fontFamily: "var(--f-caps)",
    fontSize: 11,
    letterSpacing: "0.06em",
    color: tint,
  }}>
    <span>{time}</span>
    <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
      <span style={{ fontSize: 9 }}>OFFLINE</span>
      <div style={{ display: "flex", gap: 1, alignItems: "flex-end" }}>
        {[3,5,7,9].map(h => (
          <div key={h} style={{ width: 2, height: h, background: tint }} />
        ))}
      </div>
      <div style={{
        width: 18, height: 8, border: `1px solid ${tint}`, position: "relative",
        padding: 1,
      }}>
        <div style={{ width: "75%", height: "100%", background: tint }} />
        <div style={{ position: "absolute", right: -2, top: 2, width: 1, height: 4, background: tint }} />
      </div>
    </div>
  </div>
);


// ───────────────────────────────────────────────────────────
// PILL · small status chip (score, turns, lamp)
// ───────────────────────────────────────────────────────────
const Pill = ({ icon, label, value, tone = "default", style = {} }) => {
  const tones = {
    default: { bg: "var(--c-ink-mid)", fg: "var(--c-paper-warm)", border: "var(--c-ink-line)" },
    amber:   { bg: "rgba(240,160,64,0.12)", fg: "var(--c-amber)", border: "var(--c-amber)" },
    teal:    { bg: "rgba(78,197,184,0.10)", fg: "var(--c-teal-glow)", border: "var(--c-teal-glow)" },
    treasure:{ bg: "rgba(212,168,74,0.12)", fg: "var(--c-treasure)", border: "var(--c-treasure)" },
    danger:  { bg: "rgba(212,74,58,0.15)", fg: "var(--c-danger)", border: "var(--c-danger)" },
  };
  const t = tones[tone] || tones.default;
  return (
    <div style={{
      display: "inline-flex", alignItems: "center", gap: 6,
      padding: "4px 8px",
      background: t.bg,
      border: `2px solid ${t.border}`,
      color: t.fg,
      fontFamily: "var(--f-caps)",
      fontSize: 11,
      letterSpacing: "0.08em",
      textTransform: "uppercase",
      lineHeight: 1,
      ...style,
    }}>
      {icon && <Icon name={icon} size={12} color={t.fg} />}
      {label && <span>{label}</span>}
      {value && <span style={{ fontFamily: "var(--f-display)", fontSize: 13, letterSpacing: 0 }}>{value}</span>}
    </div>
  );
};


// ───────────────────────────────────────────────────────────
// CORNER ORNAMENTS · 4 brackets framing a region (pixel-style)
// ───────────────────────────────────────────────────────────
const CornerBrackets = ({ color = "var(--c-amber)", size = 10, thickness = 2, inset = 0 }) => {
  const arm = size;
  const t = thickness;
  const corners = [
    { top: inset, left: inset, lines: [[0,0,arm,t],[0,0,t,arm]] },
    { top: inset, right: inset, lines: [[0,0,arm,t],[arm-t,0,t,arm]] },
    { bottom: inset, left: inset, lines: [[0,arm-t,arm,t],[0,0,t,arm]] },
    { bottom: inset, right: inset, lines: [[0,arm-t,arm,t],[arm-t,0,t,arm]] },
  ];
  return (
    <>
      {corners.map((c, i) => (
        <div key={i} style={{ position: "absolute", width: arm, height: arm, ...c }}>
          {c.lines.map((l, j) => (
            <div key={j} style={{
              position: "absolute",
              left: l[0], top: l[1], width: l[2], height: l[3],
              background: color,
            }} />
          ))}
        </div>
      ))}
    </>
  );
};


// ───────────────────────────────────────────────────────────
// PIXEL DIVIDER · ornate horizontal rule with center diamond
// ───────────────────────────────────────────────────────────
const PixelDivider = ({ color = "var(--c-paper-ink)", style = {} }) => (
  <div style={{
    display: "flex", alignItems: "center", gap: 8,
    margin: "12px 0", ...style
  }}>
    <div style={{ flex: 1, height: 2, background: color }} />
    <div style={{
      width: 6, height: 6, background: color,
      transform: "rotate(45deg)"
    }} />
    <div style={{ flex: 1, height: 2, background: color }} />
  </div>
);

// ───────────────────────────────────────────────────────────
// FLASH MESSAGE · inline notification banner with stamp shadow
// ───────────────────────────────────────────────────────────
const FlashMessage = ({ icon, text, tone = "default", style = {} }) => {
  const tones = {
    default:   { border: "var(--c-amber)",    bg: "rgba(240,160,64,0.10)",  fg: "var(--c-amber)" },
    success:   { border: "var(--c-success)",  bg: "rgba(110,163,74,0.12)",  fg: "var(--c-success)" },
    danger:    { border: "var(--c-danger)",   bg: "rgba(212,74,58,0.12)",   fg: "var(--c-danger)" },
    info:      { border: "var(--c-teal-glow)",bg: "rgba(78,197,184,0.10)",  fg: "var(--c-teal-glow)" },
    magic:     { border: "var(--c-magic)",    bg: "rgba(152,112,196,0.14)", fg: "var(--c-magic)" },
    discovery: { border: "var(--c-treasure)", bg: "rgba(212,168,74,0.14)",  fg: "var(--c-treasure)" },
  };
  const t = tones[tone] || tones.default;
  return (
    <div style={{
      padding: "10px 12px",
      border: `2px solid ${t.border}`,
      background: t.bg,
      color: t.fg,
      fontFamily: "var(--f-caps)",
      fontSize: 11,
      letterSpacing: "0.08em",
      textTransform: "uppercase",
      display: "flex", alignItems: "center", gap: 8,
      boxShadow: "3px 3px 0 0 var(--c-ink-void)",
      ...style,
    }}>
      {icon && <Icon name={icon} size={14} color={t.fg} />}
      <span style={{ flex: 1 }}>{text}</span>
    </div>
  );
};


// Export to window
Object.assign(window, {
  Icon, ICONS, ScenePlaceholder, FakeStatusBar, Pill, CornerBrackets, PixelDivider,
  FlashMessage,
});
