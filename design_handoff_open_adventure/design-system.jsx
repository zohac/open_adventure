/* eslint-disable */
// design-system.jsx — visual spec sheet for Open Adventure.
// One large artboard (1200×~1800) split into sections:
//  1. Cover / philosophy
//  2. Color tokens (ink, teal, paper, amber, semantic)
//  3. Typography pairing
//  4. Spacing / radii / borders
//  5. Iconography (pixel set)
//  6. Components (pills, buttons, scene placeholder)

const DS_W = 1200;

// helper card
const Card = ({ title, eyebrow, children, style = {} }) => (
  <section style={{
    background: "var(--c-ink-deep)",
    border: "2px solid var(--c-ink-line)",
    padding: 24,
    position: "relative",
    ...style,
  }}>
    <CornerBrackets color="var(--c-amber)" size={10} thickness={2} inset={6} />
    {eyebrow && (
      <div style={{
        fontFamily: "var(--f-caps)",
        fontSize: 11,
        letterSpacing: "0.16em",
        color: "var(--c-amber)",
        marginBottom: 6,
      }}>◆ {eyebrow}</div>
    )}
    {title && (
      <h3 style={{
        margin: 0,
        fontFamily: "var(--f-display)",
        fontSize: 22,
        fontWeight: 700,
        color: "var(--c-paper-bright)",
        letterSpacing: "0.01em",
        marginBottom: 18,
      }}>{title}</h3>
    )}
    {children}
  </section>
);


// Swatch component
const Swatch = ({ name, token, value, fg = "var(--c-paper-bright)", note }) => (
  <div style={{ display: "flex", flexDirection: "column" }}>
    <div style={{
      width: "100%",
      height: 76,
      background: value,
      border: "1px solid var(--c-ink-line)",
      position: "relative",
    }}>
      {fg && (
        <div style={{
          position: "absolute", left: 8, top: 8,
          fontFamily: "var(--f-caps)",
          fontSize: 9,
          letterSpacing: "0.08em",
          color: fg,
          opacity: 0.7,
        }}>{name}</div>
      )}
    </div>
    <div style={{ padding: "8px 2px 0", fontFamily: "var(--f-mono)", fontSize: 10 }}>
      <div style={{ color: "var(--c-paper-warm)" }}>{token}</div>
      <div style={{ color: "var(--c-paper-ink)", marginTop: 2 }}>{value}</div>
      {note && <div style={{ color: "var(--c-teal-mist)", marginTop: 4, fontFamily: "var(--f-body)", fontSize: 11 }}>{note}</div>}
    </div>
  </div>
);

const SwatchRow = ({ label, swatches }) => (
  <div style={{ marginBottom: 24 }}>
    <div style={{
      fontFamily: "var(--f-caps)",
      fontSize: 10,
      letterSpacing: "0.14em",
      color: "var(--c-paper-faded)",
      marginBottom: 10,
    }}>{label}</div>
    <div style={{
      display: "grid",
      gridTemplateColumns: `repeat(${swatches.length}, 1fr)`,
      gap: 10,
    }}>
      {swatches.map(s => <Swatch key={s.token} {...s} />)}
    </div>
  </div>
);


// ───────────────────────────────────────────────────────────
const ColorSection = () => (
  <Card title="COLOR · SYSTÈME ENCRE & LANTERNE" eyebrow="01 — Palette">
    <p style={{
      color: "var(--c-paper-faded)",
      fontSize: 13,
      lineHeight: 1.5,
      maxWidth: 740,
      marginTop: 0,
      marginBottom: 22,
    }}>
      Palette pulpe rétro. <strong style={{ color: "var(--c-paper-bright)" }}>Encres profondes</strong> pour les fonds (la grotte), <strong style={{ color: "var(--c-teal-mist)" }}>brumes turquoise</strong> pour le secondaire / la profondeur, <strong style={{ color: "var(--c-paper-warm)" }}>papier crème</strong> pour le texte (vélin vieilli), <strong style={{ color: "var(--c-amber)" }}>ambre lanterne</strong> pour les actions et la lumière. Dark mode uniquement — l'aventure se joue à la lampe.
    </p>

    <SwatchRow label="ENCRE · backgrounds" swatches={[
      { name: "VOID",     token: "--c-ink-void",     value: "#06101a", note: "Fond système" },
      { name: "DEEP",     token: "--c-ink-deep",     value: "#0d1d2d", note: "BG primaire" },
      { name: "MID",      token: "--c-ink-mid",      value: "#16304a", note: "Panneaux" },
      { name: "RAISED",   token: "--c-ink-raised",   value: "#1f4267", note: "Hover, élevé" },
      { name: "LINE",     token: "--c-ink-line",     value: "#2a5478", note: "Bordures" },
      { name: "HAIR",     token: "--c-ink-hairline", value: "#1a3a5a", note: "Dividers" },
    ]} />

    <SwatchRow label="BRUME · cool secondary" swatches={[
      { name: "MIST",  token: "--c-teal-mist",  value: "#5a8fa8", fg: "#06101a", note: "Texte secondaire" },
      { name: "DEEP",  token: "--c-teal-deep",  value: "#2a4d6e", note: "Surface fond" },
      { name: "GLOW",  token: "--c-teal-glow",  value: "#4ec5b8", fg: "#06101a", note: "Interactif cool" },
    ]} />

    <SwatchRow label="PAPIER · texte" swatches={[
      { name: "BRIGHT", token: "--c-paper-bright", value: "#faf2dd", fg: "#06101a", note: "Titres" },
      { name: "WARM",   token: "--c-paper-warm",   value: "#f0e4cc", fg: "#06101a", note: "Corps texte" },
      { name: "FADED",  token: "--c-paper-faded",  value: "#c8b896", fg: "#06101a", note: "Captions" },
      { name: "INK",    token: "--c-paper-ink",    value: "#7a6a4e", note: "Watermark" },
    ]} />

    <SwatchRow label="AMBRE · signature lanterne" swatches={[
      { name: "GLOW",   token: "--c-amber-glow",   value: "#ffc070", fg: "#06101a", note: "Highlight" },
      { name: "AMBER",  token: "--c-amber",        value: "#f0a040", fg: "#06101a", note: "Accent principal" },
      { name: "DEEP",   token: "--c-amber-deep",   value: "#c97432", note: "Pressé" },
      { name: "SHADOW", token: "--c-amber-shadow", value: "#8a4a1a", note: "Ombre" },
    ]} />

    <SwatchRow label="SÉMANTIQUE · états" swatches={[
      { name: "TREASURE", token: "--c-treasure", value: "#d4a84a", fg: "#06101a", note: "Or, trésors" },
      { name: "DANGER",   token: "--c-danger",   value: "#d44a3a", fg: "#06101a", note: "Hostile, lampe critique" },
      { name: "SUCCESS",  token: "--c-success",  value: "#6ea34a", fg: "#06101a", note: "Découverte" },
      { name: "MAGIC",    token: "--c-magic",    value: "#9870c4", fg: "#06101a", note: "Incantations" },
    ]} />
  </Card>
);


// ───────────────────────────────────────────────────────────
const TypeSection = () => (
  <Card title="TYPE · PIXEL DISPLAY + SANS HUMANISTE" eyebrow="02 — Typographie">
    <p style={{ color: "var(--c-paper-faded)", fontSize: 13, lineHeight: 1.5, maxWidth: 740, margin: "0 0 20px" }}>
      Hybride : chrome UI en <strong style={{ color: "var(--c-amber)" }}>Pixelify Sans</strong> (chunky 16-bit lisible) et <strong style={{ color: "var(--c-amber)" }}>Silkscreen</strong> (caps), tandis que les descriptions de jeu et menus longs passent en <strong style={{ color: "var(--c-amber)" }}>DM Sans</strong> pour préserver la lecture confortable de l'aventure textuelle.
    </p>

    <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 24 }}>
      {/* Display */}
      <div style={{ borderLeft: "3px solid var(--c-amber)", paddingLeft: 16 }}>
        <div style={{ fontFamily: "var(--f-mono)", fontSize: 10, color: "var(--c-paper-ink)", letterSpacing: "0.1em" }}>DISPLAY · Pixelify Sans</div>
        <div style={{ fontFamily: "var(--f-display)", fontSize: 40, lineHeight: 1.05, color: "var(--c-paper-bright)", marginTop: 6 }}>HALL DES BRUMES</div>
        <div style={{ fontFamily: "var(--f-display)", fontSize: 28, lineHeight: 1.1, color: "var(--c-paper-bright)", marginTop: 12 }}>Aller au Nord</div>
        <div style={{ fontFamily: "var(--f-display)", fontSize: 22, lineHeight: 1.15, color: "var(--c-paper-warm)", marginTop: 12 }}>Sous-titre 22px</div>
        <div style={{ fontFamily: "var(--f-display)", fontSize: 18, lineHeight: 1.2, color: "var(--c-paper-warm)", marginTop: 8 }}>Sous-titre 18px</div>
        <div style={{ marginTop: 16, fontFamily: "var(--f-mono)", fontSize: 10, color: "var(--c-paper-ink)" }}>
          xl 40 / l 28 / m 22 / s 18 — weight 600/700
        </div>
      </div>

      {/* Caps */}
      <div style={{ borderLeft: "3px solid var(--c-teal-glow)", paddingLeft: 16 }}>
        <div style={{ fontFamily: "var(--f-mono)", fontSize: 10, color: "var(--c-paper-ink)", letterSpacing: "0.1em" }}>CAPS · Silkscreen</div>
        <div style={{ fontFamily: "var(--f-caps)", fontSize: 12, letterSpacing: "0.1em", color: "var(--c-amber)", marginTop: 6 }}>◆ INVENTAIRE · 3 OBJETS</div>
        <div style={{ fontFamily: "var(--f-caps)", fontSize: 12, letterSpacing: "0.1em", color: "var(--c-paper-bright)", marginTop: 12 }}>QUE FAIRE ?</div>
        <div style={{ fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em", color: "var(--c-paper-faded)", marginTop: 8 }}>SOUTERRAIN · PROFONDEUR II</div>
        <div style={{ fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em", color: "var(--c-teal-mist)", marginTop: 8 }}>OFFLINE · 5 OPTIONS</div>
        <div style={{ marginTop: 24, fontFamily: "var(--f-mono)", fontSize: 10, color: "var(--c-paper-ink)" }}>
          m 12 / s 10 — letter-spacing 0.08–0.14em
        </div>
      </div>

      {/* Body */}
      <div style={{ borderLeft: "3px solid var(--c-paper-warm)", paddingLeft: 16, gridColumn: "span 2" }}>
        <div style={{ fontFamily: "var(--f-mono)", fontSize: 10, color: "var(--c-paper-ink)", letterSpacing: "0.1em" }}>BODY · DM Sans (humaniste, lisible long-form)</div>
        <p style={{ fontFamily: "var(--f-body)", fontSize: 17, lineHeight: 1.55, color: "var(--c-paper-warm)", marginTop: 6, maxWidth: 880 }}>
          17 px — <em>Description longue.</em> Tu te tiens dans une immense chambre voûtée. Une rivière souterraine murmure quelque part en contrebas. Des brumes pâles s'enroulent autour de tes chevilles.
        </p>
        <p style={{ fontFamily: "var(--f-body)", fontSize: 15, lineHeight: 1.5, color: "var(--c-paper-warm)", marginTop: 0, maxWidth: 880 }}>
          15 px — Body courant. À l'est, au nord, et vers le bas par un escalier en colimaçon taillé à même la roche.
        </p>
        <p style={{ fontFamily: "var(--f-body)", fontSize: 13, lineHeight: 1.45, color: "var(--c-paper-faded)", marginTop: 0 }}>
          13 px — Secondaire / hint. La lanterne diffuse une lumière chaleureuse à environ trois mètres.
        </p>
        <p style={{ fontFamily: "var(--f-mono)", fontSize: 12, color: "var(--c-teal-mist)", marginTop: 12, marginBottom: 0 }}>
          mono — t.047 · obj.lamp · save_v1_slot2.json — JetBrains Mono pour timestamps & chemins
        </p>
      </div>
    </div>
  </Card>
);


// ───────────────────────────────────────────────────────────
const SpacingSection = () => {
  const scale = [
    { name: "s-1", value: 4 },
    { name: "s-2", value: 8 },
    { name: "s-3", value: 12 },
    { name: "s-4", value: 16 },
    { name: "s-5", value: 20 },
    { name: "s-6", value: 24 },
    { name: "s-7", value: 32 },
    { name: "s-8", value: 40 },
    { name: "s-9", value: 48 },
    { name: "s-10", value: 64 },
  ];
  return (
    <Card title="ESPACEMENT · GRILLE 4DP" eyebrow="03 — Spacing & forme">
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 32 }}>
        <div>
          <div style={{ fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em", color: "var(--c-paper-faded)", marginBottom: 10 }}>ÉCHELLE</div>
          <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
            {scale.map(s => (
              <div key={s.name} style={{ display: "flex", alignItems: "center", gap: 12 }}>
                <span style={{
                  fontFamily: "var(--f-mono)", fontSize: 10, color: "var(--c-paper-ink)", width: 40,
                }}>{s.name}</span>
                <div style={{ height: 8, width: s.value, background: "var(--c-amber)" }} />
                <span style={{ fontFamily: "var(--f-mono)", fontSize: 10, color: "var(--c-paper-warm)" }}>{s.value}px</span>
              </div>
            ))}
          </div>
        </div>

        <div>
          <div style={{ fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em", color: "var(--c-paper-faded)", marginBottom: 10 }}>RADII · BORDERS</div>
          <div style={{ display: "flex", gap: 12, marginBottom: 24 }}>
            {[{r:0,n:"r-0"},{r:2,n:"r-1"},{r:4,n:"r-2"},{r:8,n:"r-3"}].map(x => (
              <div key={x.n} style={{ textAlign: "center" }}>
                <div style={{
                  width: 56, height: 56,
                  background: "var(--c-ink-raised)",
                  border: "2px solid var(--c-paper-warm)",
                  borderRadius: x.r,
                }} />
                <div style={{ fontFamily: "var(--f-mono)", fontSize: 10, color: "var(--c-paper-faded)", marginTop: 6 }}>{x.n}<br/>{x.r}px</div>
              </div>
            ))}
          </div>

          <div style={{ fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em", color: "var(--c-paper-faded)", marginBottom: 10 }}>OMBRES PIXEL</div>
          <div style={{ display: "flex", gap: 24, alignItems: "flex-end", marginBottom: 24 }}>
            {[
              { lbl: "block-sm", sh: "var(--sh-block-sm)" },
              { lbl: "block-md", sh: "var(--sh-block-md)" },
              { lbl: "block-lg", sh: "var(--sh-block-lg)" },
              { lbl: "glow",     sh: "var(--sh-amber-glow)" },
            ].map(x => (
              <div key={x.lbl} style={{ textAlign: "center" }}>
                <div style={{
                  width: 56, height: 56,
                  background: "var(--c-amber)",
                  boxShadow: x.sh,
                }} />
                <div style={{ fontFamily: "var(--f-mono)", fontSize: 10, color: "var(--c-paper-faded)", marginTop: 10 }}>{x.lbl}</div>
              </div>
            ))}
          </div>

          <div style={{ fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em", color: "var(--c-paper-faded)", marginBottom: 10 }}>CIBLES TACTILES</div>
          <div style={{ display: "flex", gap: 10, alignItems: "flex-end" }}>
            {[{h:44, l:"min 44"}, {h:48, l:"comfy 48"}, {h:56, l:"large 56"}].map(x => (
              <div key={x.l}>
                <div style={{ width: 120, height: x.h, background: "var(--c-ink-mid)", border: "2px solid var(--c-amber)", display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "var(--f-caps)", fontSize: 10, color: "var(--c-amber)" }}>{x.l}</div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </Card>
  );
};


// ───────────────────────────────────────────────────────────
const IconSection = () => {
  const groups = [
    { title: "NAVIGATION", names: ["north","south","east","west","up","down","back"] },
    { title: "OBJETS · INTERACTION", names: ["take","drop","lamp","key","bag","eye"] },
    { title: "MÉTA & STATUS", names: ["map","book","menu","gear","pin","coin","heart","plus","check","close"] },
  ];
  return (
    <Card title="ICONOGRAPHIE · PIXEL 16×16" eyebrow="04 — Pictogrammes">
      <p style={{ color: "var(--c-paper-faded)", fontSize: 13, lineHeight: 1.5, maxWidth: 740, margin: "0 0 20px" }}>
        Pictogrammes pixel-art tracés sur grille 16×16. Rendu <code style={{ color: "var(--c-amber)" }}>shape-rendering: crispEdges</code>, <code style={{ color: "var(--c-amber)" }}>currentColor</code> pour héritage des teintes. Tailles d'usage : 12 / 14 / 16 / 22 px.
      </p>
      {groups.map(g => (
        <div key={g.title} style={{ marginBottom: 20 }}>
          <div style={{ fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em", color: "var(--c-paper-faded)", marginBottom: 10 }}>{g.title}</div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(10, 1fr)", gap: 10 }}>
            {g.names.map(n => (
              <div key={n} style={{
                display: "flex", flexDirection: "column", alignItems: "center", gap: 6,
                padding: 12,
                border: "1px solid var(--c-ink-line)",
                background: "var(--c-ink-mid)",
              }}>
                <Icon name={n} size={24} color="var(--c-paper-bright)" />
                <span style={{ fontFamily: "var(--f-mono)", fontSize: 9, color: "var(--c-paper-faded)" }}>{n}</span>
              </div>
            ))}
          </div>
        </div>
      ))}
    </Card>
  );
};


// ───────────────────────────────────────────────────────────
const SubLabel = ({ children, style = {} }) => (
  <div style={{
    fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.14em",
    color: "var(--c-paper-faded)", marginBottom: 12, ...style,
  }}>{children}</div>
);

const MonoTag = ({ children }) => (
  <div style={{ fontFamily: "var(--f-mono)", fontSize: 10, color: "var(--c-paper-ink)", marginBottom: 6 }}>{children}</div>
);

const ComponentsSection = () => (
  <Card title="COMPOSANTS · GRAMMAIRE TAMPONS" eyebrow="05 — Building blocks">
    <p style={{ color: "var(--c-paper-faded)", fontSize: 13, lineHeight: 1.5, maxWidth: 760, margin: "0 0 24px" }}>
      Un seul langage de bouton, le <strong style={{ color: "var(--c-amber)" }}>Tampon</strong> : bordure 2,5 px, ombre dure offset 3 px (la pression sur le papier), libellé Silkscreen en caps. Deux familles — <strong style={{ color: "var(--c-paper-bright)" }}>outlined</strong> (bord seul, papier visible) et <strong style={{ color: "var(--c-paper-bright)" }}>filled</strong> (encre solide) — déclinées en cinq tons sémantiques.
    </p>

    <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 28, marginBottom: 28 }}>
      <div>
        <SubLabel>TAMPONS OUTLINED · liste d'actions</SubLabel>
        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          <div>
            <MonoTag>tone: default · navigation par défaut</MonoTag>
            <StampButton icon="east" label="Aller à l'est" hint="E" />
          </div>
          <div>
            <MonoTag>tone: meta · observer / inventaire</MonoTag>
            <StampButton icon="eye" label="Observer le lieu" hint="LOOK" tone="meta" />
          </div>
          <div>
            <MonoTag>tone: danger · action risquée (lampe faible)</MonoTag>
            <StampButton icon="north" label="Continuer au nord" hint="N" tone="danger" />
          </div>
          <div>
            <MonoTag>tone: faded · option mineure / atténuée</MonoTag>
            <StampButton icon="up" label="Remonter" hint="UP" tone="faded" />
          </div>
          <div>
            <MonoTag>disabled · option indisponible</MonoTag>
            <StampButton icon="down" label="Descendre" hint="DOWN" disabled />
          </div>
        </div>
      </div>

      <div>
        <SubLabel>TAMPONS FILLED · action principale</SubLabel>
        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          <div>
            <MonoTag>tone: primary · action recommandée</MonoTag>
            <StampButton icon="north" label="Aller au nord" hint="N" tone="primary" />
          </div>
          <div>
            <MonoTag>tone: treasure · ramasser un trésor</MonoTag>
            <StampButton icon="take" label="Prendre la coupe" hint="OBJ" tone="treasure" />
          </div>
          <div>
            <MonoTag>tone: hostile · attaque / mort certaine</MonoTag>
            <StampButton icon="close" label="Attaquer le dragon" hint="!" tone="hostile" />
          </div>
        </div>

        <SubLabel style={{ marginTop: 24 }}>STAMP MENU ITEM · Home / Settings</SubLabel>
        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          <StampMenuItem icon="lamp" title="CONTINUER" sub="HALL DES BRUMES · t.047 · 23 PTS" tone="primary" />
          <StampMenuItem icon="book" title="CHARGER" sub="3 sauvegardes" />
        </div>
      </div>
    </div>

    <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 28 }}>
      <div>
        <SubLabel>PILLS / STATUS</SubLabel>
        <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginBottom: 24 }}>
          <Pill icon="coin" label="SCORE" value="023" tone="treasure" />
          <Pill icon="lamp" label="LAMPE" value="285" tone="amber" />
          <Pill icon="lamp" label="LAMPE" value="029" tone="danger" />
          <Pill label="T" value="047" />
          <Pill icon="key" label="CLEF" tone="teal" />
        </div>

        <SubLabel>DIVIDER ORNEMENTÉ</SubLabel>
        <PixelDivider style={{ margin: "0 0 20px" }} />

        <SubLabel>CORNER BRACKETS · framing</SubLabel>
        <div style={{ position: "relative", width: 240, height: 80, background: "var(--c-ink-raised)" }}>
          <CornerBrackets color="var(--c-amber)" size={12} thickness={2} inset={4} />
          <div style={{ display: "flex", alignItems: "center", justifyContent: "center", height: "100%", fontFamily: "var(--f-display)", color: "var(--c-paper-bright)", fontSize: 13 }}>cadre 240 × 80</div>
        </div>
      </div>

      <div>
        <SubLabel>SCENE PLACEHOLDER · 16:9 + halo lanterne</SubLabel>
        <div style={{ width: "100%", maxWidth: 360, marginBottom: 24 }}>
          <ScenePlaceholder label="hall_of_mists.webp" brief="320×180 · long" />
        </div>

        <SubLabel>BOTTOM NAV · 4 onglets</SubLabel>
        <div style={{ width: "100%", maxWidth: 360, border: "1px solid var(--c-ink-line)" }}>
          <BottomNav active="map" />
        </div>
      </div>
    </div>
  </Card>
);


// ───────────────────────────────────────────────────────────
// COVER · philosophy
// ───────────────────────────────────────────────────────────
const CoverSection = () => (
  <section style={{
    background: "linear-gradient(180deg, var(--c-ink-deep) 0%, var(--c-ink-void) 100%)",
    border: "2px solid var(--c-ink-line)",
    padding: "40px 32px",
    position: "relative",
    overflow: "hidden",
  }}>
    {/* lantern halo bg */}
    <div style={{
      position: "absolute", right: "-10%", top: "-30%",
      width: 600, height: 600,
      background: "radial-gradient(circle, rgba(240,160,64,0.18) 0%, transparent 60%)",
      pointerEvents: "none",
    }} />
    <CornerBrackets color="var(--c-amber)" size={14} thickness={2.5} inset={10} />

    <div style={{
      fontFamily: "var(--f-caps)",
      fontSize: 11,
      letterSpacing: "0.32em",
      color: "var(--c-amber)",
      marginBottom: 16,
    }}>◇ DESIGN SYSTEM · v0.1 ◇ MAI 2026</div>

    <h1 style={{
      margin: 0,
      fontFamily: "var(--f-display)",
      fontSize: 56,
      fontWeight: 700,
      letterSpacing: "0.01em",
      color: "var(--c-paper-bright)",
      textShadow: "4px 4px 0 var(--c-amber-shadow)",
      lineHeight: 1,
    }}>OPEN ADVENTURE</h1>

    <div style={{
      marginTop: 8,
      fontFamily: "var(--f-body)",
      fontSize: 18,
      fontStyle: "italic",
      color: "var(--c-paper-faded)",
      maxWidth: 720,
    }}>
      Carnet d'explorateur sous la lanterne. Pixel-art 16-bit, mobile-first, dark-only, FR/EN, 100% offline.
    </div>

    <div style={{
      marginTop: 32,
      display: "grid",
      gridTemplateColumns: "repeat(3, 1fr)",
      gap: 16,
      maxWidth: 1000,
      position: "relative",
      zIndex: 1,
    }}>
      {[
        { eyebrow: "MOOD", title: "Pulpe rétro", body: "Indiana Jones meets Megadrive : encre profonde, ambre de lanterne, papier vieilli. Le joueur est éclairé par sa propre lampe." },
        { eyebrow: "GRILLE", title: "Pixel 16-bit", body: "Canvas logique 320×180, scaling entier, FilterQuality.none. Chrome UI en pixel, descriptions en sans-serif pour la lisibilité long-form." },
        { eyebrow: "INTERACTION", title: "Sans clavier", body: "3–7 boutons contextuels par tour. Hiérarchie : sécurité → navigation → interactions → méta. 44dp tap-target minimum." },
      ].map(p => (
        <div key={p.title} style={{
          background: "rgba(13,29,45,0.7)",
          border: "1px solid var(--c-ink-line)",
          padding: 16,
          backdropFilter: "blur(4px)",
        }}>
          <div style={{ fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.16em", color: "var(--c-amber)" }}>◆ {p.eyebrow}</div>
          <div style={{ fontFamily: "var(--f-display)", fontSize: 22, fontWeight: 700, color: "var(--c-paper-bright)", marginTop: 8, marginBottom: 8 }}>{p.title}</div>
          <div style={{ fontFamily: "var(--f-body)", fontSize: 13, color: "var(--c-paper-warm)", lineHeight: 1.5 }}>{p.body}</div>
        </div>
      ))}
    </div>
  </section>
);


// ───────────────────────────────────────────────────────────
// FLASH MESSAGES · taxonomy
// ───────────────────────────────────────────────────────────
const FlashSection = () => {
  const FLASHES = [
    { tone: "default",   icon: "lamp",  text: "La lampe est maintenant allumée", note: "défaut · ambre" },
    { tone: "success",   icon: "check", text: "L'oiseau est libéré · +3 pts",     note: "réussite" },
    { tone: "danger",    icon: "lamp",  text: "La lampe faiblit · 29 tours",      note: "danger · alerte" },
    { tone: "info",      icon: "eye",   text: "Tu entends un grattement de pierre", note: "info · son distant" },
    { tone: "discovery", icon: "coin",  text: "Trésor découvert · Coupe d'or",    note: "découverte · trésor" },
    { tone: "magic",     icon: "magic", text: "L'oiseau te chante un mot magique", note: "magie · canon DDR-001" },
  ];
  return (
    <Card title="FLASH MESSAGES · TAXONOMIE" eyebrow="06 — Notifications inline">
      <p style={{ color: "var(--c-paper-faded)", fontSize: 13, lineHeight: 1.5, maxWidth: 800, margin: "0 0 22px" }}>
        Bandeaux d'événement injectés au sommet de la liste d'actions à chaque tour qui produit un message canonique. Tons sémantiques 1:1 avec la palette, ombre pixel pour la cohérence avec les stamps. Affichage temporaire (~3 s), <code style={{ color: "var(--c-amber)" }}>controller.clearFlashMessage()</code> après consommation.
      </p>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
        {FLASHES.map(f => (
          <div key={f.tone}>
            <MonoTag>tone: {f.tone} · {f.note}</MonoTag>
            <FlashMessage tone={f.tone} icon={f.icon} text={f.text} />
          </div>
        ))}
      </div>

      <SubLabel style={{ marginTop: 28 }}>EMPILEMENT · 3 flashs récents</SubLabel>
      <div style={{ display: "flex", flexDirection: "column", gap: 6, maxWidth: 460 }}>
        <FlashMessage tone="success" icon="check" text="Coupe d'or ramassée · +12 pts" />
        <FlashMessage tone="info"    icon="eye"   text="Tu entends un sifflement venimeux" />
        <FlashMessage tone="danger"  icon="lamp"  text="La lampe faiblit · 27 tours" />
      </div>
    </Card>
  );
};
const GameplaySection = () => (
  <Card title="GAMEPLAY UI · LANTERNE · INCANTATION · OBJETS" eyebrow="07 — Couche jeu">
    <p style={{ color: "var(--c-paper-faded)", fontSize: 13, lineHeight: 1.5, maxWidth: 800, margin: "0 0 24px" }}>
      Composants spécifiques au gameplay. La <strong style={{ color: "var(--c-amber)" }}>lanterne</strong> est traitée en objet diegetic permanent (raccourci visible à tout moment), les <strong style={{ color: "var(--c-magic)" }}>incantations</strong> n'apparaissent qu'en contexte valide (DDR-001 Option A), les <strong style={{ color: "var(--c-paper-bright)" }}>objets de l'inventaire</strong> ont un sprite + état + actions contextuelles via bottom sheet.
    </p>

    <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 28, marginBottom: 28 }}>
      <div>
        <SubLabel>LAMP SHORTCUT · 3 états visuels</SubLabel>
        <div style={{ display: "flex", gap: 16, marginBottom: 8 }}>
          <div style={{ textAlign: "center" }}>
            <LampShortcut state="bright" turns={285} />
            <div style={{ fontFamily: "var(--f-mono)", fontSize: 10, color: "var(--c-paper-faded)", marginTop: 10 }}>bright<br/>halo ambre</div>
          </div>
          <div style={{ textAlign: "center" }}>
            <LampShortcut state="dim" turns={29} />
            <div style={{ fontFamily: "var(--f-mono)", fontSize: 10, color: "var(--c-paper-faded)", marginTop: 10 }}>dim<br/>halo rouge</div>
          </div>
          <div style={{ textAlign: "center" }}>
            <LampShortcut state="dark" turns={0} />
            <div style={{ fontFamily: "var(--f-mono)", fontSize: 10, color: "var(--c-paper-faded)", marginTop: 10 }}>dark<br/>off</div>
          </div>
        </div>
        <p style={{ color: "var(--c-paper-faded)", fontSize: 12, lineHeight: 1.5, marginTop: 16 }}>
          Toujours visible sur l'écran Adventure, ancré sur le coin droit de l'image de scène. Tap → bascule l'état + flash message. Le compteur <code style={{ color: "var(--c-amber)" }}>turns</code> reflète <code style={{ color: "var(--c-amber)" }}>limit</code> côté Domain (lecture via <code style={{ color: "var(--c-amber)" }}>_applyLampTimers</code>).
        </p>
      </div>

      <div>
        <SubLabel>MAGIC WORD SURFACE · contextuelle uniquement</SubLabel>
        <MagicWordSurface word="XYZZY" hint="T'envoie au cottage en pierre, peut-être" />
        <div style={{ marginTop: 10 }}>
          <MagicWordSurface word="PLUGH" hint="Te ramène au Y2" />
        </div>
        <p style={{ color: "var(--c-paper-faded)", fontSize: 12, lineHeight: 1.5, marginTop: 16 }}>
          Rendue <strong style={{ color: "var(--c-magic)" }}>uniquement</strong> si <code style={{ color: "var(--c-magic)" }}>Game.magicWordsUnlocked == true</code> ET si le lieu actuel est valide pour <code style={{ color: "var(--c-magic)" }}>word</code>. Position : juste avant la liste d'actions, jamais dans <code>ListAvailableActions</code> proactivement.
        </p>
      </div>
    </div>

    <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 28, marginBottom: 28 }}>
      <div>
        <SubLabel>ITEM SPRITE · 48 × 48 cadré</SubLabel>
        <div style={{ display: "flex", gap: 12, flexWrap: "wrap", marginBottom: 16 }}>
          <div style={{ textAlign: "center" }}>
            <ItemSprite icon="lamp" tone="lit" glow />
            <div style={{ fontFamily: "var(--f-mono)", fontSize: 9, color: "var(--c-paper-faded)", marginTop: 6 }}>lit · glow</div>
          </div>
          <div style={{ textAlign: "center" }}>
            <ItemSprite icon="lamp_off" tone="default" />
            <div style={{ fontFamily: "var(--f-mono)", fontSize: 9, color: "var(--c-paper-faded)", marginTop: 6 }}>default</div>
          </div>
          <div style={{ textAlign: "center" }}>
            <ItemSprite icon="bottle" tone="default" />
            <div style={{ fontFamily: "var(--f-mono)", fontSize: 9, color: "var(--c-paper-faded)", marginTop: 6 }}>bottle</div>
          </div>
          <div style={{ textAlign: "center" }}>
            <ItemSprite icon="gem" tone="treasure" glow />
            <div style={{ fontFamily: "var(--f-mono)", fontSize: 9, color: "var(--c-paper-faded)", marginTop: 6 }}>treasure</div>
          </div>
          <div style={{ textAlign: "center" }}>
            <ItemSprite icon="bird" tone="magic" />
            <div style={{ fontFamily: "var(--f-mono)", fontSize: 9, color: "var(--c-paper-faded)", marginTop: 6 }}>magic</div>
          </div>
          <div style={{ textAlign: "center" }}>
            <ItemSprite icon="rod" tone="danger" />
            <div style={{ fontFamily: "var(--f-mono)", fontSize: 9, color: "var(--c-paper-faded)", marginTop: 6 }}>danger</div>
          </div>
        </div>

        <SubLabel>STAMP TONE · magic (incantation)</SubLabel>
        <StampButton icon="magic" label="Prononcer XYZZY" hint="MOT" tone="magic" />
      </div>

      <div>
        <SubLabel>ITEM CARD · ligne d'inventaire</SubLabel>
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          <ItemCard
            icon="lamp" name="Lanterne en cuivre"
            state="ALLUMÉE · 204 tours"
            hint="Brûle de l'huile. Faisceau d'environ 3 mètres."
            spriteTone="lit" glow
          />
          <ItemCard
            icon="bottle" name="Petite bouteille"
            state="PLEINE · EAU"
            hint="Eau claire et fraîche."
            selected
          />
          <ItemCard
            icon="gem" name="Coupe d'or martelé"
            state="VOLÉE AU DRAGON"
            hint="+15 pts au dépôt."
            spriteTone="treasure" treasure
          />
        </div>
      </div>
    </div>

    <SubLabel>CARRY METER · capacité 7 (limite canon)</SubLabel>
    <div style={{
      padding: "10px 12px",
      border: "1px dashed var(--c-ink-line)",
      background: "rgba(13,29,45,0.5)",
      display: "flex", alignItems: "center", gap: 12,
      maxWidth: 420,
    }}>
      <div style={{ display: "flex", gap: 3, flex: 1 }}>
        {Array.from({ length: 7 }).map((_, i) => (
          <div key={i} style={{
            flex: 1, height: 8,
            background: i < 5 ? "var(--c-amber)" : "rgba(122,106,78,0.25)",
            border: "1px solid var(--c-paper-ink)",
          }} />
        ))}
      </div>
      <span style={{ fontFamily: "var(--f-mono)", fontSize: 10, color: "var(--c-paper-faded)" }}>5/7 · 2 libres</span>
    </div>
  </Card>
);

// ───────────────────────────────────────────────────────────
// ASSETS · spec dimensions, formats, naming conventions
// ───────────────────────────────────────────────────────────
const AssetTierCard = ({ tier, title, dims, displays, format, weight, naming, example, eyebrowColor = "var(--c-amber)" }) => (
  <div style={{
    border: `2px solid var(--c-ink-line)`,
    background: "rgba(13,29,45,0.6)",
    padding: 18,
    position: "relative",
  }}>
    <CornerBrackets color={eyebrowColor} size={8} thickness={1.5} inset={3} />

    <div style={{
      fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.18em",
      color: eyebrowColor, marginBottom: 6,
    }}>◆ TIER {tier}</div>
    <div style={{
      fontFamily: "var(--f-display)", fontSize: 18, fontWeight: 700,
      color: "var(--c-paper-bright)", letterSpacing: "0.01em",
      marginBottom: 14, lineHeight: 1,
    }}>{title}</div>

    <div style={{
      display: "grid", gridTemplateColumns: "120px 1fr", gap: 18,
    }}>
      {/* Example preview */}
      <div>
        {example}
      </div>

      {/* Spec table */}
      <div style={{
        display: "grid",
        gridTemplateColumns: "auto 1fr",
        rowGap: 6,
        columnGap: 12,
        fontFamily: "var(--f-mono)", fontSize: 11,
        alignSelf: "start",
      }}>
        <span style={{ color: "var(--c-paper-ink)" }}>master</span>
        <span style={{ color: "var(--c-paper-bright)" }}>{dims}</span>

        <span style={{ color: "var(--c-paper-ink)" }}>affichage</span>
        <span style={{ color: "var(--c-paper-warm)" }}>{displays}</span>

        <span style={{ color: "var(--c-paper-ink)" }}>format</span>
        <span style={{ color: "var(--c-amber)" }}>{format}</span>

        <span style={{ color: "var(--c-paper-ink)" }}>poids</span>
        <span style={{ color: "var(--c-paper-warm)" }}>{weight}</span>

        <span style={{ color: "var(--c-paper-ink)" }}>chemin</span>
        <span style={{ color: "var(--c-teal-glow)" }}>{naming}</span>
      </div>
    </div>
  </div>
);

const InventoryCanon = ({ items = [] }) => (
  <div style={{
    display: "grid",
    gridTemplateColumns: "repeat(5, 1fr)",
    gap: 8,
  }}>
    {items.map(it => (
      <div key={it.id} style={{ textAlign: "center" }}>
        <div style={{ display: "flex", justifyContent: "center", marginBottom: 6 }}>
          <ItemSprite icon={it.icon} size={56} tone={it.tone} src={it.src} glow={it.glow} />
        </div>
        <div style={{
          fontFamily: "var(--f-mono)", fontSize: 9,
          color: "var(--c-paper-faded)",
          letterSpacing: "0.04em",
          lineHeight: 1.2,
        }}>{it.id}</div>
      </div>
    ))}
  </div>
);

const AssetsSection = () => (
  <Card title="ASSETS · DIMENSIONS & CONVENTIONS" eyebrow="09 — Production">
    <p style={{ color: "var(--c-paper-faded)", fontSize: 13, lineHeight: 1.5, maxWidth: 820, margin: "0 0 22px" }}>
      Trois <strong style={{ color: "var(--c-amber)" }}>tiers</strong> de production pour les illustrations du jeu. Chaque tier a un <strong style={{ color: "var(--c-paper-bright)" }}>master haute résolution unique</strong> — Flutter downscale au runtime avec <code style={{ color: "var(--c-amber)" }}>FilterQuality.none</code>. Pas de jeu de variantes @2x/@3x à maintenir.
      Tous les objets et créatures sont <strong style={{ color: "var(--c-paper-bright)" }}>carrés 1:1</strong>, sur <strong style={{ color: "var(--c-teal-glow)" }}>fond transparent</strong> — le cadre <code style={{ color: "var(--c-amber)" }}>ItemSprite</code> fournit la couleur de fond selon le <em>tone</em> contextuel (lit, treasure, danger, magic).
    </p>

    <div style={{ display: "flex", flexDirection: "column", gap: 14, marginBottom: 28 }}>
      <AssetTierCard
        tier="1"
        title="Objets — inventaire, sheet, pickers"
        dims="512 × 512 px"
        displays="48 (card) · 56 (sheet) · 64 (encounter)"
        format="PNG transparent"
        weight="30 – 80 KB"
        naming="objects/<canonical_id>.png"
        eyebrowColor="var(--c-amber)"
        example={
          <div style={{ display: "flex", flexDirection: "column", gap: 6, alignItems: "center" }}>
            <ItemSprite icon="lamp" src="objects/lantern.png" size={64} tone="lit" glow />
            <div style={{ fontFamily: "var(--f-mono)", fontSize: 9, color: "var(--c-paper-ink)" }}>lantern.png</div>
          </div>
        }
      />
      <AssetTierCard
        tier="2"
        title="Créatures — encounters, bestiary"
        dims="768 × 768 px (ou 1024)"
        displays="64 (modal hero) · 96–128 (bestiary post-v1)"
        format="PNG transparent"
        weight="80 – 150 KB"
        naming="creatures/<canonical_id>.png"
        eyebrowColor="var(--c-danger)"
        example={
          <div style={{ display: "flex", flexDirection: "column", gap: 6, alignItems: "center" }}>
            <ItemSprite icon="dwarf" src="creatures/dwarf.png" size={64} tone="danger" glow />
            <div style={{ fontFamily: "var(--f-mono)", fontSize: 9, color: "var(--c-paper-ink)" }}>dwarf.png</div>
          </div>
        }
      />
      <AssetTierCard
        tier="3"
        title="Scènes — lieux 16:9"
        dims="320 × 180 px (pixel-art natif)"
        displays="full-bleed phone (~360 × 202)"
        format="WebP lossy q80"
        weight="20 – 60 KB"
        naming="scenes/<loc_id>.webp"
        eyebrowColor="var(--c-teal-glow)"
        example={
          <div style={{ width: 120 }}>
            <ScenePlaceholder
              label="loc_valley.webp"
              brief="320×180"
              lampGlow={false}
              src="scenes/loc_valley.png"
            />
          </div>
        }
      />
    </div>

    {/* Objets canon catalogue */}
    <SubLabel>INVENTAIRE CANONIQUE · 7 objets transportables + 15 trésors</SubLabel>
    <p style={{ color: "var(--c-paper-faded)", fontSize: 12, lineHeight: 1.5, marginTop: 0, marginBottom: 18 }}>
      Catalogue cible. Chaque sprite manquant utilise la version SVG pixel comme placeholder jusqu'à livraison.
    </p>

    <div style={{ marginBottom: 18 }}>
      <MonoTag>OUTILS & SURVIE</MonoTag>
      <InventoryCanon items={[
        { id: "lantern.png", icon: "lamp", tone: "lit", src: "objects/lantern.png", glow: true },
        { id: "keys.png",    icon: "key", tone: "default" },
        { id: "rod.png",     icon: "rod", tone: "default" },
        { id: "cage.png",    icon: "cage", tone: "default" },
        { id: "bottle.png",  icon: "bottle", tone: "default" },
        { id: "food.png",    icon: "food", tone: "default" },
        { id: "bird.png",    icon: "bird", tone: "magic" },
      ]} />
    </div>

    <div style={{ marginBottom: 18 }}>
      <MonoTag>TRÉSORS · 15 canon</MonoTag>
      <InventoryCanon items={[
        { id: "nugget.png",   icon: "coin", tone: "treasure" },
        { id: "diamonds.png", icon: "gem",  tone: "treasure" },
        { id: "silver.png",   icon: "gem",  tone: "treasure" },
        { id: "jewels.png",   icon: "gem",  tone: "treasure" },
        { id: "coins.png",    icon: "coin", tone: "treasure" },
        { id: "emerald.png",  icon: "gem",  tone: "treasure" },
        { id: "pyramid.png",  icon: "gem",  tone: "treasure" },
        { id: "pearl.png",    icon: "gem",  tone: "treasure" },
        { id: "vase.png",     icon: "gem",  tone: "treasure" },
        { id: "ruby.png",     icon: "gem",  tone: "treasure" },
        { id: "rug.png",      icon: "star", tone: "treasure" },
        { id: "trident.png",  icon: "star", tone: "treasure" },
        { id: "eggs.png",     icon: "gem",  tone: "treasure" },
        { id: "chain.png",    icon: "key",  tone: "treasure" },
        { id: "chest.png",    icon: "gem",  tone: "treasure" },
      ]} />
    </div>

    <div style={{ marginBottom: 18 }}>
      <MonoTag>CRÉATURES · encounters</MonoTag>
      <InventoryCanon items={[
        { id: "dwarf.png",  icon: "dwarf",  tone: "danger", src: "creatures/dwarf.png", glow: true },
        { id: "troll.png",  icon: "troll",  tone: "danger" },
        { id: "pirate.png", icon: "pirate", tone: "magic" },
        { id: "dragon.png", icon: "close",  tone: "hostile" },
        { id: "bird.png",   icon: "bird",   tone: "magic" },
      ]} />
    </div>

    {/* Prompt template */}
    <SubLabel>BRIEF · prompt template pour générateur</SubLabel>
    <pre style={{
      margin: 0,
      padding: "14px 16px",
      background: "rgba(6,16,26,0.7)",
      border: "1px dashed var(--c-amber)",
      color: "var(--c-paper-warm)",
      fontFamily: "var(--f-mono)", fontSize: 11,
      lineHeight: 1.65,
      overflow: "auto",
      whiteSpace: "pre-wrap",
    }}>{`Objet  → "Centered square illustration of a <object>, 1:1 aspect ratio,
          transparent background, pulp-retro 16-bit colored render,
          warm amber/copper highlights on deep indigo shadows,
          chunky proportions, hero-prop framing.  Output: 512×512 PNG."

Créature → "Full-body portrait of a <creature> for an adventure game,
          centered, 1:1 aspect ratio, transparent background,
          pulp-retro illustration style with stylized detail,
          menacing pose, warm rim-light from below (lantern).
          Output: 768×768 PNG."

Scène  → "Pixel-art landscape of <location_description>,
          16:9 320×180, restricted palette of deep navy + cream +
          amber lantern glow, painterly pixel cluster (Aseprite style),
          horizon mid-frame, dramatic depth.  Output: 320×180 WebP."`}</pre>
  </Card>
);

const DesignSystemBoard = () => (
  <div style={{
    width: DS_W,
    background: "var(--c-ink-void)",
    color: "var(--c-paper-warm)",
    fontFamily: "var(--f-body)",
    padding: 24,
    display: "flex",
    flexDirection: "column",
    gap: 20,
  }}>
    <CoverSection />
    <ColorSection />
    <TypeSection />
    <SpacingSection />
    <IconSection />
    <ComponentsSection />
    <FlashSection />
    <GameplaySection />
    <MotionSection />
    <AssetsSection />
  </div>
);

Object.assign(window, { DesignSystemBoard, DS_W });
