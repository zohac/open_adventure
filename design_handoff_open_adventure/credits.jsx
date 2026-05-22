/* eslint-disable */
// credits.jsx — CreditsPage : lineage of Colossal Cave Adventure
// from Crowther 1976 → Woods 1977 → Raymond 2017 → this port 2026.

// ───────────────────────────────────────────────────────────
// Lineage card — one entry in the heritage timeline
// ───────────────────────────────────────────────────────────
const LineageCard = ({ year, name, role, contribution, tone = "default", icon }) => {
  const tones = {
    default: { border: "var(--c-ink-line)", accent: "var(--c-paper-faded)", glow: "none" },
    primary: { border: "var(--c-amber)",    accent: "var(--c-amber)",       glow: "0 0 16px 2px rgba(240,160,64,0.30)" },
    current: { border: "var(--c-teal-glow)",accent: "var(--c-teal-glow)",   glow: "0 0 16px 2px rgba(78,197,184,0.30)" },
  };
  const t = tones[tone] || tones.default;
  return (
    <div style={{
      position: "relative",
      border: `2.5px solid ${t.border}`,
      background: "rgba(13,29,45,0.6)",
      padding: "14px 14px 14px",
      marginLeft: 28,
      boxShadow: `3px 3px 0 0 var(--c-ink-void), ${t.glow}`,
    }}>
      <CornerBrackets color={t.border} size={7} thickness={1.5} inset={3} />
      {/* Connector dot on the timeline */}
      <div style={{
        position: "absolute",
        left: -34, top: 22,
        width: 12, height: 12,
        background: t.accent,
        border: "2px solid var(--c-ink-void)",
        zIndex: 2,
      }} />
      {/* Connector horizontal line */}
      <div style={{
        position: "absolute",
        left: -22, top: 27,
        width: 19, height: 2,
        background: t.accent,
      }} />

      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.18em",
        color: t.accent, marginBottom: 6,
      }}>◇ {year}</div>

      <div style={{
        display: "flex", alignItems: "center", gap: 8, marginBottom: 4,
      }}>
        {icon && (
          <div style={{
            width: 22, height: 22, flexShrink: 0,
            border: `1.5px solid ${t.accent}`,
            background: "rgba(6,16,26,0.5)",
            display: "flex", alignItems: "center", justifyContent: "center",
          }}>
            <Icon name={icon} size={11} color={t.accent} />
          </div>
        )}
        <div style={{
          fontFamily: "var(--f-display)", fontSize: 17, fontWeight: 700,
          color: "var(--c-paper-bright)", letterSpacing: "0.01em", lineHeight: 1,
        }}>{name}</div>
      </div>

      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.14em",
        color: t.accent, marginBottom: 8, marginLeft: icon ? 30 : 0,
      }}>{role}</div>

      <div style={{
        fontFamily: "var(--f-body)", fontSize: 12, lineHeight: 1.5,
        color: "var(--c-paper-warm)", marginLeft: icon ? 30 : 0,
        textWrap: "pretty",
      }}>{contribution}</div>
    </div>
  );
};


// ───────────────────────────────────────────────────────────
// CREDITS PAGE
// ───────────────────────────────────────────────────────────
const CreditsPage = () => (
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
        }}>◆ HÉRITAGE</div>
        <div style={{
          fontFamily: "var(--f-display)", fontSize: 20, fontWeight: 700,
          color: "var(--c-paper-bright)", letterSpacing: "0.01em", lineHeight: 1,
        }}>CRÉDITS</div>
      </div>
    </div>

    {/* Body */}
    <div style={{
      flex: 1,
      overflow: "auto",
      padding: "16px 12px 16px",
      background: "var(--c-ink-void)",
      position: "relative",
    }}>
      {/* Hero quote */}
      <div style={{
        textAlign: "center",
        padding: "8px 8px 20px",
      }}>
        <div style={{
          fontFamily: "var(--f-display)", fontSize: 26, fontWeight: 700,
          color: "var(--c-paper-bright)", letterSpacing: "0.02em",
          textShadow: "2px 2px 0 var(--c-amber-shadow)",
          lineHeight: 1,
          marginBottom: 10,
        }}>COLOSSAL CAVE<br/>ADVENTURE</div>
        <div style={{
          fontFamily: "var(--f-body)", fontStyle: "italic", fontSize: 12,
          color: "var(--c-paper-faded)", lineHeight: 1.4,
          maxWidth: 280, margin: "0 auto",
        }}>
          « You are standing at the end of a road before a small brick building. Around you is a forest. »
        </div>
        <div style={{
          fontFamily: "var(--f-mono)", fontSize: 10,
          color: "var(--c-paper-ink)",
          marginTop: 8, letterSpacing: "0.06em",
        }}>— premier verset, 1976</div>
      </div>

      <PixelDivider style={{ margin: "0 24px 18px" }} />

      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em",
        color: "var(--c-paper-faded)", padding: "0 8px 12px",
      }}>◇ LIGNÉE — 50 ANS</div>

      {/* Timeline rail */}
      <div style={{ position: "relative", paddingLeft: 0 }}>
        <div style={{
          position: "absolute",
          left: 22, top: 6, bottom: 6,
          width: 2,
          background: "repeating-linear-gradient(180deg, var(--c-paper-ink) 0 5px, transparent 5px 10px)",
          zIndex: 1,
        }} />

        <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
          <LineageCard
            year="1975 – 1976"
            name="Will Crowther"
            role="Créateur original · ingénieur BBN"
            contribution="Programmeur et spéléologue, écrit le jeu originel en FORTRAN sur le PDP-10. Inspiré par la grotte Mammoth Cave (Kentucky) qu'il explorait avec sa famille. Première forme : ~70 lieux, simulation purement caverneuse."
            icon="pin"
            tone="default"
          />
          <LineageCard
            year="1977"
            name="Don Woods"
            role="Extension fantastique · Stanford SAIL"
            contribution="Étudiant à Stanford, il découvre le code de Crowther, obtient son accord pour l'étendre. Ajoute trolls, nains, dragon, trésors, magie, fin de partie scorée — la version 350 points est née. Devient « Colossal Cave Adventure »."
            icon="star"
            tone="default"
          />
          <LineageCard
            year="2017 – aujourd'hui"
            name="Eric S. Raymond"
            role="Open Adventure 2.5 · BSD 2-clauses"
            contribution="Avec l'accord de Crowther et Woods, libère et modernise le code C : portage propre, données YAML générant les JSON utilisés ici, extension à 430 points, tests de non-régression. Source d'oracle de notre moteur."
            icon="book"
            tone="primary"
          />
          <LineageCard
            year="2026"
            name="Open Adventure — Flutter"
            role="Portage mobile pixel-art · 100% offline"
            contribution="Reboot Flutter Clean Architecture, UI tactile sans clavier (3–7 boutons contextuels), DA 16-bit SNES/Megadrive, FR/EN, sauvegardes locales JSON versionnées. Fidélité gameplay vérifiée par oracle C."
            icon="lamp"
            tone="current"
          />
        </div>
      </div>

      {/* License & footer */}
      <div style={{
        marginTop: 24,
        padding: "14px 14px",
        border: "2px solid var(--c-ink-line)",
        background: "rgba(13,29,45,0.5)",
      }}>
        <div style={{
          fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.16em",
          color: "var(--c-amber)", marginBottom: 8,
        }}>◆ LICENCE & REMERCIEMENTS</div>
        <div style={{
          fontFamily: "var(--f-body)", fontSize: 11, lineHeight: 1.5,
          color: "var(--c-paper-warm)",
        }}>
          Code et données dérivés d'<strong style={{ color: "var(--c-paper-bright)" }}>Open Adventure 2.5</strong> sous licence <strong style={{ color: "var(--c-amber)" }}>BSD 2-clauses</strong>. Aucun trésor pris, aucune télémétrie. Avec gratitude pour Will Crowther, Don Woods, Eric S. Raymond, et la communauté qui a maintenu le récit en vie cinquante ans durant.
        </div>
      </div>

      <div style={{
        marginTop: 16,
        textAlign: "center",
        fontFamily: "var(--f-mono)", fontSize: 9,
        color: "var(--c-paper-ink)",
        letterSpacing: "0.06em",
        lineHeight: 1.6,
      }}>
        Open Adventure Mobile v1.0.0<br/>
        Flutter 3.35 · Dart 3 · ~658 KB d'assets<br/>
        — fin —
      </div>
    </div>
  </PhoneShell>
);

Object.assign(window, { CreditsPage, LineageCard });
