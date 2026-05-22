/* eslint-disable */
// overflow-actions.jsx — "Plus…" overflow pattern when > 7 actions available.
// Two artboards:
//   · AdventureOverflow      collapsed (6 actions + "Plus…" stamp)
//   · AdventureOverflowSheet expanded (full list in bottom sheet)

// ───────────────────────────────────────────────────────────
// 1 · ADVENTURE OVERFLOW — collapsed (6 + Plus…)
// ───────────────────────────────────────────────────────────
const AdventureOverflow = () => (
  <AdventureChrome
    sceneLabel="east_pit.webp"
    sceneBrief="cluttered room · many objects"
    locationName="FOSSE EST"
    subtitle="Souterrain · Profondeur III"
    description="Une fosse ouverte vers le bas. La pierre est jonchée d'objets : oiseau en cage, baguette noire, débris divers. Plusieurs passages s'ouvrent dans la roche."
    lampState="bright"
    lampTurns={204}
    scorePill={{ value: "087", tone: "treasure" }}
    turnPill={{ value: "094" }}
    actionCount={11}
    tabActive="inventory"
  >
    {/* 6 most-relevant actions */}
    <StampButton icon="north" label="Aller au nord"      hint="N"     tone="primary" />
    <StampButton icon="east"  label="Aller à l'est"      hint="E" />
    <StampButton icon="down"  label="Descendre dans la fosse" hint="DOWN" />
    <StampButton icon="take"  label="Prendre la baguette" hint="OBJ" />
    <StampButton icon="take"  label="Prendre l'oiseau (cage)" hint="OBJ" />
    <StampButton icon="eye"   label="Observer le lieu"   hint="LOOK"  tone="meta" />

    {/* Plus… disclosure */}
    <button style={{
      width: "100%",
      minHeight: 44,
      padding: "9px 14px",
      display: "flex",
      alignItems: "center",
      gap: 12,
      background: "transparent",
      border: "2.5px dashed var(--c-paper-warm)",
      color: "var(--c-paper-warm)",
      fontFamily: "var(--f-caps)",
      fontSize: 12,
      letterSpacing: "0.1em",
      textTransform: "uppercase",
      textAlign: "left",
      cursor: "pointer",
      boxShadow: "3px 3px 0 0 rgba(6,16,26,0.4)",
    }}>
      <Icon name="plus" size={14} color="var(--c-paper-warm)" />
      <span style={{ flex: 1 }}>Plus d'actions</span>
      <span style={{
        fontFamily: "var(--f-mono)",
        fontSize: 10,
        letterSpacing: 0,
        opacity: 0.7,
        textTransform: "none",
      }}>+5</span>
      <span style={{
        fontFamily: "var(--f-display)",
        fontSize: 14,
        opacity: 0.6,
        lineHeight: 1,
      }}>›</span>
    </button>
  </AdventureChrome>
);


// ───────────────────────────────────────────────────────────
// 2 · ADVENTURE OVERFLOW SHEET — expanded with all 11 actions
//     in a full bottom sheet, organized by category.
// ───────────────────────────────────────────────────────────
const OverflowSheet = ({ actions = [], close }) => {
  // Group by category
  const byCat = actions.reduce((acc, a) => {
    acc[a.cat] = acc[a.cat] || [];
    acc[a.cat].push(a);
    return acc;
  }, {});
  const order = ["security", "travel", "interaction", "meta"];
  const labels = {
    security:    "Sécurité",
    travel:      "Navigation",
    interaction: "Interactions",
    meta:        "Méta",
  };

  return (
    <div style={{
      position: "absolute",
      left: 0, right: 0, bottom: 0,
      top: "12%",
      background: "var(--c-ink-deep)",
      borderTop: "2.5px solid var(--c-amber)",
      boxShadow: "0 -4px 24px rgba(0,0,0,0.6)",
      padding: "14px 14px 16px",
      zIndex: 5,
      display: "flex",
      flexDirection: "column",
    }}>
      {/* drag handle */}
      <div style={{
        width: 40, height: 3,
        background: "var(--c-paper-ink)",
        margin: "0 auto 12px",
      }} />

      {/* header */}
      <div style={{
        display: "flex", alignItems: "center", gap: 10,
        marginBottom: 12,
      }}>
        <Icon name="plus" size={18} color="var(--c-amber)" />
        <div style={{ flex: 1 }}>
          <div style={{
            fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.16em",
            color: "var(--c-amber)",
          }}>◆ TOUTES LES ACTIONS</div>
          <div style={{
            fontFamily: "var(--f-display)", fontSize: 18, fontWeight: 700,
            color: "var(--c-paper-bright)", letterSpacing: "0.01em",
            marginTop: 2, lineHeight: 1,
          }}>11 options disponibles</div>
        </div>
        <button style={{
          width: 30, height: 30,
          background: "transparent",
          border: "2px solid var(--c-ink-line)",
          color: "var(--c-paper-warm)",
          cursor: "pointer", padding: 0,
          display: "flex", alignItems: "center", justifyContent: "center",
        }}>
          <Icon name="close" size={11} color="var(--c-paper-faded)" />
        </button>
      </div>

      {/* Scrollable category list */}
      <div style={{
        flex: 1,
        overflow: "auto",
      }}>
        {order.map(cat => byCat[cat] && (
          <div key={cat} style={{ marginBottom: 14 }}>
            <div style={{
              fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.14em",
              color: "var(--c-paper-faded)", marginBottom: 6, padding: "0 2px",
            }}>◇ {labels[cat]} · {byCat[cat].length}</div>
            <div style={{ display: "flex", flexDirection: "column", gap: 7 }}>
              {byCat[cat].map((a, i) => (
                <StampButton key={i} {...a} />
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

const AdventureOverflowSheet = () => {
  const allActions = [
    // travel (5)
    { cat: "travel", icon: "north", label: "Aller au nord",       hint: "N",    tone: "primary" },
    { cat: "travel", icon: "east",  label: "Aller à l'est",       hint: "E" },
    { cat: "travel", icon: "down",  label: "Descendre dans la fosse", hint: "DOWN" },
    { cat: "travel", icon: "up",    label: "Remonter",             hint: "UP" },
    { cat: "travel", icon: "back",  label: "Rebrousser chemin",    hint: "BACK" },
    // interaction (4)
    { cat: "interaction", icon: "take", label: "Prendre la baguette",     hint: "OBJ" },
    { cat: "interaction", icon: "take", label: "Prendre l'oiseau (cage)", hint: "OBJ" },
    { cat: "interaction", icon: "drop", label: "Lâcher la lanterne",      hint: "DROP",  tone: "faded" },
    { cat: "interaction", icon: "lamp", label: "Éteindre la lanterne",    hint: "LIGHT", tone: "meta" },
    // meta (2)
    { cat: "meta", icon: "eye",  label: "Observer le lieu", hint: "LOOK",  tone: "meta" },
    { cat: "meta", icon: "bag",  label: "Inventaire",       hint: "INV",   tone: "meta" },
  ];
  return (
    <AdventureChrome
      sceneLabel="east_pit.webp"
      sceneBrief="cluttered room · many objects"
      locationName="FOSSE EST"
      subtitle="Souterrain · Profondeur III"
      description="Une fosse ouverte vers le bas. La pierre est jonchée d'objets…"
      lampState="bright"
      lampTurns={204}
      scorePill={{ value: "087", tone: "treasure" }}
      turnPill={{ value: "094" }}
      actionCount={11}
      tabActive="inventory"
    >
      <StampButton icon="north" label="Aller au nord" hint="N" tone="primary" />
      <StampButton icon="east"  label="Aller à l'est" hint="E" />

      {/* scrim + sheet overlay */}
      <div style={{
        position: "absolute", inset: 0,
        background: "rgba(6,16,26,0.55)",
        zIndex: 4,
      }} />
      <OverflowSheet actions={allActions} />
    </AdventureChrome>
  );
};

Object.assign(window, { AdventureOverflow, AdventureOverflowSheet, OverflowSheet });
