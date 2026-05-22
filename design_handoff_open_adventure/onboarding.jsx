/* eslint-disable */
// onboarding.jsx — first-launch tutorial : 3 cards introducing the core
// mechanics. Hero illustration + title + body + progress dots + CTAs.
//   1 · Tu n'écris pas, tu choisis     (button-driven UI)
//   2 · La lanterne est ton souffle    (diegetic lamp)
//   3 · Le carnet retient tout         (journal · map · saves)

// ───────────────────────────────────────────────────────────
// Progress dots component
// ───────────────────────────────────────────────────────────
const ProgressDots = ({ count = 3, active = 0 }) => (
  <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
    {Array.from({ length: count }).map((_, i) => (
      <div key={i} style={{
        width: i === active ? 18 : 8,
        height: 8,
        background: i === active ? "var(--c-amber)" : "rgba(122,106,78,0.35)",
        border: i === active ? "1px solid var(--c-amber-shadow)" : "1px solid var(--c-paper-ink)",
      }} />
    ))}
  </div>
);


// ───────────────────────────────────────────────────────────
// Onboarding shell — common layout
// ───────────────────────────────────────────────────────────
const OnboardingShell = ({ step, total = 3, eyebrow, title, body, hero, nextLabel = "Suivant", isLast }) => (
  <PhoneShell>
    <FakeStatusBar tint="var(--c-paper-faded)" />

    {/* Skip in top-right */}
    <div style={{
      position: "absolute", right: 14, top: 32,
      zIndex: 5,
    }}>
      <button style={{
        background: "transparent",
        border: "none",
        color: "var(--c-paper-faded)",
        fontFamily: "var(--f-caps)",
        fontSize: 10,
        letterSpacing: "0.14em",
        textTransform: "uppercase",
        padding: 6,
        cursor: "pointer",
      }}>Passer ›</button>
    </div>

    {/* Hero zone */}
    <div style={{
      flex: "0 0 320px",
      position: "relative",
      background: "radial-gradient(ellipse at center, rgba(240,160,64,0.16) 0%, transparent 60%)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      overflow: "hidden",
      borderBottom: "1.5px dashed var(--c-ink-line)",
    }}>
      {/* faint grid bg */}
      <div style={{
        position: "absolute", inset: 0,
        backgroundImage: `
          repeating-linear-gradient(0deg, transparent 0 19px, rgba(78,197,184,0.06) 19px 20px),
          repeating-linear-gradient(90deg, transparent 0 19px, rgba(78,197,184,0.06) 19px 20px)
        `,
      }} />
      <div style={{ position: "relative", zIndex: 1, width: "100%", padding: "0 32px" }}>
        {hero}
      </div>
    </div>

    {/* Text zone */}
    <div style={{
      flex: 1,
      padding: "24px 24px 0",
      display: "flex",
      flexDirection: "column",
    }}>
      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.24em",
        color: "var(--c-amber)", marginBottom: 10,
      }}>◆ {eyebrow}</div>
      <h1 style={{
        margin: 0,
        fontFamily: "var(--f-display)", fontSize: 26, fontWeight: 700,
        color: "var(--c-paper-bright)", letterSpacing: "0.01em",
        lineHeight: 1.05,
        textShadow: "2px 2px 0 var(--c-amber-shadow)",
      }}>{title}</h1>
      <p style={{
        marginTop: 14, marginBottom: 0,
        fontFamily: "var(--f-body)", fontSize: 14, lineHeight: 1.55,
        color: "var(--c-paper-warm)",
        textWrap: "pretty",
      }}>{body}</p>
    </div>

    {/* Footer */}
    <div style={{
      padding: "14px 20px 18px",
      borderTop: "1px solid var(--c-ink-hairline)",
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      gap: 14,
    }}>
      <ProgressDots count={total} active={step} />
      <button style={{
        minHeight: 44,
        padding: "10px 16px",
        background: isLast ? "var(--c-amber)" : "transparent",
        border: isLast ? "2.5px solid var(--c-amber-shadow)" : "2.5px solid var(--c-paper-warm)",
        color: isLast ? "var(--c-ink-void)" : "var(--c-paper-warm)",
        fontFamily: "var(--f-caps)",
        fontSize: 12,
        letterSpacing: "0.1em",
        textTransform: "uppercase",
        boxShadow: isLast ? "3px 3px 0 0 var(--c-amber-shadow)" : "3px 3px 0 0 var(--c-ink-void)",
        display: "flex", alignItems: "center", gap: 8,
        cursor: "pointer",
      }}>
        <span>{nextLabel}</span>
        <span style={{ fontFamily: "var(--f-display)", fontSize: 16 }}>›</span>
      </button>
    </div>
  </PhoneShell>
);


// ───────────────────────────────────────────────────────────
// HERO 1 · stack of stamp buttons with the top one being "tapped"
// ───────────────────────────────────────────────────────────
const Hero1 = () => (
  <div style={{ display: "flex", flexDirection: "column", gap: 8, position: "relative" }}>
    {/* "tap" indicator */}
    <div style={{
      position: "absolute",
      right: 8, top: 22,
      width: 26, height: 26,
      border: "2px solid var(--c-amber)",
      borderRadius: "50%",
      zIndex: 3,
      boxShadow: "0 0 0 6px rgba(240,160,64,0.18), 0 0 0 11px rgba(240,160,64,0.08)",
    }} />
    <div style={{
      position: "absolute",
      right: 14, top: 28,
      width: 14, height: 14,
      background: "var(--c-amber)",
      zIndex: 4,
    }} />
    {/* mock stamp buttons */}
    <div style={{
      padding: "10px 12px",
      background: "var(--c-amber)",
      border: "2.5px solid var(--c-amber-shadow)",
      color: "var(--c-ink-void)",
      fontFamily: "var(--f-caps)", fontSize: 11, letterSpacing: "0.1em",
      textTransform: "uppercase",
      display: "flex", alignItems: "center", gap: 8,
      boxShadow: "3px 3px 0 0 var(--c-amber-shadow)",
    }}>
      <Icon name="north" size={14} color="var(--c-ink-void)" />
      <span style={{ flex: 1 }}>Aller au nord</span>
      <span style={{ fontFamily: "var(--f-mono)", fontSize: 9, opacity: 0.6, textTransform: "none" }}>N</span>
    </div>
    <div style={{
      padding: "10px 12px",
      background: "transparent",
      border: "2.5px solid var(--c-paper-warm)",
      color: "var(--c-paper-warm)",
      fontFamily: "var(--f-caps)", fontSize: 11, letterSpacing: "0.1em",
      textTransform: "uppercase",
      display: "flex", alignItems: "center", gap: 8,
      boxShadow: "3px 3px 0 0 rgba(6,16,26,0.6)",
    }}>
      <Icon name="east" size={14} color="var(--c-paper-warm)" />
      <span style={{ flex: 1 }}>Aller à l'est</span>
      <span style={{ fontFamily: "var(--f-mono)", fontSize: 9, opacity: 0.6, textTransform: "none" }}>E</span>
    </div>
    <div style={{
      padding: "10px 12px",
      background: "transparent",
      border: "2.5px solid var(--c-teal-glow)",
      color: "var(--c-teal-glow)",
      fontFamily: "var(--f-caps)", fontSize: 11, letterSpacing: "0.1em",
      textTransform: "uppercase",
      display: "flex", alignItems: "center", gap: 8,
      boxShadow: "3px 3px 0 0 rgba(6,16,26,0.6)",
    }}>
      <Icon name="eye" size={14} color="var(--c-teal-glow)" />
      <span style={{ flex: 1 }}>Observer le lieu</span>
      <span style={{ fontFamily: "var(--f-mono)", fontSize: 9, opacity: 0.6, textTransform: "none" }}>LOOK</span>
    </div>
  </div>
);


// ───────────────────────────────────────────────────────────
// HERO 2 · the lantern, large, with halo + tour counter
// ───────────────────────────────────────────────────────────
const Hero2 = () => (
  <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 14 }}>
    <div style={{
      width: 110, height: 110,
      background: "rgba(240,160,64,0.10)",
      border: "3px solid var(--c-amber)",
      boxShadow: "0 0 28px 6px rgba(240,160,64,0.45), 4px 4px 0 0 var(--c-ink-void)",
      display: "flex", alignItems: "center", justifyContent: "center",
      position: "relative",
    }}>
      <CornerBrackets color="var(--c-amber-shadow)" size={10} thickness={2} inset={4} />
      <Icon name="lamp" size={64} color="var(--c-amber-glow)" />
    </div>
    {/* 3 states preview */}
    <div style={{ display: "flex", gap: 14, alignItems: "flex-end" }}>
      {[
        { st: "bright", t: 285, lbl: "PLEINE" },
        { st: "dim",    t: 29,  lbl: "FAIBLE" },
        { st: "dark",   t: 0,   lbl: "ÉTEINTE" },
      ].map(s => (
        <div key={s.st} style={{ textAlign: "center" }}>
          <LampShortcut state={s.st} turns={s.t} />
        </div>
      ))}
    </div>
  </div>
);


// ───────────────────────────────────────────────────────────
// HERO 3 · stack of carnet pages (journal + map + saves)
// ───────────────────────────────────────────────────────────
const Hero3 = () => (
  <div style={{ position: "relative", height: 220 }}>
    {/* back card — Map */}
    <div style={{
      position: "absolute", left: 8, top: 16, right: 70, bottom: 24,
      background: "rgba(13,29,45,0.7)",
      border: "2px solid var(--c-teal-mist)",
      transform: "rotate(-4deg)",
      boxShadow: "3px 3px 0 0 var(--c-ink-void)",
      padding: 8,
    }}>
      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.14em",
        color: "var(--c-teal-mist)",
      }}>◇ CARTE</div>
      <div style={{
        marginTop: 8,
        display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: 4,
      }}>
        {Array.from({ length: 12 }).map((_, i) => (
          <div key={i} style={{
            height: 10,
            background: i === 5 ? "var(--c-amber)"
                     : i % 3 === 0 ? "rgba(240,228,204,0.4)"
                     : "rgba(78,197,184,0.2)",
          }} />
        ))}
      </div>
    </div>

    {/* mid card — Saves */}
    <div style={{
      position: "absolute", left: 28, top: 32, right: 30, bottom: 12,
      background: "rgba(13,29,45,0.85)",
      border: "2px solid var(--c-amber)",
      transform: "rotate(2deg)",
      boxShadow: "3px 3px 0 0 var(--c-ink-void)",
      padding: 8,
    }}>
      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.14em",
        color: "var(--c-amber)",
      }}>◇ SAUVEGARDES · AUTO</div>
      <div style={{ marginTop: 6, display: "flex", gap: 6, alignItems: "center" }}>
        <MiniScene w={50} h={32} />
        <div style={{
          fontFamily: "var(--f-display)", fontSize: 11, fontWeight: 700,
          color: "var(--c-paper-bright)",
        }}>HALL DES BRUMES</div>
      </div>
    </div>

    {/* front card — Journal */}
    <div style={{
      position: "absolute", left: 60, top: 50, right: 8, bottom: 0,
      background: "var(--c-ink-deep)",
      border: "2.5px solid var(--c-paper-warm)",
      transform: "rotate(-1deg)",
      boxShadow: "4px 4px 0 0 var(--c-ink-void)",
      padding: 10,
    }}>
      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.14em",
        color: "var(--c-paper-bright)",
      }}>◇ JOURNAL · 187</div>
      <div style={{ marginTop: 6 }}>
        <div style={{
          fontFamily: "var(--f-mono)", fontSize: 8, color: "var(--c-paper-ink)",
        }}>t.189 · DÉCOUVERTE</div>
        <div style={{
          fontFamily: "var(--f-body)", fontSize: 10, fontStyle: "italic",
          color: "var(--c-treasure)", marginTop: 2, lineHeight: 1.3,
        }}>« Une coupe d'or martelé scintille au sol… »</div>
      </div>
      <div style={{ marginTop: 8 }}>
        <div style={{
          fontFamily: "var(--f-mono)", fontSize: 8, color: "var(--c-paper-ink)",
        }}>t.184 · ALERTE</div>
        <div style={{
          fontFamily: "var(--f-body)", fontSize: 10, fontStyle: "italic",
          color: "var(--c-danger)", marginTop: 2, lineHeight: 1.3,
        }}>« La lampe faiblit · 29 tours… »</div>
      </div>
    </div>
  </div>
);


// ───────────────────────────────────────────────────────────
// Three step screens
// ───────────────────────────────────────────────────────────
const Onboarding1 = () => (
  <OnboardingShell
    step={0}
    eyebrow="01 — INTERFACE"
    title="TU N'ÉCRIS PAS, TU CHOISIS"
    body="À chaque tour, le jeu te propose 3 à 7 actions vraiment utiles. Tape l'une d'elles — la mise en avant ambre indique le choix recommandé. Pas de clavier, juste des tampons à presser."
    nextLabel="Suivant"
    hero={<Hero1 />}
  />
);

const Onboarding2 = () => (
  <OnboardingShell
    step={1}
    eyebrow="02 — LA LANTERNE"
    title="ELLE EST TON SOUFFLE"
    body="Sa flamme s'épuise tour après tour. Tant qu'elle brûle, tu vois. Quand elle faiblit, l'écran te prévient. Quand elle s'éteint, l'obscurité te dévore. Tape la lanterne pour l'allumer ou l'éteindre."
    nextLabel="Suivant"
    hero={<Hero2 />}
  />
);

const Onboarding3 = () => (
  <OnboardingShell
    step={2}
    isLast
    eyebrow="03 — TON CARNET"
    title="IL RETIENT TOUT"
    body="Carte, journal, sauvegardes — l'aventure se sauvegarde à chaque tour. Reviens en arrière, relis tes pas, repars d'une vieille partie. Rien ne sort jamais du téléphone."
    nextLabel="Commencer"
    hero={<Hero3 />}
  />
);

Object.assign(window, {
  Onboarding1, Onboarding2, Onboarding3,
  OnboardingShell, ProgressDots,
  Hero1, Hero2, Hero3,
});
