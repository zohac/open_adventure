/* eslint-disable */
// death.jsx — DeathPage : canonical obituary message + reincarnation option.
// Adventure canon: -10 pts per reincarnation, max 3 then permadeath.

// ───────────────────────────────────────────────────────────
// Fallen lantern illustration (snuffed-out hero)
// ───────────────────────────────────────────────────────────
const FallenLantern = () => (
  <div style={{
    width: 140, height: 140,
    margin: "0 auto",
    position: "relative",
    display: "flex", alignItems: "center", justifyContent: "center",
  }}>
    {/* faint cracked-glass halo */}
    <div style={{
      position: "absolute", inset: -10,
      background: "radial-gradient(circle, rgba(212,74,58,0.10) 0%, transparent 70%)",
      filter: "blur(1px)",
    }} />
    {/* lantern, tilted */}
    <div style={{
      width: 110, height: 110,
      border: "3px solid var(--c-paper-ink)",
      background: "rgba(13,29,45,0.6)",
      display: "flex", alignItems: "center", justifyContent: "center",
      transform: "rotate(-22deg)",
      boxShadow: "5px 5px 0 0 var(--c-ink-void)",
      position: "relative",
    }}>
      <CornerBrackets color="var(--c-paper-ink)" size={9} thickness={1.5} inset={4} />
      <Icon name="lamp_off" size={64} color="var(--c-paper-ink)" />
    </div>
    {/* ↯ slash mark */}
    <div style={{
      position: "absolute",
      width: 64, height: 4,
      background: "var(--c-danger)",
      transform: "rotate(-30deg)",
      boxShadow: "0 0 8px var(--c-danger)",
      opacity: 0.8,
    }} />
  </div>
);


// ───────────────────────────────────────────────────────────
// DEATH PAGE
// ───────────────────────────────────────────────────────────
const DeathPage = ({
  obituary = "Tu es tombé dans une fosse profonde, te brisant tous les os du corps.",
  cause = "Petit puits — chute",
  turn = 47,
  score = 23,
  penalty = 10,
  incarnationsLeft = 2,
}) => (
  <PhoneShell>
    <FakeStatusBar tint="var(--c-paper-faded)" />

    <div style={{
      flex: 1,
      overflow: "auto",
      background: "linear-gradient(180deg, var(--c-ink-void) 0%, #1a0a0a 60%, var(--c-ink-void) 100%)",
      display: "flex",
      flexDirection: "column",
    }}>
      {/* Hero */}
      <div style={{
        padding: "32px 24px 20px",
        textAlign: "center",
      }}>
        <FallenLantern />

        <div style={{
          fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.32em",
          color: "var(--c-danger)", marginTop: 18, marginBottom: 10,
        }}>◆ FIN PRÉMATURÉE ◆</div>

        <div style={{
          fontFamily: "var(--f-display)", fontSize: 36, fontWeight: 700,
          color: "var(--c-paper-bright)", letterSpacing: "0.02em",
          lineHeight: 1,
          textShadow: "3px 3px 0 #5a1a14",
        }}>TU AS PÉRI</div>
      </div>

      {/* Obituary card */}
      <div style={{
        margin: "0 16px 14px",
        padding: "16px 14px",
        background: "rgba(13,29,45,0.65)",
        border: "2.5px solid var(--c-danger)",
        boxShadow: "4px 4px 0 #3a0d08",
        position: "relative",
      }}>
        <CornerBrackets color="var(--c-danger)" size={10} thickness={2} inset={4} />
        <div style={{
          fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.18em",
          color: "var(--c-danger)", marginBottom: 10, textAlign: "center",
        }}>◇ OBITUAIRE ◇</div>
        <div style={{
          fontFamily: "var(--f-body)", fontSize: 14, fontStyle: "italic",
          color: "var(--c-paper-warm)", lineHeight: 1.5,
          textAlign: "center",
          textWrap: "pretty",
        }}>« {obituary} »</div>
      </div>

      {/* Run summary */}
      <div style={{
        margin: "0 16px 14px",
        padding: "10px 14px",
        background: "rgba(13,29,45,0.4)",
        border: "1px dashed var(--c-ink-line)",
        display: "grid",
        gridTemplateColumns: "1fr 1fr 1fr",
        gap: 8,
        textAlign: "center",
      }}>
        <div>
          <div style={{
            fontFamily: "var(--f-caps)", fontSize: 8, letterSpacing: "0.12em",
            color: "var(--c-paper-ink)",
          }}>TOUR</div>
          <div style={{
            fontFamily: "var(--f-display)", fontSize: 22, fontWeight: 700,
            color: "var(--c-paper-bright)", letterSpacing: "0.02em",
            lineHeight: 1, marginTop: 2,
          }}>{String(turn).padStart(3, "0")}</div>
        </div>
        <div>
          <div style={{
            fontFamily: "var(--f-caps)", fontSize: 8, letterSpacing: "0.12em",
            color: "var(--c-paper-ink)",
          }}>SCORE</div>
          <div style={{
            fontFamily: "var(--f-display)", fontSize: 22, fontWeight: 700,
            color: "var(--c-treasure)", letterSpacing: "0.02em",
            lineHeight: 1, marginTop: 2,
          }}>{String(score).padStart(3, "0")}</div>
        </div>
        <div>
          <div style={{
            fontFamily: "var(--f-caps)", fontSize: 8, letterSpacing: "0.12em",
            color: "var(--c-paper-ink)",
          }}>CAUSE</div>
          <div style={{
            fontFamily: "var(--f-body)", fontSize: 10,
            color: "var(--c-paper-warm)",
            lineHeight: 1.2, marginTop: 6,
            fontStyle: "italic",
          }}>{cause}</div>
        </div>
      </div>

      {/* Reincarnation section */}
      <div style={{
        padding: "12px 16px 0",
      }}>
        <div style={{
          fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.18em",
          color: "var(--c-amber)", marginBottom: 4,
          display: "flex", alignItems: "center", gap: 6,
        }}>
          <Icon name="magic" size={11} color="var(--c-amber)" />
          RÉINCARNATION POSSIBLE
        </div>
        <div style={{
          fontFamily: "var(--f-body)", fontSize: 12, lineHeight: 1.45,
          color: "var(--c-paper-faded)", marginBottom: 12,
          fontStyle: "italic",
        }}>
          Une magie ancienne peut te ramener à la surface. Le prix : <strong style={{ color: "var(--c-danger)" }}>−{penalty} points</strong> et un peu de ta vigueur.
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 9 }}>
          <StampButton
            icon="magic"
            label="Réincarne-toi"
            hint={`−${penalty} pts`}
            tone="primary"
          />
          <StampButton
            icon="book"
            label="Charger la dernière sauvegarde"
            hint="t.045"
            tone="meta"
          />
          <StampButton
            icon="close"
            label="Accepter cette fin"
            hint="QUIT"
            tone="faded"
          />
        </div>
      </div>

      {/* Footer reincarnation counter */}
      <div style={{
        marginTop: "auto",
        padding: "14px 16px 14px",
        textAlign: "center",
        fontFamily: "var(--f-mono)", fontSize: 10,
        color: "var(--c-paper-ink)",
        letterSpacing: "0.06em",
        borderTop: "1px dashed var(--c-ink-hairline)",
      }}>
        {incarnationsLeft > 0
          ? `${incarnationsLeft} incarnation${incarnationsLeft > 1 ? "s" : ""} restante${incarnationsLeft > 1 ? "s" : ""}`
          : "Plus aucune incarnation — la mort est définitive."}
      </div>
    </div>
  </PhoneShell>
);

// Variant: final death (no reincarnation left)
const DeathPageFinal = () => (
  <DeathPage
    obituary="Tu disturbes les nains, qui ne tolèrent pas plus longtemps ta présence dans leur grotte. Ils convergent sur toi en silence — et tout devient noir."
    cause="Souterrain — nains"
    turn={284}
    score={142}
    penalty={10}
    incarnationsLeft={0}
  />
);

Object.assign(window, { DeathPage, DeathPageFinal, FallenLantern });
