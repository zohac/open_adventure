/* eslint-disable */
// motion-spec.jsx — DS section showcasing the motion vocabulary with
// live looping demos and timing/easing specs. Mirrors motion.css 1:1.
// Note: must run AFTER design-system.jsx loaded (depends on Card, SubLabel, MonoTag).

// ───────────────────────────────────────────────────────────
// MotionCard · one row of the spec
// ───────────────────────────────────────────────────────────
const MotionCard = ({ num, name, useCase, duration, easing, demo }) => (
  <div style={{
    border: "2px solid var(--c-ink-line)",
    background: "rgba(13,29,45,0.6)",
    padding: 16,
    display: "grid",
    gridTemplateColumns: "150px 1fr 1fr",
    gap: 18,
    alignItems: "center",
    position: "relative",
    overflow: "hidden",
  }}>
    <CornerBrackets color="var(--c-amber)" size={6} thickness={1} inset={3} />
    {/* Demo area */}
    <div style={{
      height: 110,
      width: 150,
      display: "flex", alignItems: "center", justifyContent: "center",
      background: "rgba(6,16,26,0.6)",
      border: "1px dashed var(--c-ink-line)",
      position: "relative",
      overflow: "hidden",
    }}>
      {demo}
    </div>

    {/* Metadata */}
    <div>
      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.18em",
        color: "var(--c-amber)", marginBottom: 4,
      }}>◆ MOTION · {num}</div>
      <div style={{
        fontFamily: "var(--f-display)", fontSize: 18, fontWeight: 700,
        color: "var(--c-paper-bright)", letterSpacing: "0.01em", lineHeight: 1.05,
        marginBottom: 6,
      }}>{name}</div>
      <div style={{
        fontFamily: "var(--f-body)", fontSize: 12,
        color: "var(--c-paper-faded)", lineHeight: 1.4,
      }}>{useCase}</div>
    </div>

    {/* Spec */}
    <div style={{
      fontFamily: "var(--f-mono)", fontSize: 10,
      color: "var(--c-paper-warm)",
      lineHeight: 1.7,
      borderLeft: "1px dashed var(--c-ink-line)",
      paddingLeft: 14,
    }}>
      <div><span style={{ color: "var(--c-paper-ink)" }}>dur ·</span> {duration}</div>
      <div><span style={{ color: "var(--c-paper-ink)" }}>ease ·</span> {easing}</div>
      <div><span style={{ color: "var(--c-paper-ink)" }}>class ·</span> <span style={{ color: "var(--c-amber)" }}>.{`oa-anim-${name.toLowerCase().replace(/[^a-z0-9]+/g, "-")}`}</span></div>
    </div>
  </div>
);


// ───────────────────────────────────────────────────────────
// Demo bricks — minimal reproductions that loop the animations
// ───────────────────────────────────────────────────────────

// 1 · Stamp press
const DemoStampPress = () => (
  <div className="oa-anim-stamp-press" style={{
    padding: "8px 12px",
    background: "var(--c-amber)",
    border: "2.5px solid var(--c-amber-shadow)",
    color: "var(--c-ink-void)",
    fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.1em",
    textTransform: "uppercase",
    display: "flex", alignItems: "center", gap: 6,
    boxShadow: "3px 3px 0 0 var(--c-ink-void)",
  }}>
    <Icon name="north" size={11} color="var(--c-ink-void)" />
    <span>Aller</span>
  </div>
);

// 2 · Lamp flicker (bright lamp idle pulse)
const DemoLampFlicker = () => (
  <div className="oa-anim-lamp-flicker" style={{
    padding: "6px 8px",
    background: "rgba(240,160,64,0.14)",
    border: "2.5px solid var(--c-amber)",
    color: "var(--c-amber-glow)",
    display: "flex", alignItems: "center", justifyContent: "center",
  }}>
    <Icon name="lamp" size={22} color="var(--c-amber-glow)" />
  </div>
);

// 3 · Lamp pulse warn (dim, critical)
const DemoLampPulseWarn = () => (
  <div className="oa-anim-lamp-pulse-warn" style={{
    padding: "6px 8px",
    background: "rgba(212,74,58,0.14)",
    border: "2.5px solid var(--c-danger)",
    color: "var(--c-danger)",
    display: "flex", alignItems: "center", justifyContent: "center",
  }}>
    <Icon name="lamp_dim" size={22} color="var(--c-danger)" />
  </div>
);

// 4 · Magic reveal
const DemoMagicReveal = () => (
  <div className="oa-anim-magic-reveal" style={{
    padding: "6px 10px",
    background: "rgba(152,112,196,0.16)",
    border: "2px solid var(--c-magic)",
    color: "var(--c-magic)",
    fontFamily: "var(--f-display)", fontSize: 16, fontWeight: 700,
    letterSpacing: "0.16em",
  }}>XYZZY</div>
);

// 5 · Magic pulse
const DemoMagicPulse = () => (
  <div className="oa-anim-magic-pulse" style={{
    padding: "6px 8px",
    background: "rgba(152,112,196,0.18)",
    border: "2.5px solid var(--c-magic)",
    display: "flex", alignItems: "center", justifyContent: "center",
  }}>
    <Icon name="magic" size={22} color="var(--c-magic)" />
  </div>
);

// 6 · Death tilt
const DemoDeathTilt = () => (
  <div style={{ position: "relative", width: 60, height: 60 }}>
    <div className="oa-anim-death-tilt" style={{
      position: "absolute", inset: 0,
      border: "2px solid var(--c-paper-ink)",
      background: "rgba(13,29,45,0.6)",
      display: "flex", alignItems: "center", justifyContent: "center",
      transformOrigin: "50% 80%",
    }}>
      <Icon name="lamp_off" size={28} color="var(--c-paper-ink)" />
    </div>
    <div className="oa-anim-death-slash" style={{
      position: "absolute", left: 0, top: "50%",
      width: 64, height: 3,
      background: "var(--c-danger)",
      transformOrigin: "0 50%",
      boxShadow: "0 0 6px var(--c-danger)",
    }} />
  </div>
);

// 7 · Flash slide
const DemoFlashSlide = () => (
  <div className="oa-anim-flash-slide" style={{
    padding: "5px 8px",
    background: "rgba(240,160,64,0.10)",
    border: "2px solid var(--c-amber)",
    color: "var(--c-amber)",
    fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.08em",
    textTransform: "uppercase",
    display: "flex", alignItems: "center", gap: 4,
    boxShadow: "3px 3px 0 0 var(--c-ink-void)",
  }}>
    <Icon name="coin" size={10} color="var(--c-amber)" />
    Trésor +12
  </div>
);

// 8 · Sheet slide up
const DemoSheetSlide = () => (
  <div style={{ position: "relative", width: 90, height: 80, border: "1px dashed var(--c-ink-line)", overflow: "hidden" }}>
    <div className="oa-anim-sheet-slide" style={{
      position: "absolute", left: 0, right: 0, bottom: 0, height: "60%",
      background: "var(--c-ink-deep)",
      borderTop: "2.5px solid var(--c-amber)",
      padding: "8px 6px",
    }}>
      <div style={{ width: 24, height: 2, background: "var(--c-paper-ink)", margin: "0 auto 4px" }} />
      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 8, letterSpacing: "0.08em",
        color: "var(--c-paper-warm)", textAlign: "center",
      }}>Action</div>
    </div>
  </div>
);

// 9 · Sparkle (treasure discovery)
const DemoSparkle = () => (
  <div style={{ position: "relative", width: 60, height: 60 }}>
    <div style={{
      position: "absolute", inset: 6,
      border: "2px solid var(--c-treasure)",
      background: "rgba(212,168,74,0.18)",
      display: "flex", alignItems: "center", justifyContent: "center",
    }}>
      <Icon name="coin" size={22} color="var(--c-treasure)" />
    </div>
    {[
      { l: 0,  t: -4, d: "0s" },
      { l: 54, t: 8,  d: "0.5s" },
      { l: 6,  t: 50, d: "1.0s" },
    ].map((s, i) => (
      <div key={i} className="oa-anim-sparkle" style={{
        position: "absolute",
        left: s.l, top: s.t,
        width: 8, height: 8,
        animationDelay: s.d,
        background: "var(--c-treasure)",
        clipPath: "polygon(50% 0, 60% 40%, 100% 50%, 60% 60%, 50% 100%, 40% 60%, 0 50%, 40% 40%)",
      }} />
    ))}
  </div>
);

// 10 · Score pop
const DemoScorePop = () => (
  <div style={{ position: "relative", height: 50, width: 60, display: "flex", alignItems: "flex-end", justifyContent: "center" }}>
    <div style={{
      fontFamily: "var(--f-display)", fontSize: 16, fontWeight: 700,
      color: "var(--c-treasure)", letterSpacing: "0.02em",
    }}>023</div>
    <div className="oa-anim-score-pop" style={{
      position: "absolute", left: "50%", bottom: 22,
      transform: "translateX(-50%)",
      fontFamily: "var(--f-display)", fontSize: 13, fontWeight: 700,
      color: "var(--c-amber)",
      textShadow: "1px 1px 0 var(--c-ink-void)",
    }}>+12</div>
  </div>
);

// 11 · Tap halo
const DemoTapHalo = () => (
  <div style={{ position: "relative", width: 60, height: 60 }}>
    <div style={{
      position: "absolute", inset: 14,
      background: "var(--c-amber)",
      border: "2px solid var(--c-amber-shadow)",
    }} />
    <div className="oa-anim-tap-halo" style={{
      position: "absolute", left: "50%", top: "50%",
      width: 24, height: 24,
      transform: "translate(-50%,-50%)",
      border: "2px solid var(--c-amber)",
      borderRadius: "50%",
    }} />
  </div>
);

// 12 · Dot blink (turn indicator)
const DemoDotBlink = () => (
  <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
    <div className="oa-anim-dot-blink" style={{
      width: 8, height: 8, background: "var(--c-amber)",
    }} />
    <span style={{
      fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em",
      color: "var(--c-amber)",
    }}>T.189</span>
  </div>
);


// ───────────────────────────────────────────────────────────
// MOTION SECTION (slot into DS at the end)
// ───────────────────────────────────────────────────────────
const MotionSection = () => (
  <Card title="MOTION · MICRO-INTERACTIONS" eyebrow="08 — Animation">
    <p style={{ color: "var(--c-paper-faded)", fontSize: 13, lineHeight: 1.5, maxWidth: 820, margin: "0 0 24px" }}>
      Toutes les animations utilisent un easing <strong style={{ color: "var(--c-amber)" }}>en marches (steps)</strong> pour préserver le ressenti 16-bit. Pas de cubic-bezier fluide, pas de spring physics : la perception doit être <em>chunky</em>, comme un sprite qui change de frame. Durées courtes (1–3 s), iterations <em>infinite</em> en démo, déclenchement <em>once</em> en runtime. <code style={{ color: "var(--c-amber)" }}>prefers-reduced-motion</code> est respecté (animations désactivées).
    </p>

    <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
      <MotionCard num="01" name="stamp-press"     useCase="Feedback tactile sur tap d'un bouton — le tampon s'enfonce de 3px, l'ombre disparaît, rebond."         duration="2.4s loop · 240ms en runtime" easing="steps(8, end)"  demo={<DemoStampPress />} />
      <MotionCard num="02" name="lamp-flicker"    useCase="Lanterne allumée idle — vibration douce du halo ambre pour donner vie à la flamme."                  duration="1.8s loop infini" easing="steps(3, end)"  demo={<DemoLampFlicker />} />
      <MotionCard num="03" name="lamp-pulse-warn" useCase="Lanterne faible — halo rouge pulsé pour signaler l'urgence (≤ 30 tours restants)."                   duration="1.4s loop infini" easing="steps(8, end)"  demo={<DemoLampPulseWarn />} />
      <MotionCard num="04" name="magic-reveal"    useCase="Surface d'incantation qui apparaît lorsqu'un mot magique devient utilisable dans le lieu courant."  duration="2.6s loop · 520ms en runtime" easing="steps(6, end)"  demo={<DemoMagicReveal />} />
      <MotionCard num="05" name="magic-pulse"     useCase="Onde violette discrète sur l'incantation pour la signaler comme contextuelle et précieuse."         duration="2.0s loop infini" easing="ease-out"       demo={<DemoMagicPulse />} />
      <MotionCard num="06" name="death-tilt"      useCase="Lanterne qui tombe sur l'écran de mort — rotation à −22° avec rebond, slash rouge apparaît."         duration="3.2s en runtime · loop en démo" easing="steps(8, end)"  demo={<DemoDeathTilt />} />
      <MotionCard num="07" name="flash-slide"     useCase="Bandeau flash en haut de liste d'actions — slide-in du dessus avec ombre qui se pose."                 duration="2.8s loop · 320ms en runtime" easing="steps(8, end)"  demo={<DemoFlashSlide />} />
      <MotionCard num="08" name="sheet-slide-up"  useCase="ItemActionSheet et autres bottom sheets — glissent du bas en steps chunky."                            duration="2.4s loop · 280ms en runtime" easing="steps(8, end)"  demo={<DemoSheetSlide />} />
      <MotionCard num="09" name="sparkle"         useCase="Trésor découvert — 3 éclats étoilés autour du sprite (delays décalés à 0/0.5/1.0s)."                  duration="1.6s loop infini" easing="steps(8, end)"  demo={<DemoSparkle />} />
      <MotionCard num="10" name="score-pop"       useCase="+N points qui flotte au-dessus du score pill puis fade. Aussi pour pénalités (rouge)."                 duration="2.0s en runtime"  easing="steps(8, end)"  demo={<DemoScorePop />} />
      <MotionCard num="11" name="tap-halo"        useCase="Onde concentrique sur tap — feedback complémentaire de stamp-press pour les actions importantes."     duration="1.4s loop · single en runtime" easing="steps(6, end)"  demo={<DemoTapHalo />} />
      <MotionCard num="12" name="dot-blink"       useCase="Petit indicateur de tour actif en tête de Journal — blinkote calmement pour situer le présent."        duration="1.0s loop infini" easing="steps(2, end)"  demo={<DemoDotBlink />} />
    </div>
  </Card>
);

Object.assign(window, { MotionSection, MotionCard });
