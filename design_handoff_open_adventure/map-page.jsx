/* eslint-disable */
// map-page.jsx — MapPage : explorer's hand-sketched map of discovered locations.
// Pixel-grid paper bg · dashed connections · pixel-rect nodes colored by state ·
// handwritten-feel annotations · legend at bottom.

// ───────────────────────────────────────────────────────────
// Node component — a single map marker
// ───────────────────────────────────────────────────────────
const MapNode = ({ x, y, label, state = "visited", icon, w = 60, h = 22 }) => {
  // state: "current" | "visited" | "edge" (adjacent unexplored) | "treasure" | "hostile" | "deadend"
  const styles = {
    current:  { bg: "var(--c-amber)",          border: "var(--c-amber-shadow)", fg: "var(--c-ink-void)",    halo: "0 0 0 3px rgba(240,160,64,0.25), 0 0 16px 2px rgba(240,160,64,0.6)" },
    visited:  { bg: "rgba(13,29,45,0.85)",     border: "var(--c-paper-warm)",   fg: "var(--c-paper-bright)",halo: "none" },
    treasure: { bg: "rgba(212,168,74,0.22)",   border: "var(--c-treasure)",     fg: "var(--c-treasure)",    halo: "none" },
    hostile:  { bg: "rgba(212,74,58,0.20)",    border: "var(--c-danger)",       fg: "var(--c-danger)",      halo: "none" },
    deadend:  { bg: "rgba(13,29,45,0.5)",      border: "var(--c-paper-ink)",    fg: "var(--c-paper-faded)", halo: "none", border_style: "dashed" },
    edge:     { bg: "transparent",             border: "var(--c-paper-ink)",    fg: "var(--c-paper-ink)",   halo: "none", border_style: "dashed" },
  };
  const s = styles[state] || styles.visited;
  return (
    <div style={{
      position: "absolute",
      left: x, top: y,
      width: w, height: h,
      background: s.bg,
      border: `2px ${s.border_style || "solid"} ${s.border}`,
      color: s.fg,
      display: "flex", alignItems: "center", justifyContent: "center",
      gap: 4,
      fontFamily: "var(--f-caps)",
      fontSize: 8,
      letterSpacing: "0.06em",
      textTransform: "uppercase",
      boxShadow: s.halo,
      zIndex: state === "current" ? 5 : 2,
    }}>
      {icon && <Icon name={icon} size={8} color={s.fg} />}
      <span>{label}</span>
      {state === "treasure" && (
        <div style={{
          position: "absolute", right: -3, top: -3,
          width: 5, height: 5, background: "var(--c-treasure)",
          transform: "rotate(45deg)",
        }} />
      )}
      {state === "hostile" && (
        <div style={{
          position: "absolute", left: -3, top: -3,
          width: 5, height: 5, background: "var(--c-danger)",
          transform: "rotate(45deg)",
        }} />
      )}
    </div>
  );
};


// ───────────────────────────────────────────────────────────
// Edge — dashed line between two anchor points
// ───────────────────────────────────────────────────────────
const MapEdge = ({ x1, y1, x2, y2, dashed = true, color = "var(--c-paper-ink)" }) => {
  const dx = x2 - x1;
  const dy = y2 - y1;
  const len = Math.sqrt(dx * dx + dy * dy);
  const angle = Math.atan2(dy, dx) * 180 / Math.PI;
  return (
    <div style={{
      position: "absolute",
      left: x1, top: y1,
      width: len, height: 0,
      borderTop: `1.5px ${dashed ? "dashed" : "solid"} ${color}`,
      transform: `rotate(${angle}deg)`,
      transformOrigin: "0 0",
      zIndex: 1,
    }} />
  );
};


// ───────────────────────────────────────────────────────────
// Handwritten annotation — italic body, faded ink
// ───────────────────────────────────────────────────────────
const MapNote = ({ x, y, children, w = 80, align = "left" }) => (
  <div style={{
    position: "absolute",
    left: x, top: y,
    width: w,
    fontFamily: "var(--f-body)",
    fontSize: 9,
    fontStyle: "italic",
    color: "var(--c-paper-ink)",
    lineHeight: 1.2,
    textAlign: align,
    pointerEvents: "none",
    zIndex: 3,
  }}>
    {children}
  </div>
);


// ───────────────────────────────────────────────────────────
// MAP PAGE
// ───────────────────────────────────────────────────────────
const MapPage = () => (
  <PhoneShell>
    <FakeStatusBar tint="var(--c-paper-faded)" />

    {/* Header */}
    <div style={{
      padding: "8px 12px 10px",
      display: "flex",
      alignItems: "center",
      gap: 10,
      borderBottom: "1px solid var(--c-ink-hairline)",
    }}>
      <button style={{
        width: 32, height: 32,
        background: "transparent",
        border: "2px solid var(--c-ink-line)",
        color: "var(--c-paper-warm)",
        cursor: "pointer",
        display: "flex", alignItems: "center", justifyContent: "center",
        padding: 0,
      }}>
        <Icon name="back" size={14} color="var(--c-paper-warm)" />
      </button>
      <div style={{ flex: 1 }}>
        <div style={{
          fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em",
          color: "var(--c-amber)", marginBottom: 2,
        }}>◆ TON CARNET</div>
        <div style={{
          fontFamily: "var(--f-display)", fontSize: 20, fontWeight: 700,
          color: "var(--c-paper-bright)", letterSpacing: "0.01em", lineHeight: 1,
        }}>CARTE</div>
      </div>
      <Pill icon="pin" label="LIEUX" value="14/87" tone="default" />
    </div>

    {/* Map viewport */}
    <div style={{
      flex: 1,
      position: "relative",
      overflow: "hidden",
      background: "var(--c-ink-deep)",
      backgroundImage: `
        repeating-linear-gradient(0deg, transparent 0 15px, rgba(78,197,184,0.04) 15px 16px),
        repeating-linear-gradient(90deg, transparent 0 15px, rgba(78,197,184,0.04) 15px 16px)
      `,
    }}>
      {/* Zone band — surface */}
      <div style={{
        position: "absolute", left: 8, top: 8,
        fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.14em",
        color: "var(--c-success)",
        padding: "3px 6px",
        border: "1px solid var(--c-success)",
        background: "rgba(110,163,74,0.10)",
      }}>◇ SURFACE</div>

      {/* Zone band — souterrain */}
      <div style={{
        position: "absolute", left: 8, top: 282,
        fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.14em",
        color: "var(--c-teal-mist)",
        padding: "3px 6px",
        border: "1px solid var(--c-teal-mist)",
        background: "rgba(90,143,168,0.10)",
      }}>◇ SOUTERRAIN · PROF. I — II</div>

      {/* Surface zone divider */}
      <div style={{
        position: "absolute", left: 0, right: 0, top: 270,
        borderTop: "1.5px dashed var(--c-ink-line)",
      }} />

      {/* ─────────── EDGES ─────────── */}
      {/* Surface graph */}
      <MapEdge x1={70}  y1={120} x2={140} y2={80} />
      <MapEdge x1={70}  y1={120} x2={180} y2={155} />
      <MapEdge x1={180} y1={155} x2={250} y2={90} />
      <MapEdge x1={180} y1={155} x2={280} y2={155} />
      <MapEdge x1={180} y1={155} x2={180} y2={225} />
      <MapEdge x1={180} y1={225} x2={250} y2={225} />
      <MapEdge x1={180} y1={225} x2={120} y2={225} />
      <MapEdge x1={250} y1={225} x2={250} y2={310} dashed solid color="var(--c-amber)" /> {/* descend to underground */}

      {/* Underground graph */}
      <MapEdge x1={250} y1={335} x2={180} y2={370} />
      <MapEdge x1={180} y1={370} x2={100} y2={400} />
      <MapEdge x1={180} y1={370} x2={180} y2={440} />
      <MapEdge x1={180} y1={440} x2={100} y2={470} />
      <MapEdge x1={180} y1={440} x2={250} y2={470} />
      <MapEdge x1={250} y1={470} x2={300} y2={530} />
      <MapEdge x1={180} y1={440} x2={180} y2={510} />
      <MapEdge x1={180} y1={510} x2={120} y2={560} dashed />
      <MapEdge x1={180} y1={510} x2={250} y2={560} dashed />

      {/* ─────────── NODES — SURFACE ─────────── */}
      <MapNode x={40}  y={60}  label="forêt" state="visited" />
      <MapNode x={110} y={60}  label="colline" state="deadend" />
      <MapNode x={40}  y={110} label="route" state="visited" w={60} />
      <MapNode x={150} y={140} label="cottage" state="visited" w={60} icon="bag" />
      <MapNode x={222} y={70}  label="bord N" state="edge" />
      <MapNode x={250} y={140} label="fin route" state="deadend" />
      <MapNode x={150} y={210} label="vallée" state="visited" />
      <MapNode x={92}  y={210} label="fente" state="visited" />
      <MapNode x={222} y={210} label="grille" state="visited" icon="key" />

      {/* ─────────── NODES — UNDERGROUND ─────────── */}
      <MapNode x={222} y={310} label="cobble" state="visited" />
      <MapNode x={150} y={355} label="débris" state="treasure" />
      <MapNode x={70}  y={388} label="oiseau" state="visited" icon="bird" />
      <MapNode x={150} y={428} label="pittop" state="visited" />
      <MapNode x={70}  y={458} label="W pit" state="visited" />
      <MapNode x={222} y={458} label="hall brumes" state="current" w={70} icon="pin" />
      <MapNode x={272} y={518} label="roi" state="hostile" icon="speak" />
      <MapNode x={150} y={498} label="échelle" state="edge" />
      <MapNode x={92}  y={548} label="?" state="edge" w={28} />
      <MapNode x={222} y={548} label="?" state="edge" w={28} />

      {/* ─────────── ANNOTATIONS ─────────── */}
      <MapNote x={20} y={36} w={70}>« forêt nord — perdu une fois ici »</MapNote>
      <MapNote x={220} y={188} w={75}>« clef en métal · hier »</MapNote>
      <MapNote x={5} y={328} w={80}>« descente abrupte, attention »</MapNote>
      <MapNote x={5} y={420} w={70}>« plante crie pour de l'eau »</MapNote>
      <MapNote x={220} y={502} w={80} align="left"><span style={{ color: "var(--c-danger)" }}>⚠ serpent</span> — barre route</MapNote>
      <MapNote x={75} y={580} w={120}>« passages non explorés… »</MapNote>

      {/* Compass rose, bottom-left */}
      <div style={{
        position: "absolute", left: 14, bottom: 90,
        width: 44, height: 44,
        border: "1.5px solid var(--c-paper-ink)",
        borderRadius: "50%",
        display: "flex", alignItems: "center", justifyContent: "center",
        fontFamily: "var(--f-display)", fontSize: 11,
        color: "var(--c-paper-ink)",
      }}>
        <span style={{ position: "absolute", top: 2, color: "var(--c-amber)" }}>N</span>
        <span style={{ position: "absolute", right: 5 }}>E</span>
        <span style={{ position: "absolute", bottom: 2 }}>S</span>
        <span style={{ position: "absolute", left: 5 }}>O</span>
        <div style={{ width: 2, height: 18, background: "var(--c-amber)", transform: "translateY(-4px)" }} />
      </div>
    </div>

    {/* Legend */}
    <div style={{
      padding: "8px 12px 10px",
      borderTop: "1px dashed var(--c-ink-line)",
      background: "var(--c-ink-deep)",
      display: "flex",
      flexWrap: "wrap",
      gap: 10,
      rowGap: 6,
    }}>
      {[
        { color: "var(--c-amber)",   label: "Position" },
        { color: "var(--c-paper-warm)", label: "Visité" },
        { color: "var(--c-treasure)", label: "Trésor" },
        { color: "var(--c-danger)",   label: "Hostile" },
        { color: "var(--c-paper-ink)", label: "À explorer", dashed: true },
      ].map(l => (
        <div key={l.label} style={{ display: "flex", alignItems: "center", gap: 5 }}>
          <div style={{
            width: 12, height: 8,
            background: l.dashed ? "transparent" : l.color,
            border: `1.5px ${l.dashed ? "dashed" : "solid"} ${l.color}`,
          }} />
          <span style={{
            fontFamily: "var(--f-caps)", fontSize: 9,
            letterSpacing: "0.08em", color: "var(--c-paper-faded)",
          }}>{l.label}</span>
        </div>
      ))}
    </div>

    <BottomNav active="map" />
  </PhoneShell>
);

Object.assign(window, { MapPage, MapNode, MapEdge, MapNote });
