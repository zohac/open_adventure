/* eslint-disable */
// encounters.jsx — three narrative modals layered over Adventure:
//   · DwarfEncounter   random hostile (axe throw)
//   · PirateSteal      treasure stolen, mysterious moment
//   · TrollBridge      bribe demand, treasure-picker

// ───────────────────────────────────────────────────────────
// EncounterModal — generic centered modal
// ───────────────────────────────────────────────────────────
const EncounterModal = ({
  eyebrow = "RENCONTRE",
  title,
  icon,
  iconSrc,
  iconTone = "danger",
  description,
  children,
  actions = [],
  scrim = "rgba(6,16,26,0.78)",
  borderColor = "var(--c-danger)",
  shadow = "#3a0d08",
}) => (
  <>
    {/* scrim */}
    <div style={{
      position: "absolute", inset: 0,
      background: scrim,
      zIndex: 8,
    }} />
    {/* modal card */}
    <div style={{
      position: "absolute",
      left: 16, right: 16,
      top: "50%",
      transform: "translateY(-50%)",
      zIndex: 9,
      background: "var(--c-ink-deep)",
      border: `3px solid ${borderColor}`,
      boxShadow: `6px 6px 0 0 ${shadow}`,
      padding: "20px 18px 18px",
    }}>
      <CornerBrackets color={borderColor} size={12} thickness={2.5} inset={5} />

      {/* eyebrow */}
      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.28em",
        color: borderColor, textAlign: "center", marginBottom: 12,
      }}>◆ {eyebrow} ◆</div>

      {/* big icon */}
      {icon && (
        <div style={{
          display: "flex", justifyContent: "center", marginBottom: 14,
        }}>
          <ItemSprite icon={icon} src={iconSrc} size={64} tone={iconTone} glow />
        </div>
      )}

      {/* title */}
      <div style={{
        fontFamily: "var(--f-display)", fontSize: 26, fontWeight: 700,
        color: "var(--c-paper-bright)", letterSpacing: "0.02em",
        textAlign: "center", lineHeight: 1, marginBottom: 12,
        textShadow: `2px 2px 0 ${shadow}`,
      }}>{title}</div>

      {/* description */}
      {description && (
        <div style={{
          fontFamily: "var(--f-body)", fontSize: 13,
          color: "var(--c-paper-warm)", lineHeight: 1.5,
          textAlign: "center", marginBottom: 14,
          textWrap: "pretty",
        }}>{description}</div>
      )}

      {/* custom children (e.g. loot list, troll picker) */}
      {children}

      {/* actions */}
      <div style={{ display: "flex", flexDirection: "column", gap: 8, marginTop: 14 }}>
        {actions.map((a, i) => <StampButton key={i} {...a} />)}
      </div>
    </div>
  </>
);


// ───────────────────────────────────────────────────────────
// Muted Adventure backdrop — same chrome but disabled-feeling
// ───────────────────────────────────────────────────────────
const AdventureBackdrop = ({ children, ...props }) => (
  <AdventureChrome {...props}>{children}</AdventureChrome>
);


// ───────────────────────────────────────────────────────────
// 1 · DWARF ENCOUNTER — hostile, random apparition
// ───────────────────────────────────────────────────────────
const DwarfEncounter = () => (
  <AdventureBackdrop
    sceneLabel="hall_of_mists.webp"
    sceneBrief="dwarf attack"
    locationName="HALL DES BRUMES"
    subtitle="Souterrain · Profondeur II"
    description="Tu te tiens dans l'immense chambre voûtée…"
    lampState="bright"
    lampTurns={241}
    scorePill={{ value: "087", tone: "treasure" }}
    turnPill={{ value: "143" }}
    actionCount={4}
  >
    <StampButton icon="north" label="Aller au nord" hint="N" />
    <StampButton icon="east" label="Aller à l'est" hint="E" />
    <StampButton icon="down" label="Descendre" hint="DOWN" />
    <StampButton icon="eye" label="Observer le lieu" hint="LOOK" tone="meta" />

    <EncounterModal
      eyebrow="UN NAIN SURGIT"
      title="ATTAQUE !"
      icon="dwarf"
      iconSrc="creatures/dwarf.png"
      iconTone="danger"
      description="Un petit nain rugueux, l'œil rougeoyant, jaillit de l'ombre. Il dégaine une hache et te la lance à travers la salle. Tu n'as qu'un instant pour réagir."
      actions={[
        { icon: "back",  label: "Esquiver",            hint: "DODGE", tone: "primary" },
        { icon: "take",  label: "Lui lancer la hache", hint: "THROW", tone: "hostile" },
        { icon: "north", label: "Fuir au nord",        hint: "N",     tone: "meta" },
      ]}
    />
  </AdventureBackdrop>
);

// Override icon "hostile" to use close (since we don't have a dwarf icon)
// We patch ICONS at first render via the magic icon already there — actually ItemSprite uses an icon name. Let me ensure "hostile" name resolves.
// We'll feed it a real icon; rewrite to use "close" or "magic" or add a "dwarf" icon.
// To avoid editing pixel-ui.jsx again, use "close" with danger tone.


// ───────────────────────────────────────────────────────────
// 2 · PIRATE STEAL — mysterious, treasure theft
// ───────────────────────────────────────────────────────────
const PirateSteal = () => (
  <AdventureBackdrop
    sceneLabel="maze_twisty.webp"
    sceneBrief="furtive shadow"
    locationName="DÉDALE TORTUEUX"
    subtitle="Souterrain · Profondeur V"
    description="Tu es dans un dédale de petits passages tortueux, tous semblables…"
    lampState="bright"
    lampTurns={188}
    scorePill={{ value: "112", tone: "treasure" }}
    turnPill={{ value: "201" }}
    actionCount={3}
  >
    <StampButton icon="north" label="Aller au nord" hint="N" />
    <StampButton icon="west" label="Aller à l'ouest" hint="O" />
    <StampButton icon="up" label="Remonter" hint="UP" />

    <EncounterModal
      eyebrow="UN ÉCLAT DANS L'OMBRE"
      title="LE PIRATE !"
      icon="pirate"
      iconTone="magic"
      borderColor="var(--c-magic)"
      shadow="#3d2a55"
      scrim="rgba(20,8,40,0.78)"
      description="Une silhouette furtive bondit hors de l'obscurité, t'arrache un trésor des mains, et disparaît avec un rire moqueur dans les couloirs sinueux."
      actions={[
        { icon: "magic", label: "Maudit pirate !",         hint: "OK",   tone: "magic" },
        { icon: "eye",   label: "Vérifier l'inventaire",   hint: "BAG",  tone: "meta" },
      ]}
    >
      {/* stolen items */}
      <div style={{
        margin: "0 0 4px",
        padding: "10px 12px",
        background: "rgba(152,112,196,0.10)",
        border: "1px dashed var(--c-magic)",
      }}>
        <div style={{
          fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.16em",
          color: "var(--c-magic)", marginBottom: 8,
        }}>OBJETS DÉROBÉS</div>
        <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
          {[
            { icon: "gem",  name: "Émeraude" },
            { icon: "coin", name: "Pépite d'or" },
          ].map(t => (
            <div key={t.name} style={{
              display: "flex", alignItems: "center", gap: 10,
              fontFamily: "var(--f-display)", fontSize: 13,
              color: "var(--c-paper-bright)",
            }}>
              <ItemSprite icon={t.icon} size={26} tone="magic" />
              <span style={{ flex: 1 }}>{t.name}</span>
              <span style={{
                fontFamily: "var(--f-mono)", fontSize: 10,
                color: "var(--c-magic)",
                letterSpacing: "0.06em",
              }}>−14 pts</span>
            </div>
          ))}
        </div>
        <div style={{
          marginTop: 8, paddingTop: 8,
          borderTop: "1px dashed var(--c-magic)",
          fontFamily: "var(--f-body)", fontSize: 11,
          fontStyle: "italic",
          color: "var(--c-paper-faded)",
          textAlign: "center",
        }}>« Tu retrouveras peut-être son butin… »</div>
      </div>
    </EncounterModal>
  </AdventureBackdrop>
);


// ───────────────────────────────────────────────────────────
// 3 · TROLL BRIDGE — bribe demand, treasure picker
// ───────────────────────────────────────────────────────────
const TrollBridge = () => (
  <AdventureBackdrop
    sceneLabel="troll_bridge.webp"
    sceneBrief="pay troll!"
    locationName="GOUFFRE SUD-OUEST"
    subtitle="Souterrain · Profondeur III"
    description="Un pont en bois rickety enjambe le gouffre…"
    lampState="bright"
    lampTurns={163}
    scorePill={{ value: "098", tone: "treasure" }}
    turnPill={{ value: "172" }}
    actionCount={2}
  >
    <StampButton icon="south" label="Repartir au sud" hint="S" />
    <StampButton icon="eye" label="Observer le pont" hint="LOOK" tone="meta" />

    <EncounterModal
      eyebrow="LE PONT EST GARDÉ"
      title="PAY TROLL!"
      icon="troll"
      iconTone="danger"
      description="Un troll trapu sort de sous le pont et te barre le passage. Il tape de son gourdin sur le panneau crasseux :  « PAYE LE TROLL ! » Il faut lui jeter un trésor pour traverser."
      actions={[
        { icon: "back",  label: "Refuser et reculer",  hint: "BACK",  tone: "faded" },
      ]}
    >
      <div style={{
        margin: "0 0 4px",
      }}>
        <div style={{
          fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.16em",
          color: "var(--c-danger)", marginBottom: 8,
        }}>OFFRIR UN TRÉSOR</div>
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          {[
            { icon: "coin", name: "Pépite d'or",   pts: 14, recommended: false },
            { icon: "gem",  name: "Diamants",      pts: 14, recommended: true },
            { icon: "gem",  name: "Bijoux",        pts: 14, recommended: false },
          ].map(t => (
            <button key={t.name} style={{
              display: "flex", alignItems: "center", gap: 10,
              padding: "10px 12px",
              background: t.recommended ? "rgba(212,168,74,0.10)" : "transparent",
              border: t.recommended ? "2px solid var(--c-treasure)" : "2px solid var(--c-ink-line)",
              boxShadow: t.recommended ? "3px 3px 0 0 var(--c-amber-shadow)" : "none",
              cursor: "pointer",
              color: "var(--c-paper-warm)",
              textAlign: "left",
            }}>
              <ItemSprite icon={t.icon} size={30} tone={t.recommended ? "treasure" : "default"} />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{
                  fontFamily: "var(--f-display)", fontSize: 14, fontWeight: 600,
                  color: "var(--c-paper-bright)", lineHeight: 1,
                }}>{t.name}</div>
                <div style={{
                  fontFamily: "var(--f-mono)", fontSize: 10,
                  color: t.recommended ? "var(--c-treasure)" : "var(--c-paper-faded)",
                  marginTop: 3, letterSpacing: "0.04em",
                }}>{t.recommended ? "▸ recommandé" : "−" + t.pts + " pts au dépôt"}</div>
              </div>
              <Icon name="drop" size={12} color="var(--c-paper-faded)" />
            </button>
          ))}
        </div>
      </div>
    </EncounterModal>
  </AdventureBackdrop>
);

Object.assign(window, {
  EncounterModal, AdventureBackdrop,
  DwarfEncounter, PirateSteal, TrollBridge,
});
