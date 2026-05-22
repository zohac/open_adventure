/* eslint-disable */
// journal.jsx — JournalPage : chronological feed of canonical messages.
// Filter chips · grouped by turn · color-coded categories · running counters.

// ───────────────────────────────────────────────────────────
// Journal entry component
// ───────────────────────────────────────────────────────────
const JournalEntry = ({ turn, time, icon, category, text, tone = "info" }) => {
  const tones = {
    info:      { fg: "var(--c-paper-warm)",  accent: "var(--c-teal-mist)" },
    travel:    { fg: "var(--c-paper-warm)",  accent: "var(--c-amber)" },
    discovery: { fg: "var(--c-treasure)",    accent: "var(--c-treasure)" },
    danger:    { fg: "var(--c-danger)",      accent: "var(--c-danger)" },
    magic:     { fg: "var(--c-magic)",       accent: "var(--c-magic)" },
    success:   { fg: "var(--c-success)",     accent: "var(--c-success)" },
    system:    { fg: "var(--c-paper-faded)", accent: "var(--c-paper-ink)" },
  };
  const t = tones[tone] || tones.info;
  return (
    <div style={{
      display: "flex",
      gap: 10,
      padding: "10px 12px",
      borderLeft: `3px solid ${t.accent}`,
      background: "rgba(13,29,45,0.4)",
      marginBottom: 6,
    }}>
      <div style={{
        flexShrink: 0,
        display: "flex", flexDirection: "column", alignItems: "center", gap: 4,
      }}>
        <div style={{
          width: 22, height: 22,
          border: `1.5px solid ${t.accent}`,
          background: "rgba(6,16,26,0.6)",
          display: "flex", alignItems: "center", justifyContent: "center",
        }}>
          <Icon name={icon} size={11} color={t.accent} />
        </div>
        <div style={{
          fontFamily: "var(--f-mono)", fontSize: 9,
          color: "var(--c-paper-ink)", lineHeight: 1,
          letterSpacing: "0.04em",
        }}>{turn}</div>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          display: "flex", alignItems: "center", gap: 6, marginBottom: 4,
        }}>
          <span style={{
            fontFamily: "var(--f-caps)", fontSize: 9,
            letterSpacing: "0.12em", color: t.accent,
          }}>{category}</span>
          <span style={{
            fontFamily: "var(--f-mono)", fontSize: 9,
            color: "var(--c-paper-ink)",
          }}>· {time}</span>
        </div>
        <div style={{
          fontFamily: "var(--f-body)", fontSize: 13, lineHeight: 1.4,
          color: t.fg, textWrap: "pretty",
        }}>{text}</div>
      </div>
    </div>
  );
};


// ───────────────────────────────────────────────────────────
// Filter chip
// ───────────────────────────────────────────────────────────
const FilterChip = ({ icon, label, count, active }) => (
  <button style={{
    flexShrink: 0,
    display: "inline-flex", alignItems: "center", gap: 5,
    padding: "5px 9px",
    background: active ? "var(--c-amber)" : "transparent",
    border: active ? "2px solid var(--c-amber-shadow)" : "2px solid var(--c-ink-line)",
    color: active ? "var(--c-ink-void)" : "var(--c-paper-warm)",
    fontFamily: "var(--f-caps)",
    fontSize: 10,
    letterSpacing: "0.08em",
    textTransform: "uppercase",
    cursor: "pointer",
    lineHeight: 1,
    boxShadow: active ? "2px 2px 0 0 var(--c-amber-shadow)" : "none",
  }}>
    {icon && <Icon name={icon} size={10} color="currentColor" />}
    {label}
    {count != null && (
      <span style={{
        fontFamily: "var(--f-mono)", fontSize: 9,
        opacity: 0.7,
      }}>{count}</span>
    )}
  </button>
);


// ───────────────────────────────────────────────────────────
// JOURNAL PAGE
// ───────────────────────────────────────────────────────────
const JournalPage = () => (
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
        }}>◆ TON RÉCIT</div>
        <div style={{
          fontFamily: "var(--f-display)", fontSize: 20, fontWeight: 700,
          color: "var(--c-paper-bright)", letterSpacing: "0.01em", lineHeight: 1,
        }}>JOURNAL</div>
      </div>
      <Pill label="ENTRÉES" value="187/200" tone="default" />
    </div>

    {/* Filter chips */}
    <div style={{
      padding: "8px 10px 10px",
      display: "flex",
      gap: 6,
      overflowX: "auto",
      borderBottom: "1px solid var(--c-ink-hairline)",
    }}>
      <FilterChip label="Tout" count={187} active />
      <FilterChip icon="pin"  label="Lieux"     count={42} />
      <FilterChip icon="coin" label="Trésors"   count={14} />
      <FilterChip icon="close" label="Combats"  count={8} />
      <FilterChip icon="magic" label="Magie"    count={3} />
      <FilterChip icon="lamp"  label="Lampe"    count={6} />
    </div>

    {/* Feed */}
    <div style={{
      flex: 1,
      overflow: "auto",
      padding: "10px 10px 14px",
      background: "var(--c-ink-void)",
    }}>
      {/* Current turn header */}
      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em",
        color: "var(--c-amber)", padding: "0 4px 8px",
        display: "flex", alignItems: "center", justifyContent: "space-between",
      }}>
        <span>◆ TOUR EN COURS · 189</span>
        <span style={{ fontFamily: "var(--f-mono)", fontSize: 9, color: "var(--c-paper-ink)" }}>21:47</span>
      </div>

      <JournalEntry turn="t.189" time="21:47" icon="coin"  category="DÉCOUVERTE"
        tone="discovery"
        text="Une coupe d'or martelé scintille au sol, parmi les ossements." />
      <JournalEntry turn="t.189" time="21:47" icon="pin" category="LIEU"
        tone="travel"
        text="Tu es dans l'antre du dragon. L'air est tiède et sent la poussière dorée." />

      {/* Earlier turn header */}
      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em",
        color: "var(--c-paper-faded)", padding: "12px 4px 8px",
      }}>◇ TOUR 188</div>

      <JournalEntry turn="t.188" time="21:46" icon="east" category="MOUVEMENT"
        tone="info"
        text="Tu avances prudemment vers l'est, dans une cavité plus large." />

      {/* Earlier turn */}
      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em",
        color: "var(--c-paper-faded)", padding: "12px 4px 8px",
      }}>◇ TOUR 186</div>

      <JournalEntry turn="t.186" time="21:44" icon="magic" category="INCANTATION"
        tone="magic"
        text="Tu prononces XYZZY. Une lueur t'enveloppe — tu te retrouves dans le cottage en pierre." />

      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em",
        color: "var(--c-paper-faded)", padding: "12px 4px 8px",
      }}>◇ TOUR 184</div>

      <JournalEntry turn="t.184" time="21:42" icon="lamp" category="ALERTE"
        tone="danger"
        text="La lampe faiblit. Il te reste 29 tours avant que la flamme ne s'éteigne." />

      <JournalEntry turn="t.183" time="21:42" icon="bird" category="OISEAU"
        tone="magic"
        text="L'oiseau te chante un mot magique : XYZZY. Tu le notes mentalement." />

      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em",
        color: "var(--c-paper-faded)", padding: "12px 4px 8px",
      }}>◇ TOUR 181</div>

      <JournalEntry turn="t.181" time="21:41" icon="take" category="OBJET"
        tone="success"
        text="Tu prends le petit oiseau dans sa cage en osier." />

      <JournalEntry turn="t.180" time="21:40" icon="eye" category="OBSERVATION"
        tone="system"
        text="Tu te tiens dans une petite chambre tapissée de mousse. Un oiseau chante." />

      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em",
        color: "var(--c-paper-faded)", padding: "12px 4px 8px",
      }}>◇ TOUR 178</div>

      <JournalEntry turn="t.178" time="21:38" icon="close" category="COMBAT"
        tone="danger"
        text="Un nain surgit et te lance sa hache. Tu esquives de justesse." />

      {/* End-of-feed marker */}
      <div style={{
        textAlign: "center",
        padding: "20px 0 8px",
        fontFamily: "var(--f-mono)", fontSize: 10,
        color: "var(--c-paper-ink)",
        letterSpacing: "0.06em",
      }}>
        ─── 187 entrées · plus loin dans l'historique ───
      </div>
    </div>

    <BottomNav active="journal" />
  </PhoneShell>
);

Object.assign(window, { JournalPage, JournalEntry, FilterChip });
