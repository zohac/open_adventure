/* eslint-disable */
// action-buttons.jsx — single button family: STAMPS (rubber-stamp pills).
// Used for action lists, menu items, primary CTAs. One grammar, many tones.
//
// Anatomy of a stamp:
//   border: 2.5px solid — the rubber edge
//   shadow: 3px 3px 0   — the press onto paper
//   caps:   Silkscreen  — the stamped text
//   two fills: outlined (paper showing) or filled (inked solid)

// ───────────────────────────────────────────────────────────
// Core token table for stamp tones
// ───────────────────────────────────────────────────────────
const STAMP_TONES = {
  // OUTLINED — border only, transparent fill
  default: { bg: "transparent",            border: "var(--c-paper-warm)",  fg: "var(--c-paper-warm)",  sh: "var(--c-ink-void)" },
  meta:    { bg: "transparent",            border: "var(--c-teal-glow)",   fg: "var(--c-teal-glow)",   sh: "var(--c-ink-void)" },
  faded:   { bg: "transparent",            border: "var(--c-paper-ink)",   fg: "var(--c-paper-faded)", sh: "var(--c-ink-void)" },
  danger:  { bg: "transparent",            border: "var(--c-danger)",      fg: "var(--c-danger)",      sh: "var(--c-ink-void)" },
  // FILLED — primary ink stamps
  primary: { bg: "var(--c-amber)",         border: "var(--c-amber-shadow)",fg: "var(--c-ink-void)",    sh: "var(--c-amber-shadow)" },
  treasure:{ bg: "var(--c-treasure)",      border: "var(--c-amber-shadow)",fg: "var(--c-ink-void)",    sh: "var(--c-amber-shadow)" },
  hostile: { bg: "var(--c-danger)",        border: "#7a2418",              fg: "var(--c-paper-bright)",sh: "#3a0d08" },
  // MAGIC — incantation, contextual only (DDR-001 Option A)
  magic:   { bg: "rgba(152,112,196,0.16)", border: "var(--c-magic)",       fg: "var(--c-magic)",       sh: "#3d2a55" },
};


// ───────────────────────────────────────────────────────────
// STAMP BUTTON · action list row (default usage)
// One-liner: icon · label · hint
// ───────────────────────────────────────────────────────────
const StampButton = ({ icon, label, hint, tone = "default", disabled }) => {
  const t = STAMP_TONES[tone] || STAMP_TONES.default;
  return (
    <button disabled={disabled} style={{
      width: "100%",
      minHeight: 48,
      padding: "11px 14px",
      display: "flex",
      alignItems: "center",
      gap: 12,
      background: t.bg,
      border: `2.5px solid ${t.border}`,
      color: t.fg,
      fontFamily: "var(--f-caps)",
      fontSize: 12,
      letterSpacing: "0.1em",
      textTransform: "uppercase",
      textAlign: "left",
      cursor: disabled ? "not-allowed" : "pointer",
      position: "relative",
      boxShadow: `3px 3px 0 0 ${t.sh}`,
      opacity: disabled ? 0.45 : 1,
      lineHeight: 1,
    }}>
      {icon && <Icon name={icon} size={16} color={t.fg} />}
      <span style={{ flex: 1, fontWeight: 400 }}>{label}</span>
      {hint && (
        <span style={{
          fontFamily: "var(--f-mono)",
          fontSize: 10,
          letterSpacing: 0,
          opacity: 0.7,
          textTransform: "none",
        }}>{hint}</span>
      )}
    </button>
  );
};


// ───────────────────────────────────────────────────────────
// STAMP MENU ITEM · taller stamp with title (display) + sub
// Used on Home for the main menu rows.
// ───────────────────────────────────────────────────────────
const StampMenuItem = ({ icon, title, sub, tone = "default" }) => {
  const t = STAMP_TONES[tone] || STAMP_TONES.default;
  return (
    <button style={{
      width: "100%",
      minHeight: 56,
      padding: "12px 14px",
      display: "flex",
      alignItems: "center",
      gap: 14,
      background: t.bg,
      border: `2.5px solid ${t.border}`,
      color: t.fg,
      cursor: "pointer",
      position: "relative",
      boxShadow: `3px 3px 0 0 ${t.sh}`,
      textAlign: "left",
    }}>
      {icon && (
        <div style={{
          width: 32, height: 32,
          display: "flex", alignItems: "center", justifyContent: "center",
          background: tone === "primary" || tone === "treasure" || tone === "hostile"
            ? "rgba(6,16,26,0.18)"
            : "rgba(240,228,204,0.05)",
          border: `1.5px solid ${t.border}`,
        }}>
          <Icon name={icon} size={16} color={t.fg} />
        </div>
      )}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          fontFamily: "var(--f-display)",
          fontSize: 16,
          fontWeight: 700,
          letterSpacing: "0.02em",
          lineHeight: 1,
        }}>{title}</div>
        {sub && (
          <div style={{
            fontFamily: "var(--f-mono)",
            fontSize: 10,
            letterSpacing: "0.04em",
            opacity: 0.7,
            marginTop: 5,
            textTransform: "none",
          }}>{sub}</div>
        )}
      </div>
      <span style={{ fontFamily: "var(--f-display)", fontSize: 18, opacity: 0.6, lineHeight: 1 }}>›</span>
    </button>
  );
};


// ───────────────────────────────────────────────────────────
// BOTTOM NAV · 4 tabs (Inventaire / Carte / Journal / Menu)
// Stamp-grammar: active tab gets an amber top edge & tint.
// ───────────────────────────────────────────────────────────
const BottomNav = ({ active = "inventory" }) => {
  const tabs = [
    { id: "inventory", label: "Sac",     icon: "bag" },
    { id: "map",       label: "Carte",   icon: "map" },
    { id: "journal",   label: "Journal", icon: "book" },
    { id: "menu",      label: "Menu",    icon: "menu" },
  ];
  return (
    <div style={{
      display: "flex",
      borderTop: "2px solid var(--c-ink-line)",
      background: "var(--c-ink-deep)",
    }}>
      {tabs.map(t => {
        const isActive = t.id === active;
        return (
          <button key={t.id} style={{
            flex: 1,
            background: isActive ? "rgba(240,160,64,0.08)" : "transparent",
            border: "none",
            borderTop: isActive ? "2px solid var(--c-amber)" : "2px solid transparent",
            marginTop: -2,
            padding: "10px 4px 12px",
            cursor: "pointer",
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 5,
            color: isActive ? "var(--c-amber)" : "var(--c-teal-mist)",
          }}>
            <Icon name={t.icon} size={18} color={isActive ? "var(--c-amber)" : "var(--c-teal-mist)"} />
            <span style={{
              fontFamily: "var(--f-caps)",
              fontSize: 10,
              letterSpacing: "0.08em",
              textTransform: "uppercase",
            }}>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
};

Object.assign(window, { StampButton, StampMenuItem, BottomNav, STAMP_TONES });
