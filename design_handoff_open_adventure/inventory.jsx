/* eslint-disable */
// inventory.jsx — gameplay UI for Open Adventure:
//   · LampShortcut       diegetic lantern toggle (top-right of header)
//   · MagicWordSurface   contextual incantation row (DDR-001 Option A)
//   · ItemSprite         32×32 placeholder pixel sprite for inventory items
//   · ItemCard           one row in the inventory list
//   · InventoryPage      full-screen pouch view (max 7 slots)
//   · ItemActionSheet    bottom sheet listing verbs available on an item

// ───────────────────────────────────────────────────────────
// LAMP SHORTCUT · always-visible lantern button
// States: bright (lit, amber halo) · dim (warning, slow pulse) · dark (off)
// ───────────────────────────────────────────────────────────
const LampShortcut = ({ state = "bright", turns = 285 }) => {
  // state: "bright" | "dim" | "dark"
  const tones = {
    bright: {
      icon: "lamp",
      border: "var(--c-amber)",
      bg:     "rgba(240,160,64,0.14)",
      fg:     "var(--c-amber-glow)",
      halo:   "0 0 20px 4px rgba(240,160,64,0.45)",
      meta:   "ALLUMÉE",
    },
    dim: {
      icon: "lamp_dim",
      border: "var(--c-danger)",
      bg:     "rgba(212,74,58,0.14)",
      fg:     "var(--c-danger)",
      halo:   "0 0 16px 3px rgba(212,74,58,0.4)",
      meta:   "FAIBLE",
    },
    dark: {
      icon: "lamp_off",
      border: "var(--c-ink-line)",
      bg:     "transparent",
      fg:     "var(--c-paper-ink)",
      halo:   "none",
      meta:   "ÉTEINTE",
    },
  };
  const t = tones[state] || tones.bright;
  return (
    <button style={{
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      padding: "6px 8px",
      gap: 3,
      background: t.bg,
      border: `2.5px solid ${t.border}`,
      color: t.fg,
      cursor: "pointer",
      boxShadow: `3px 3px 0 0 var(--c-ink-void), ${t.halo}`,
      position: "relative",
      minWidth: 56,
    }}>
      <Icon name={t.icon} size={22} color={t.fg} />
      <span style={{
        fontFamily: "var(--f-mono)",
        fontSize: 9,
        letterSpacing: "0.04em",
        color: t.fg,
        lineHeight: 1,
      }}>{turns}t</span>
      <span style={{
        fontFamily: "var(--f-caps)",
        fontSize: 7,
        letterSpacing: "0.1em",
        color: t.fg,
        opacity: 0.85,
        lineHeight: 1,
      }}>{t.meta}</span>
    </button>
  );
};


// ───────────────────────────────────────────────────────────
// MAGIC WORD SURFACE · contextual incantation row
// Only renders when (1) Game.magicWordsUnlocked == true
// AND (2) the current location is a valid target for `word`.
// ───────────────────────────────────────────────────────────
const MagicWordSurface = ({ word = "XYZZY", hint = "T'envoie quelque part…" }) => (
  <div style={{
    border: "2.5px solid var(--c-magic)",
    background: "linear-gradient(180deg, rgba(152,112,196,0.18) 0%, rgba(152,112,196,0.06) 100%)",
    padding: "10px 12px 11px",
    display: "flex",
    alignItems: "center",
    gap: 11,
    boxShadow: "3px 3px 0 0 #3d2a55",
    position: "relative",
    cursor: "pointer",
  }}>
    {/* runic ornaments */}
    <div style={{
      position: "absolute", left: -1, top: -1, width: 8, height: 8,
      borderTop: "2px solid var(--c-magic)", borderLeft: "2px solid var(--c-magic)",
    }} />
    <div style={{
      position: "absolute", right: -1, top: -1, width: 8, height: 8,
      borderTop: "2px solid var(--c-magic)", borderRight: "2px solid var(--c-magic)",
    }} />
    <Icon name="magic" size={20} color="var(--c-magic)" />
    <div style={{ flex: 1, minWidth: 0 }}>
      <div style={{
        fontFamily: "var(--f-caps)",
        fontSize: 9,
        letterSpacing: "0.18em",
        color: "var(--c-magic)",
        opacity: 0.85,
      }}>◆ INCANTATION CONNUE</div>
      <div style={{
        fontFamily: "var(--f-display)",
        fontSize: 18,
        fontWeight: 700,
        color: "var(--c-paper-bright)",
        letterSpacing: "0.18em",
        marginTop: 2,
        lineHeight: 1,
      }}>{word}</div>
      <div style={{
        fontFamily: "var(--f-body)",
        fontSize: 11,
        fontStyle: "italic",
        color: "var(--c-paper-faded)",
        marginTop: 4,
      }}>{hint}</div>
    </div>
    <span style={{
      fontFamily: "var(--f-display)",
      fontSize: 22,
      color: "var(--c-magic)",
      opacity: 0.8,
      lineHeight: 1,
    }}>›</span>
  </div>
);


// ───────────────────────────────────────────────────────────
// ITEM SPRITE · 48×48 framed sprite for inventory items.
// If `src` is provided, render the real artwork inside the frame.
// Otherwise, render the pixel-art Icon by name.
// ───────────────────────────────────────────────────────────
const ItemSprite = ({ icon, size = 48, tone = "default", glow = false, label, src }) => {
  const tones = {
    default:  { border: "var(--c-ink-line)",  bg: "rgba(13,29,45,0.6)",     fg: "var(--c-paper-warm)" },
    treasure: { border: "var(--c-treasure)",  bg: "rgba(212,168,74,0.10)",  fg: "var(--c-treasure)"   },
    lit:      { border: "var(--c-amber)",     bg: "rgba(240,160,64,0.14)",  fg: "var(--c-amber-glow)" },
    danger:   { border: "var(--c-danger)",    bg: "rgba(212,74,58,0.10)",   fg: "var(--c-danger)"     },
    magic:    { border: "var(--c-magic)",     bg: "rgba(152,112,196,0.12)", fg: "var(--c-magic)"      },
  };
  const t = tones[tone] || tones.default;
  return (
    <div style={{
      width: size, height: size,
      flexShrink: 0,
      border: `2px solid ${t.border}`,
      background: t.bg,
      display: "flex", alignItems: "center", justifyContent: "center",
      position: "relative",
      overflow: "hidden",
      boxShadow: glow ? `0 0 14px 2px ${t.border}` : "none",
    }}>
      {src ? (
        <img
          src={src}
          alt={icon}
          style={{
            width: "100%", height: "100%",
            objectFit: "cover",
            display: "block",
          }}
        />
      ) : (
        <Icon name={icon} size={Math.floor(size * 0.6)} color={t.fg} />
      )}
      {label && (
        <div style={{
          position: "absolute", left: -1, top: -1,
          background: t.border,
          color: tone === "default" ? "var(--c-paper-warm)" : "var(--c-ink-void)",
          fontFamily: "var(--f-caps)",
          fontSize: 8,
          letterSpacing: "0.08em",
          padding: "1px 4px 1px",
          lineHeight: 1,
          zIndex: 1,
        }}>{label}</div>
      )}
    </div>
  );
};


// ───────────────────────────────────────────────────────────
// ITEM CARD · row in inventory list
// ───────────────────────────────────────────────────────────
const ItemCard = ({ icon, name, state, hint, spriteTone = "default", glow, selected, treasure, sprite }) => (
  <button style={{
    width: "100%",
    minHeight: 64,
    padding: "10px 12px",
    display: "flex",
    alignItems: "center",
    gap: 12,
    background: selected ? "rgba(240,160,64,0.10)" : "transparent",
    border: selected ? "2px solid var(--c-amber)" : "2px solid var(--c-ink-hairline)",
    color: "var(--c-paper-warm)",
    cursor: "pointer",
    textAlign: "left",
    boxShadow: selected ? "3px 3px 0 0 var(--c-amber-shadow)" : "none",
  }}>
    <ItemSprite icon={icon} size={48} tone={spriteTone} glow={glow} src={sprite} />
    <div style={{ flex: 1, minWidth: 0 }}>
      <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
        {treasure && <Icon name="star" size={11} color="var(--c-treasure)" />}
        <span style={{
          fontFamily: "var(--f-display)",
          fontSize: 15,
          fontWeight: 600,
          letterSpacing: "0.01em",
          color: "var(--c-paper-bright)",
          lineHeight: 1.05,
        }}>{name}</span>
      </div>
      {state && (
        <div style={{
          fontFamily: "var(--f-caps)",
          fontSize: 9,
          letterSpacing: "0.12em",
          color: spriteTone === "lit" ? "var(--c-amber)"
               : spriteTone === "danger" ? "var(--c-danger)"
               : spriteTone === "treasure" ? "var(--c-treasure)"
               : "var(--c-teal-mist)",
          marginTop: 4,
        }}>◆ {state}</div>
      )}
      {hint && (
        <div style={{
          fontFamily: "var(--f-body)",
          fontSize: 12,
          color: "var(--c-paper-faded)",
          marginTop: 3,
          lineHeight: 1.3,
        }}>{hint}</div>
      )}
    </div>
    <span style={{ color: "var(--c-paper-ink)", fontFamily: "var(--f-display)", fontSize: 14 }}>›</span>
  </button>
);


// ───────────────────────────────────────────────────────────
// INVENTORY PAGE · full screen pouch view
// ───────────────────────────────────────────────────────────
const InventoryPage = ({ items = [], capacity = 7 }) => {
  const free = capacity - items.length;
  return (
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
          }}>◆ TON SAC</div>
          <div style={{
            fontFamily: "var(--f-display)", fontSize: 20, fontWeight: 700,
            color: "var(--c-paper-bright)", letterSpacing: "0.01em", lineHeight: 1,
          }}>INVENTAIRE</div>
        </div>
        <Pill icon="bag" value={`${items.length}/${capacity}`} tone={free === 0 ? "danger" : "amber"} />
      </div>

      {/* Body */}
      <div style={{
        flex: 1,
        overflow: "auto",
        padding: "12px 12px 16px",
      }}>
        {/* Group: outils */}
        <div style={{
          fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.14em",
          color: "var(--c-paper-ink)", margin: "0 4px 8px",
        }}>OUTILS · 4</div>
        <div style={{ display: "flex", flexDirection: "column", gap: 8, marginBottom: 16 }}>
          {items.slice(0, 4).map((it, i) => <ItemCard key={i} {...it} />)}
        </div>

        <div style={{
          fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.14em",
          color: "var(--c-paper-ink)", margin: "0 4px 8px",
        }}>SURVIE · 2</div>
        <div style={{ display: "flex", flexDirection: "column", gap: 8, marginBottom: 16 }}>
          {items.slice(4, 6).map((it, i) => <ItemCard key={i} {...it} />)}
        </div>

        <div style={{
          fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.14em",
          color: "var(--c-paper-ink)", margin: "0 4px 8px",
        }}>VIVANT · 1</div>
        <div style={{ display: "flex", flexDirection: "column", gap: 8, marginBottom: 16 }}>
          {items.slice(6, 7).map((it, i) => <ItemCard key={i} {...it} />)}
        </div>

        {/* Capacity meter */}
        <div style={{
          marginTop: 16,
          padding: "10px 12px",
          border: "1px dashed var(--c-ink-line)",
          background: "rgba(13,29,45,0.5)",
          display: "flex", alignItems: "center", gap: 10,
        }}>
          <div style={{
            display: "flex", gap: 3, flex: 1,
          }}>
            {Array.from({ length: capacity }).map((_, i) => (
              <div key={i} style={{
                flex: 1, height: 8,
                background: i < items.length ? "var(--c-amber)" : "rgba(122,106,78,0.25)",
                border: "1px solid var(--c-paper-ink)",
              }} />
            ))}
          </div>
          <span style={{
            fontFamily: "var(--f-mono)", fontSize: 10,
            color: "var(--c-paper-faded)",
            letterSpacing: "0.04em",
          }}>{free} libres</span>
        </div>
      </div>

      <BottomNav active="inventory" />
    </PhoneShell>
  );
};


// ───────────────────────────────────────────────────────────
// ITEM ACTION SHEET · bottom sheet showing verbs for an item
// Floats over Adventure screen
// ───────────────────────────────────────────────────────────
const ItemActionSheet = ({ icon, name, state, description, actions = [], spriteTone = "default", sprite }) => (
  <div style={{
    position: "absolute",
    left: 0, right: 0, bottom: 0,
    background: "var(--c-ink-deep)",
    borderTop: "2.5px solid var(--c-amber)",
    boxShadow: "0 -4px 24px rgba(0,0,0,0.6)",
    padding: "14px 16px 16px",
    zIndex: 5,
  }}>
    {/* drag handle */}
    <div style={{
      width: 40, height: 3,
      background: "var(--c-paper-ink)",
      margin: "0 auto 14px",
    }} />

    {/* header */}
    <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 12 }}>
      <ItemSprite icon={icon} size={56} tone={spriteTone} glow={spriteTone !== "default"} src={sprite} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.16em",
          color: "var(--c-amber)",
        }}>◆ OBJET SÉLECTIONNÉ</div>
        <div style={{
          fontFamily: "var(--f-display)", fontSize: 20, fontWeight: 700,
          color: "var(--c-paper-bright)", letterSpacing: "0.01em", lineHeight: 1.05,
          marginTop: 3,
        }}>{name}</div>
        {state && (
          <div style={{
            fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.12em",
            color: spriteTone === "lit" ? "var(--c-amber)" : "var(--c-teal-mist)",
            marginTop: 4,
          }}>{state}</div>
        )}
      </div>
      <button style={{
        width: 30, height: 30,
        background: "transparent",
        border: "2px solid var(--c-ink-line)",
        color: "var(--c-paper-warm)",
        cursor: "pointer",
        padding: 0,
        display: "flex", alignItems: "center", justifyContent: "center",
      }}>
        <Icon name="close" size={11} color="var(--c-paper-faded)" />
      </button>
    </div>

    {description && (
      <div style={{
        fontFamily: "var(--f-body)",
        fontSize: 13,
        fontStyle: "italic",
        color: "var(--c-paper-faded)",
        lineHeight: 1.4,
        margin: "0 0 14px",
        textWrap: "pretty",
      }}>« {description} »</div>
    )}

    {/* action stamps */}
    <div style={{
      fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em",
      color: "var(--c-paper-ink)", marginBottom: 8,
    }}>QUE FAIRE AVEC ?</div>
    <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
      {actions.map((a, i) => (
        <StampButton key={i} {...a} />
      ))}
    </div>
  </div>
);


Object.assign(window, {
  LampShortcut, MagicWordSurface,
  ItemSprite, ItemCard, InventoryPage, ItemActionSheet,
});
