/* eslint-disable */
// endgame.jsx — Score breakdown screen.
// Canonical Adventure scores up to 430 pts. Treasure tally · category rows ·
// rank achievement · CTAs to restart / journal / credits.

// ───────────────────────────────────────────────────────────
// Score row — one line of the breakdown table
// ───────────────────────────────────────────────────────────
const ScoreRow = ({ icon, label, sub, count, value, tone = "positive" }) => {
  const tones = {
    positive: { fg: "var(--c-paper-bright)", sign: "+", valueColor: "var(--c-amber)" },
    treasure: { fg: "var(--c-treasure)",     sign: "+", valueColor: "var(--c-treasure)" },
    negative: { fg: "var(--c-danger)",       sign: "−", valueColor: "var(--c-danger)" },
    neutral:  { fg: "var(--c-paper-warm)",   sign: "+", valueColor: "var(--c-paper-warm)" },
  };
  const t = tones[tone] || tones.positive;
  return (
    <div style={{
      display: "flex",
      alignItems: "center",
      gap: 12,
      padding: "10px 12px",
      borderBottom: "1px dashed var(--c-ink-line)",
    }}>
      {icon && (
        <div style={{
          width: 24, height: 24, flexShrink: 0,
          border: `1.5px solid ${t.valueColor}`,
          background: "rgba(13,29,45,0.6)",
          display: "flex", alignItems: "center", justifyContent: "center",
        }}>
          <Icon name={icon} size={12} color={t.valueColor} />
        </div>
      )}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          fontFamily: "var(--f-display)", fontSize: 14, fontWeight: 600,
          color: t.fg, lineHeight: 1, letterSpacing: "0.01em",
        }}>{label}</div>
        {sub && (
          <div style={{
            fontFamily: "var(--f-mono)", fontSize: 10,
            color: "var(--c-paper-faded)",
            marginTop: 3, letterSpacing: "0.04em",
          }}>{sub}</div>
        )}
      </div>
      {count != null && (
        <div style={{
          fontFamily: "var(--f-mono)", fontSize: 11,
          color: "var(--c-paper-ink)", marginRight: 6,
        }}>{count}</div>
      )}
      <div style={{
        fontFamily: "var(--f-display)", fontSize: 17, fontWeight: 700,
        color: t.valueColor, letterSpacing: "0.01em",
        minWidth: 50, textAlign: "right",
      }}>{t.sign}{Math.abs(value)}</div>
    </div>
  );
};


// ───────────────────────────────────────────────────────────
// Treasure tally — pixel sprites in a row, gold = collected, faded = missed
// ───────────────────────────────────────────────────────────
const TREASURES = [
  { icon: "coin",  name: "Nugget",   got: true },
  { icon: "gem",   name: "Diamants", got: true },
  { icon: "gem",   name: "Argent",   got: true },
  { icon: "gem",   name: "Bijoux",   got: true },
  { icon: "coin",  name: "Pièces",   got: true },
  { icon: "gem",   name: "Émeraude", got: true },
  { icon: "gem",   name: "Pyramide", got: true },
  { icon: "gem",   name: "Perle",    got: false },
  { icon: "gem",   name: "Vase",     got: false },
  { icon: "gem",   name: "Rubis",    got: false },
  { icon: "star",  name: "Tapis",    got: false },
  { icon: "star",  name: "Trident",  got: false },
  { icon: "gem",   name: "Œufs d'or", got: false },
  { icon: "key",   name: "Chaîne",   got: false },
  { icon: "gem",   name: "Coffre",   got: false },
];

const TreasureTally = ({ treasures = TREASURES }) => {
  const got = treasures.filter(t => t.got).length;
  return (
    <div style={{
      padding: "12px 14px",
      border: "1px solid var(--c-ink-line)",
      background: "rgba(13,29,45,0.5)",
      margin: "0 14px 14px",
    }}>
      <div style={{
        display: "flex", alignItems: "center", justifyContent: "space-between",
        marginBottom: 10,
      }}>
        <span style={{
          fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em",
          color: "var(--c-treasure)",
        }}>◆ TRÉSORS</span>
        <span style={{
          fontFamily: "var(--f-mono)", fontSize: 11,
          color: "var(--c-paper-faded)", letterSpacing: "0.04em",
        }}>{got} / {treasures.length}</span>
      </div>
      <div style={{
        display: "grid",
        gridTemplateColumns: "repeat(8, 1fr)",
        gap: 4,
      }}>
        {treasures.map((t, i) => (
          <div key={i} style={{
            aspectRatio: "1 / 1",
            border: t.got ? "1.5px solid var(--c-treasure)" : "1.5px dashed var(--c-paper-ink)",
            background: t.got ? "rgba(212,168,74,0.18)" : "rgba(13,29,45,0.5)",
            display: "flex", alignItems: "center", justifyContent: "center",
          }}>
            <Icon name={t.icon} size={14} color={t.got ? "var(--c-treasure)" : "var(--c-paper-ink)"} />
          </div>
        ))}
      </div>
    </div>
  );
};


// ───────────────────────────────────────────────────────────
// Rank stamp — diegetic "stamp" awarded
// ───────────────────────────────────────────────────────────
const RankStamp = ({ rank = "MAÎTRE JUNIOR", subtitle = "Tu as su lire la grotte" }) => (
  <div style={{
    position: "relative",
    margin: "0 14px 14px",
    padding: "16px 14px 14px",
    border: "3px double var(--c-amber)",
    background: "rgba(240,160,64,0.06)",
    textAlign: "center",
    boxShadow: "4px 4px 0 0 var(--c-amber-shadow)",
  }}>
    <CornerBrackets color="var(--c-amber)" size={10} thickness={2} inset={4} />
    <div style={{
      fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.28em",
      color: "var(--c-amber)", marginBottom: 6,
    }}>◇ RANG DÉCERNÉ ◇</div>
    <div style={{
      fontFamily: "var(--f-display)", fontSize: 26, fontWeight: 700,
      color: "var(--c-paper-bright)", letterSpacing: "0.02em", lineHeight: 1,
      textShadow: "2px 2px 0 var(--c-amber-shadow)",
    }}>{rank}</div>
    <div style={{
      fontFamily: "var(--f-body)", fontStyle: "italic", fontSize: 11,
      color: "var(--c-paper-faded)", marginTop: 8,
    }}>« {subtitle} »</div>
  </div>
);


// ───────────────────────────────────────────────────────────
// END GAME PAGE
// ───────────────────────────────────────────────────────────
const EndGamePage = () => {
  const total = 287;
  const max = 430;
  return (
    <PhoneShell>
      <FakeStatusBar tint="var(--c-paper-faded)" />

      {/* Body scroll */}
      <div style={{
        flex: 1,
        overflow: "auto",
        background: "var(--c-ink-void)",
      }}>
        {/* Hero */}
        <div style={{
          padding: "20px 16px 14px",
          textAlign: "center",
          position: "relative",
          background: "radial-gradient(ellipse at top, rgba(240,160,64,0.16) 0%, transparent 70%)",
        }}>
          <div style={{
            fontFamily: "var(--f-caps)", fontSize: 11, letterSpacing: "0.32em",
            color: "var(--c-amber)", marginBottom: 12,
          }}>◆ FIN DE L'AVENTURE ◆</div>
          <div style={{
            fontFamily: "var(--f-display)", fontSize: 60, fontWeight: 700,
            color: "var(--c-paper-bright)", lineHeight: 1,
            textShadow: "3px 3px 0 var(--c-amber-shadow)",
            letterSpacing: "0.02em",
          }}>{total}</div>
          <div style={{
            fontFamily: "var(--f-mono)", fontSize: 12,
            color: "var(--c-paper-faded)", marginTop: 6,
            letterSpacing: "0.08em",
          }}>SUR {max} POINTS</div>

          {/* Progress bar */}
          <div style={{
            marginTop: 14,
            height: 10,
            background: "rgba(122,106,78,0.18)",
            border: "1.5px solid var(--c-paper-ink)",
            position: "relative",
          }}>
            <div style={{
              position: "absolute", left: 0, top: 0, bottom: 0,
              width: `${(total/max)*100}%`,
              background: "linear-gradient(90deg, var(--c-amber-deep) 0%, var(--c-amber) 50%, var(--c-amber-glow) 100%)",
              boxShadow: "inset 0 1px 0 rgba(255,240,200,0.4)",
            }} />
            {/* milestone ticks */}
            {[100, 220, 330].map(m => (
              <div key={m} style={{
                position: "absolute", top: -3, bottom: -3,
                left: `${(m/max)*100}%`,
                width: 1,
                background: "var(--c-paper-ink)",
              }} />
            ))}
          </div>
          <div style={{
            marginTop: 4,
            display: "flex", justifyContent: "space-between",
            fontFamily: "var(--f-mono)", fontSize: 8,
            color: "var(--c-paper-ink)",
            letterSpacing: "0.04em",
          }}>
            <span>NOVICE</span>
            <span>SEASONED</span>
            <span>MASTER</span>
            <span>GRANDMASTER</span>
          </div>
        </div>

        <PixelDivider style={{ margin: "8px 24px 6px" }} />

        <RankStamp rank="MAÎTRE JUNIOR" subtitle="Tu as su lire la grotte sans t'y perdre." />

        <TreasureTally />

        {/* Breakdown */}
        <div style={{
          fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em",
          color: "var(--c-paper-faded)", padding: "0 14px 6px",
        }}>BILAN DÉTAILLÉ</div>

        <div style={{ margin: "0 14px 14px", border: "1px solid var(--c-ink-line)", background: "rgba(13,29,45,0.5)" }}>
          <ScoreRow icon="coin"  label="Trésors trouvés"    sub="7 trésors recueillis"      count="×12" value={84}  tone="treasure" />
          <ScoreRow icon="bag"   label="Trésors déposés"    sub="6 ramenés au cottage"      count="×14" value={84}  tone="treasure" />
          <ScoreRow icon="pin"   label="Caverne explorée"   sub="seuil franchi"              value={25}  tone="positive" />
          <ScoreRow icon="magic" label="Mots magiques"      sub="XYZZY · PLUGH appris"      count="×3"  value={15}  tone="positive" />
          <ScoreRow icon="lamp"  label="Survie"             sub="aucune mort"                value={25}  tone="positive" />
          <ScoreRow icon="check" label="Sortie volontaire"  sub="QUIT canon"                 value={4}   tone="positive" />
          <ScoreRow icon="eye"   label="Pénalité indices"   sub="2 hints consultés"          count="×−5" value={-10} tone="negative" />
          <ScoreRow icon="close" label="Pénalité hostile"   sub="1 nain non évité"           value={-5}  tone="negative" />
          <ScoreRow icon="check" label="Bonus rang"         sub="Maître Junior 270+"         value={65}  tone="positive" />
        </div>

        {/* Actions */}
        <div style={{ padding: "0 14px 18px", display: "flex", flexDirection: "column", gap: 9 }}>
          <StampButton icon="plus" label="Nouvelle aventure"  hint="RESTART" tone="primary" />
          <StampButton icon="book" label="Relire le journal"  hint="LOG"     tone="meta" />
          <StampButton icon="eye"  label="Crédits & sources"  hint="ABOUT"   tone="faded" />
        </div>
      </div>
    </PhoneShell>
  );
};

Object.assign(window, { EndGamePage, ScoreRow, TreasureTally, RankStamp, TREASURES });
