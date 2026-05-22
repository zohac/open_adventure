/* eslint-disable */
// screens.jsx — Home + Adventure for Open Adventure.
// One unified grammar: STAMPS. Three Adventure states demo the system.

const PHONE_W = 360;
const PHONE_H = 760;

const PhoneShell = ({ children, bg = "var(--c-ink-void)" }) => (
  <div style={{
    width: PHONE_W, height: PHONE_H,
    background: bg,
    color: "var(--c-paper-warm)",
    fontFamily: "var(--f-body)",
    position: "relative",
    overflow: "hidden",
    display: "flex",
    flexDirection: "column",
  }}>
    {children}
  </div>
);


// ───────────────────────────────────────────────────────────
// HOME SCREEN
// ───────────────────────────────────────────────────────────
const HomeScreen = () => {
  return (
    <PhoneShell>
      <FakeStatusBar tint="var(--c-paper-faded)" />

      {/* Hero scene */}
      <div style={{ position: "relative" }}>
        <ScenePlaceholder
          label="loc_start.webp"
          brief="LOC_START · hero loop"
          lampGlow={true}
          src="scenes/loc_start.png"
        />
        <div style={{
          position: "absolute", left: 0, right: 0, bottom: 0, height: "55%",
          background: "linear-gradient(180deg, transparent 0%, var(--c-ink-void) 95%)",
          pointerEvents: "none",
        }} />
      </div>

      {/* Title block */}
      <div style={{
        position: "relative",
        marginTop: -64,
        padding: "0 20px",
        zIndex: 2,
        textAlign: "center",
      }}>
        <div style={{
          fontFamily: "var(--f-caps)",
          fontSize: 10,
          letterSpacing: "0.32em",
          color: "var(--c-amber)",
          marginBottom: 8,
        }}>◆ ÉDITION 16-BIT · 430 PTS ◆</div>
        <h1 style={{
          margin: 0,
          fontFamily: "var(--f-display)",
          fontWeight: 700,
          fontSize: 36,
          lineHeight: 1,
          color: "var(--c-paper-bright)",
          textShadow: "3px 3px 0 var(--c-amber-shadow), 0 0 24px var(--c-amber-halo)",
          letterSpacing: "0.02em",
        }}>OPEN<br/>ADVENTURE</h1>
        <div style={{
          marginTop: 10,
          fontFamily: "var(--f-body)",
          fontSize: 13,
          fontStyle: "italic",
          color: "var(--c-paper-faded)",
          letterSpacing: "0.02em",
        }}>« You are standing at the end of a road… »</div>

        <PixelDivider color="var(--c-paper-ink)" style={{ margin: "16px 36px 14px" }} />
      </div>

      {/* Menu — single grammar (stamps) */}
      <div style={{
        padding: "0 20px",
        display: "flex",
        flexDirection: "column",
        gap: 10,
        flex: 1,
      }}>
        <StampMenuItem
          icon="lamp"
          title="CONTINUER"
          sub="HALL DES BRUMES · t.047 · 23 PTS"
          tone="primary"
        />
        <StampMenuItem icon="plus" title="NOUVELLE AVENTURE" sub="Repartir du début" />
        <StampMenuItem icon="book" title="CHARGER"           sub="3 sauvegardes" />
        <StampMenuItem icon="gear" title="OPTIONS"           sub="Audio · Police · Langue" />
        <StampMenuItem icon="eye"  title="CRÉDITS"           sub="Crowther · Woods · Raymond" tone="faded" />
      </div>

      {/* Footer */}
      <div style={{
        padding: "16px 20px 18px",
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        fontFamily: "var(--f-mono)",
        fontSize: 9,
        letterSpacing: "0.06em",
        color: "var(--c-paper-ink)",
        borderTop: "1px solid var(--c-ink-hairline)",
      }}>
        <span>v1.0.0 · OFFLINE</span>
        <span style={{ display: "flex", gap: 4, alignItems: "center" }}>
          <span style={{ width: 6, height: 6, background: "var(--c-success)" }} />
          BSD · FR/EN
        </span>
      </div>
    </PhoneShell>
  );
};


// ───────────────────────────────────────────────────────────
// ADVENTURE CHROME — shared between game states
// ───────────────────────────────────────────────────────────
const AdventureChrome = ({
  children,
  sceneLabel = "hall_of_mists.webp",
  sceneBrief = "first visit · long",
  sceneSrc,
  locationName = "HALL DES BRUMES",
  subtitle = "Souterrain · Profondeur II",
  description,
  flash,
  scorePill = { value: "023", tone: "treasure" },
  lampState = "bright",
  lampTurns = 285,
  turnPill = { value: "047" },
  magicWord,
  itemSheet,
  tabActive = "inventory",
  actionCount = 5,
}) => {
  return (
    <PhoneShell>
      <FakeStatusBar tint="var(--c-paper-faded)" />

      {/* Top bar — slimmer now that lamp lives below as a diegetic prop */}
      <div style={{
        padding: "6px 12px 10px",
        display: "flex",
        gap: 6,
        alignItems: "center",
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
          <Icon name="menu" size={14} color="var(--c-paper-faded)" />
        </button>
        <Pill icon="coin" value={scorePill.value} tone={scorePill.tone} />
        <Pill label="T" value={turnPill.value} tone={turnPill.tone || "default"} />
        <div style={{ flex: 1 }} />
        <Pill icon="pin" label="Prof. II" tone="default" style={{ fontSize: 10 }} />
      </div>

      {/* Scene + floating lantern */}
      <div style={{ position: "relative" }}>
        <ScenePlaceholder label={sceneLabel} brief={sceneBrief} lampGlow={lampState === "bright"} src={sceneSrc} />
        <div style={{
          position: "absolute",
          right: 12,
          bottom: -22,
          zIndex: 3,
        }}>
          <LampShortcut state={lampState} turns={lampTurns} />
        </div>
      </div>

      {/* Location header */}
      <div style={{ padding: "14px 16px 4px", paddingRight: 80 }}>
        <div style={{
          fontFamily: "var(--f-caps)",
          fontSize: 10,
          letterSpacing: "0.14em",
          color: "var(--c-amber)",
          display: "flex", alignItems: "center", gap: 6,
          marginBottom: 4,
        }}>
          <Icon name="pin" size={11} color="var(--c-amber)" />
          {subtitle}
        </div>
        <h2 style={{
          margin: 0,
          fontFamily: "var(--f-display)",
          fontSize: 22,
          fontWeight: 700,
          letterSpacing: "0.01em",
          color: "var(--c-paper-bright)",
          lineHeight: 1.1,
        }}>{locationName}</h2>
      </div>

      {/* Description */}
      <div style={{
        padding: "8px 16px 12px",
        fontFamily: "var(--f-body)",
        fontSize: 14,
        lineHeight: 1.5,
        color: "var(--c-paper-warm)",
        textWrap: "pretty",
      }}>
        {description}
      </div>

      {/* Flash message (optional) */}
      {flash && (
        <div style={{
          margin: "0 16px 10px",
          padding: "10px 12px",
          border: `2px solid ${flash.tone === "danger" ? "var(--c-danger)" : "var(--c-amber)"}`,
          background: flash.tone === "danger" ? "rgba(212,74,58,0.12)" : "rgba(240,160,64,0.10)",
          color: flash.tone === "danger" ? "var(--c-danger)" : "var(--c-amber)",
          fontFamily: "var(--f-caps)",
          fontSize: 11,
          letterSpacing: "0.08em",
          textTransform: "uppercase",
          display: "flex", alignItems: "center", gap: 8,
          boxShadow: "3px 3px 0 0 var(--c-ink-void)",
        }}>
          {flash.icon && <Icon name={flash.icon} size={14} color="currentColor" />}
          <span style={{ flex: 1 }}>{flash.text}</span>
        </div>
      )}

      {/* Action list */}
      <div style={{
        padding: "8px 14px 14px",
        flex: 1,
        overflow: "auto",
        borderTop: "1px dashed var(--c-ink-line)",
      }}>
        <div style={{
          fontFamily: "var(--f-caps)",
          fontSize: 10,
          letterSpacing: "0.14em",
          color: "var(--c-paper-ink)",
          marginBottom: 10,
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
        }}>
          <span>QUE FAIRE ?</span>
          <span style={{ fontFamily: "var(--f-mono)", fontSize: 9 }}>{actionCount} OPTIONS</span>
        </div>
        {magicWord && (
          <div style={{ marginBottom: 9 }}>
            <MagicWordSurface word={magicWord.word} hint={magicWord.hint} />
          </div>
        )}
        <div style={{ display: "flex", flexDirection: "column", gap: 9 }}>
          {children}
        </div>
      </div>

      <BottomNav active={tabActive} />

      {/* Item action sheet overlay */}
      {itemSheet && (
        <>
          <div style={{
            position: "absolute", inset: 0,
            background: "rgba(6,16,26,0.55)",
            zIndex: 4,
          }} />
          <ItemActionSheet {...itemSheet} />
        </>
      )}
    </PhoneShell>
  );
};


// ───────────────────────────────────────────────────────────
// ADVENTURE STATES — demoing the grammar in real game contexts
// ───────────────────────────────────────────────────────────

// STATE 0 — LOC_START · the canonical opening (real pixel-art scene)
const AdventureStart = () => (
  <AdventureChrome
    sceneLabel="loc_start.webp"
    sceneBrief="first launch · long"
    sceneSrc="scenes/loc_start.png"
    locationName="DEVANT LE COTTAGE"
    subtitle="Surface · Forêt"
    description="Tu te tiens au bout d'une route, devant une petite maison en briques. Autour de toi s'étend une forêt. Une petite rivière coule en sortant de la maison et descend dans un ravin."
    actionCount={5}
    lampState="dark"
    lampTurns={300}
    scorePill={{ value: "000", tone: "treasure" }}
    turnPill={{ value: "001" }}
    tabActive="inventory"
  >
    <StampButton icon="take" label="Entrer dans le cottage" hint="IN"  tone="primary" />
    <StampButton icon="east" label="Suivre la rivière"      hint="E" />
    <StampButton icon="south" label="Aller au sud (forêt)"   hint="S" />
    <StampButton icon="north" label="Aller au nord"          hint="N" />
    <StampButton icon="eye"  label="Observer le lieu"        hint="LOOK" tone="meta" />
  </AdventureChrome>
);

// STATE 0b — LOC_VALLEY · forest valley with stream (canonical, surface, lit)
const AdventureValley = () => (
  <AdventureChrome
    sceneLabel="loc_valley.webp"
    sceneBrief="stream_gurgles · long"
    sceneSrc="scenes/loc_valley.png"
    locationName="DANS LA VALLÉE"
    subtitle="Surface · Forêt · au bord du ruisseau"
    description="Tu es dans une vallée au cœur de la forêt, près d'un ruisseau qui dégringole sur un lit rocheux."
    actionCount={6}
    lampState="dark"
    lampTurns={300}
    scorePill={{ value: "000", tone: "treasure" }}
    turnPill={{ value: "008" }}
    tabActive="inventory"
  >
    <StampButton icon="down"  label="Descendre vers la fente"  hint="DOWN" tone="primary" />
    <StampButton icon="north" label="Remonter au cottage"      hint="N" />
    <StampButton icon="east"  label="Entrer dans la forêt"     hint="E" />
    <StampButton icon="west"  label="Suivre l'orée à l'ouest"  hint="W" />
    <StampButton icon="eye"   label="Examiner le ruisseau"     hint="LOOK" tone="meta" />
    <StampButton icon="pin"   label="Approcher de la dépression" hint="DEPR" tone="meta" />
  </AdventureChrome>
);

// STATE 0c — LOC_WINDING · long winding corridor (DEEP, dark, lit lamp)
const AdventureWinding = () => (
  <AdventureChrome
    sceneLabel="loc_winding.webp"
    sceneBrief="DEEP · long corridor"
    sceneSrc="scenes/loc_winding.png"
    locationName="CORRIDOR SINUEUX"
    subtitle="Souterrain · Profondeur III"
    description="Tu es dans un long corridor sinueux qui s'incline et disparaît hors de vue, dans les deux directions. La pierre est froide et la lanterne projette des ombres dansantes sur les parois."
    actionCount={3}
    lampState="bright"
    lampTurns={241}
    scorePill={{ value: "045", tone: "treasure" }}
    turnPill={{ value: "062" }}
    tabActive="inventory"
  >
    <StampButton icon="down" label="Descendre vers la salle basse" hint="DOWN"  tone="primary" />
    <StampButton icon="up"   label="Monter vers le gouffre"        hint="UP" />
    <StampButton icon="eye"  label="Observer le corridor"          hint="LOOK"  tone="meta" />
  </AdventureChrome>
);

// STATE 1 — Hall of Mists, first visit, calm exploration
const AdventureHall = () => (
  <AdventureChrome
    description="Tu te tiens dans une immense chambre voûtée. Une rivière souterraine murmure quelque part en contrebas. Des brumes pâles s'enroulent autour de tes chevilles, et le faisceau de ta lanterne dévoile des fissures sombres à l'est, au nord, et vers le bas."
    actionCount={5}
    lampState="bright"
    lampTurns={285}
  >
    <StampButton icon="north" label="Aller au nord"   hint="N"     tone="primary" />
    <StampButton icon="east"  label="Aller à l'est"   hint="E" />
    <StampButton icon="down"  label="Descendre"       hint="DOWN" />
    <StampButton icon="take"  label="Prendre la lampe" hint="OBJ" />
    <StampButton icon="eye"   label="Observer le lieu" hint="LOOK" tone="meta" />
  </AdventureChrome>
);

// STATE 2 — Magic word unlocked (bird taught XYZZY)
const AdventureMagic = () => (
  <AdventureChrome
    sceneLabel="hall_of_mists.webp"
    sceneBrief="incantation possible"
    locationName="HALL DES BRUMES"
    subtitle="Souterrain · Profondeur II"
    description="L'oiseau t'a soufflé un mot qui résonne encore dans ta tête. Les murs de pierre semblent vibrer doucement, comme s'ils attendaient qu'on les nomme."
    flash={{ text: "L'oiseau te chante un mot magique : XYZZY", icon: "magic", tone: "default" }}
    actionCount={5}
    lampState="bright"
    lampTurns={241}
    magicWord={{ word: "XYZZY", hint: "T'envoie au cottage en pierre, peut-être" }}
    turnPill={{ value: "091" }}
    scorePill={{ value: "034", tone: "treasure" }}
  >
    <StampButton icon="north" label="Aller au nord"   hint="N" tone="primary" />
    <StampButton icon="east"  label="Aller à l'est"   hint="E" />
    <StampButton icon="down"  label="Descendre"       hint="DOWN" />
    <StampButton icon="take"  label="Prendre la coupe d'or" hint="OBJ" tone="treasure" />
    <StampButton icon="eye"   label="Observer le lieu" hint="LOOK" tone="meta" />
  </AdventureChrome>
);

// STATE 3 — Lamp critical, danger flash, retreat encouraged
const AdventureLamp = () => (
  <AdventureChrome
    sceneLabel="dark_passage.webp"
    sceneBrief="lamp dimming · short"
    locationName="PASSAGE OBSCUR"
    subtitle="Souterrain · Profondeur IV"
    description="L'air est lourd et froid. Ta lanterne vacille — la flamme s'amenuise. Au-delà de son halo, l'obscurité te dévore. Tu entends un grattement de pierre, peut-être un nain, peut-être autre chose."
    scorePill={{ value: "041", tone: "treasure" }}
    lampState="dim"
    lampTurns={29}
    turnPill={{ value: "112" }}
    flash={{ text: "La lampe faiblit · 29 tours restants", icon: "lamp", tone: "danger" }}
    actionCount={4}
    tabActive="inventory"
  >
    <StampButton icon="back"  label="Rebrousser chemin" hint="BACK"  tone="primary" />
    <StampButton icon="lamp"  label="Ranimer la lampe"  hint="LIGHT" tone="meta" />
    <StampButton icon="north" label="Continuer au nord" hint="N"     tone="danger" />
    <StampButton icon="eye"   label="Observer le lieu"  hint="LOOK"  tone="faded" />
  </AdventureChrome>
);

// STATE 4 — Treasure chamber, discovery
const AdventureTreasure = () => (
  <AdventureChrome
    sceneLabel="dragon_lair.webp"
    sceneBrief="discovery · long"
    locationName="ANTRE DU DRAGON"
    subtitle="Souterrain · Profondeur VII"
    description="Une cavité vaste et tiède. À tes pieds, un trésor scintille parmi les ossements : une coupe d'or martelé. Le dragon dort enroulé autour d'une stalagmite, sa respiration tiède soulève la poussière dorée."
    scorePill={{ value: "087", tone: "treasure" }}
    lampState="bright"
    lampTurns={204}
    turnPill={{ value: "189" }}
    flash={{ text: "Trésor découvert · Coupe d'or", icon: "coin", tone: "default" }}
    actionCount={5}
    tabActive="journal"
  >
    <StampButton icon="take"  label="Prendre la coupe"   hint="OBJ"   tone="treasure" />
    <StampButton icon="back"  label="Repartir doucement" hint="BACK" />
    <StampButton icon="eye"   label="Examiner le dragon" hint="LOOK"  tone="meta" />
    <StampButton icon="south" label="Aller au sud"       hint="S" />
    <StampButton icon="up"    label="Remonter"           hint="UP"    tone="faded" />
  </AdventureChrome>
);


// ───────────────────────────────────────────────────────────
// INVENTORY — pouch full of canon objects (mid-game)
// ───────────────────────────────────────────────────────────
const INVENTORY_SAMPLE = [
  // outils
  { icon: "lamp",   name: "Lanterne en cuivre", state: "ALLUMÉE · 204 tours",
    hint: "Brûle de l'huile. Faisceau d'environ 3 mètres.",
    spriteTone: "lit", glow: true, sprite: "objects/lantern.png" },
  { icon: "key",    name: "Trousseau de clefs", state: "5 CLEFS",
    hint: "Ouvre la grille à l'entrée des galeries." },
  { icon: "rod",    name: "Bâton noir", state: "MARQUE D'ÉTOILE",
    hint: "Un bâton de trois pieds, métallique, étrangement chaud." },
  { icon: "cage",   name: "Cage en osier", state: "OCCUPÉE",
    hint: "Légère, vannerie usée." },
  // survie
  { icon: "bottle", name: "Petite bouteille", state: "PLEINE · EAU",
    hint: "Contient de l'eau claire et fraîche." },
  { icon: "food",   name: "Ration de voyage", state: "1 PORTION",
    hint: "Pain, fromage sec, viande salée." },
  // vivant
  { icon: "bird",   name: "Petit oiseau", state: "DANS LA CAGE",
    hint: "Il chantait avant. La cage l'a fait taire.",
    spriteTone: "magic" },
];

const InventoryScreen = () => <InventoryPage items={INVENTORY_SAMPLE} capacity={7} />;


// ───────────────────────────────────────────────────────────
// ADVENTURE + ITEM ACTION SHEET (lantern selected — hero treatment)
// ───────────────────────────────────────────────────────────
const AdventureLanternSheet = () => (
  <AdventureChrome
    sceneLabel="loc_winding.webp"
    sceneBrief="corridor sinueux"
    sceneSrc="scenes/loc_winding.png"
    locationName="CORRIDOR SINUEUX"
    subtitle="Souterrain · Profondeur III"
    description="Tu es dans un long corridor sinueux. La pierre est froide ; ta lanterne projette des ombres dansantes."
    actionCount={3}
    lampState="bright"
    lampTurns={204}
    scorePill={{ value: "045", tone: "treasure" }}
    turnPill={{ value: "067" }}
    tabActive="inventory"
    itemSheet={{
      icon: "lamp",
      sprite: "objects/lantern.png",
      name: "Lanterne en cuivre",
      state: "ALLUMÉE · 204 TOURS RESTANTS",
      description: "Une lanterne en cuivre martelé. Sa flamme ronde et chaude éclaire à environ trois mètres. Tu peux l'éteindre pour économiser l'huile, ou la lâcher si ton sac est trop lourd.",
      spriteTone: "lit",
      actions: [
        { icon: "lamp", label: "Éteindre la lanterne", hint: "OFF",   tone: "primary" },
        { icon: "eye",  label: "Examiner la flamme",   hint: "LOOK",  tone: "meta" },
        { icon: "drop", label: "Verser de l'huile",    hint: "POUR" },
        { icon: "drop", label: "Lâcher la lanterne",   hint: "DROP",  tone: "faded" },
      ],
    }}
  >
    <StampButton icon="down" label="Descendre vers la salle basse" hint="DOWN" />
    <StampButton icon="up"   label="Monter vers le gouffre"        hint="UP" />
    <StampButton icon="eye"  label="Observer le corridor"          hint="LOOK" tone="meta" />
  </AdventureChrome>
);


// ───────────────────────────────────────────────────────────
// ADVENTURE + ITEM ACTION SHEET (bottle of water selected)
// ───────────────────────────────────────────────────────────
const AdventureItemSheet = () => (
  <AdventureChrome
    sceneLabel="west_pit.webp"
    sceneBrief="plant cries for water"
    locationName="FOSSE OUEST"
    subtitle="Souterrain · Profondeur III"
    description="Une fosse profonde. Au fond, une plante minuscule murmure « water, water… ». Elle a l'air assoiffée."
    actionCount={6}
    lampState="bright"
    lampTurns={198}
    scorePill={{ value: "052", tone: "treasure" }}
    turnPill={{ value: "127" }}
    tabActive="inventory"
    itemSheet={{
      icon: "bottle",
      name: "Petite bouteille",
      state: "PLEINE · EAU",
      description: "Une fiole de verre épais, à demi pleine d'eau cristalline. Tu pourrais la boire, la verser, ou la donner à quelque chose qui a soif.",
      spriteTone: "default",
      actions: [
        { icon: "drop",  label: "Verser sur la plante", hint: "USE",   tone: "primary" },
        { icon: "take",  label: "Boire l'eau",          hint: "DRINK", tone: "meta" },
        { icon: "drop",  label: "Vider la bouteille",   hint: "POUR" },
        { icon: "eye",   label: "Examiner",             hint: "LOOK",  tone: "faded" },
        { icon: "drop",  label: "Lâcher la bouteille",  hint: "DROP",  tone: "faded" },
      ],
    }}
  >
    <StampButton icon="up"   label="Remonter à l'est" hint="UP" />
    <StampButton icon="east" label="Aller à l'est"    hint="E" />
    <StampButton icon="down" label="Descendre dans la fosse" hint="DOWN" />
  </AdventureChrome>
);


Object.assign(window, {
  PhoneShell, HomeScreen,
  AdventureChrome, AdventureStart, AdventureValley, AdventureWinding, AdventureHall, AdventureMagic, AdventureLamp, AdventureTreasure,
  InventoryScreen, AdventureItemSheet, AdventureLanternSheet, INVENTORY_SAMPLE,
  PHONE_W, PHONE_H,
});
