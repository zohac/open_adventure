/* eslint-disable */
// saves.jsx — SavesPage : autosave + 4 manual slots + storage.
// Each save shows a thumbnail (scene placeholder), location, turns/score, date.

// ───────────────────────────────────────────────────────────
// Mini scene thumbnail — compressed scene placeholder for save cards
// ───────────────────────────────────────────────────────────
const MiniScene = ({ label = "scene", lampGlow = true, w = 80, h = 56 }) => (
  <div style={{
    width: w, height: h,
    background: "var(--c-ink-deep)",
    border: "1.5px solid var(--c-ink-line)",
    position: "relative",
    overflow: "hidden",
    flexShrink: 0,
  }}>
    <div style={{
      position: "absolute", inset: 0,
      backgroundImage: "repeating-linear-gradient(45deg, transparent 0 6px, rgba(90,143,168,0.10) 6px 7px)",
    }} />
    <div style={{
      position: "absolute", left: "10%", bottom: "30%", width: "25%", height: "40%",
      background: "rgba(13,29,45,0.7)",
    }} />
    <div style={{
      position: "absolute", right: "20%", bottom: "30%", width: "30%", height: "55%",
      background: "rgba(13,29,45,0.65)",
    }} />
    {lampGlow && (
      <div style={{
        position: "absolute", left: "50%", top: "55%", transform: "translate(-50%,-50%)",
        width: "90%", height: "140%",
        background: "radial-gradient(ellipse at center, rgba(240,160,64,0.4) 0%, transparent 60%)",
      }} />
    )}
  </div>
);


// ───────────────────────────────────────────────────────────
// Save slot card
// ───────────────────────────────────────────────────────────
const SaveSlot = ({ slot, location, turns, score, date, sceneLabel, isAutosave, isEmpty }) => {
  if (isEmpty) {
    return (
      <button style={{
        width: "100%",
        padding: "16px 14px",
        background: "transparent",
        border: "2px dashed var(--c-paper-ink)",
        color: "var(--c-paper-faded)",
        cursor: "pointer",
        display: "flex",
        alignItems: "center",
        gap: 12,
        textAlign: "left",
        minHeight: 80,
      }}>
        <div style={{
          width: 80, height: 56,
          border: "1.5px dashed var(--c-paper-ink)",
          display: "flex", alignItems: "center", justifyContent: "center",
        }}>
          <Icon name="plus" size={20} color="var(--c-paper-ink)" />
        </div>
        <div style={{ flex: 1 }}>
          <div style={{
            fontFamily: "var(--f-display)", fontSize: 14, fontWeight: 600,
            color: "var(--c-paper-faded)", letterSpacing: "0.02em",
          }}>SLOT {slot} · LIBRE</div>
          <div style={{
            fontFamily: "var(--f-mono)", fontSize: 10,
            color: "var(--c-paper-ink)", marginTop: 4,
          }}>Tap pour sauvegarder ici</div>
        </div>
      </button>
    );
  }
  const cardBg     = isAutosave ? "linear-gradient(180deg, rgba(240,160,64,0.12) 0%, rgba(240,160,64,0.04) 100%)" : "transparent";
  const cardBorder = isAutosave ? "var(--c-amber)" : "var(--c-ink-line)";
  const shadow     = isAutosave ? "3px 3px 0 0 var(--c-amber-shadow)" : "3px 3px 0 0 var(--c-ink-void)";

  return (
    <div role="button" tabIndex={0} style={{
      width: "100%",
      padding: "12px 12px",
      background: cardBg,
      border: `2.5px solid ${cardBorder}`,
      color: "var(--c-paper-warm)",
      cursor: "pointer",
      display: "flex",
      gap: 12,
      textAlign: "left",
      boxShadow: shadow,
    }}>
      <MiniScene label={sceneLabel} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          display: "flex", alignItems: "center", gap: 6, marginBottom: 3,
        }}>
          {isAutosave && (
            <span style={{
              fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.16em",
              color: "var(--c-amber)",
            }}>◆ AUTO</span>
          )}
          {!isAutosave && (
            <span style={{
              fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.14em",
              color: "var(--c-paper-faded)",
            }}>SLOT {slot}</span>
          )}
        </div>
        <div style={{
          fontFamily: "var(--f-display)", fontSize: 15, fontWeight: 700,
          color: "var(--c-paper-bright)", letterSpacing: "0.01em",
          lineHeight: 1.1, marginBottom: 4,
        }}>{location}</div>
        <div style={{
          display: "flex", gap: 10,
          fontFamily: "var(--f-mono)", fontSize: 10,
          color: "var(--c-paper-faded)",
          letterSpacing: "0.04em",
        }}>
          <span>T.{turns}</span>
          <span style={{ color: "var(--c-treasure)" }}>● {score} pts</span>
        </div>
        <div style={{
          fontFamily: "var(--f-body)", fontSize: 11, fontStyle: "italic",
          color: "var(--c-paper-ink)", marginTop: 5,
        }}>{date}</div>
      </div>
      <button style={{
        width: 28, height: 28,
        background: "transparent",
        border: "1.5px solid var(--c-ink-line)",
        color: "var(--c-paper-warm)",
        cursor: "pointer",
        padding: 0,
        display: "flex", alignItems: "center", justifyContent: "center",
        flexShrink: 0,
        alignSelf: "flex-start",
      }}>
        <Icon name="menu" size={11} color="var(--c-paper-faded)" />
      </button>
    </div>
  );
};


// ───────────────────────────────────────────────────────────
// SAVES PAGE
// ───────────────────────────────────────────────────────────
const SavesPage = () => (
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
        }}>◆ TON CARNET DE BORD</div>
        <div style={{
          fontFamily: "var(--f-display)", fontSize: 20, fontWeight: 700,
          color: "var(--c-paper-bright)", letterSpacing: "0.01em", lineHeight: 1,
        }}>SAUVEGARDES</div>
      </div>
      <Pill icon="plus" label="NOUVEAU" tone="amber" />
    </div>

    {/* Body */}
    <div style={{
      flex: 1,
      overflow: "auto",
      padding: "12px 12px 14px",
      background: "var(--c-ink-void)",
    }}>
      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em",
        color: "var(--c-paper-faded)", padding: "0 4px 8px",
      }}>REPRENDRE</div>

      <div style={{ marginBottom: 14 }}>
        <SaveSlot
          isAutosave
          location="HALL DES BRUMES"
          turns="047"
          score="023"
          date="Sauvegardé à chaque tour · il y a 12 secondes"
          sceneLabel="hall_of_mists.webp"
        />
      </div>

      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em",
        color: "var(--c-paper-faded)", padding: "0 4px 8px",
      }}>SLOTS MANUELS · 3 / 5</div>

      <div style={{ display: "flex", flexDirection: "column", gap: 9, marginBottom: 16 }}>
        <SaveSlot
          slot="1"
          location="COTTAGE EN PIERRE"
          turns="012"
          score="002"
          date="Hier soir · 22:14"
          sceneLabel="cottage.webp"
        />
        <SaveSlot
          slot="2"
          location="ANTRE DU DRAGON"
          turns="189"
          score="087"
          date="Il y a 3 jours · 18:30"
          sceneLabel="dragon_lair.webp"
        />
        <SaveSlot
          slot="3"
          location="HALL DU ROI"
          turns="312"
          score="178"
          date="La semaine dernière · 14:08"
          sceneLabel="king_hall.webp"
        />
        <SaveSlot slot="4" isEmpty />
        <SaveSlot slot="5" isEmpty />
      </div>

      {/* Storage info */}
      <div style={{
        padding: "10px 12px",
        border: "1px dashed var(--c-ink-line)",
        background: "rgba(13,29,45,0.5)",
      }}>
        <div style={{
          display: "flex", justifyContent: "space-between", alignItems: "center",
          marginBottom: 8,
        }}>
          <span style={{
            fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.14em",
            color: "var(--c-paper-faded)",
          }}>STOCKAGE LOCAL</span>
          <span style={{
            fontFamily: "var(--f-mono)", fontSize: 10,
            color: "var(--c-paper-warm)",
          }}>248 KB / 5 MB</span>
        </div>
        <div style={{
          height: 6,
          background: "rgba(122,106,78,0.18)",
          border: "1px solid var(--c-paper-ink)",
          position: "relative",
        }}>
          <div style={{
            position: "absolute", left: 0, top: 0, bottom: 0,
            width: "4.8%",
            background: "var(--c-teal-glow)",
          }} />
        </div>
        <div style={{
          fontFamily: "var(--f-mono)", fontSize: 9,
          color: "var(--c-paper-ink)",
          marginTop: 6, letterSpacing: "0.04em",
        }}>$APP/saves/ · 100% offline · aucune télémétrie</div>
      </div>
    </div>
  </PhoneShell>
);

Object.assign(window, { SavesPage, SaveSlot, MiniScene });
