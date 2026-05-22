/* eslint-disable */
// dialogs.jsx — confirmation dialogs layered over their parent screen.
// Smaller and less dramatic than EncounterModal (no big creature icon).
// Three scenarios demoed: delete save · attack dragon · quit game.

// ───────────────────────────────────────────────────────────
// Generic ConfirmDialog
// ───────────────────────────────────────────────────────────
const ConfirmDialog = ({
  eyebrow = "CONFIRMATION",
  title,
  description,
  detail,
  confirmLabel = "Confirmer",
  confirmHint,
  confirmTone = "primary",
  cancelLabel = "Annuler",
  borderColor = "var(--c-amber)",
  shadow = "var(--c-amber-shadow)",
  iconName,
  iconTone = "default",
}) => (
  <>
    <div style={{
      position: "absolute", inset: 0,
      background: "rgba(6,16,26,0.72)",
      zIndex: 8,
    }} />
    <div style={{
      position: "absolute",
      left: 24, right: 24,
      top: "50%",
      transform: "translateY(-50%)",
      zIndex: 9,
      background: "var(--c-ink-deep)",
      border: `2.5px solid ${borderColor}`,
      boxShadow: `5px 5px 0 0 ${shadow}`,
      padding: "16px 16px 16px",
    }}>
      <CornerBrackets color={borderColor} size={9} thickness={2} inset={4} />

      {/* eyebrow */}
      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 10, letterSpacing: "0.24em",
        color: borderColor, marginBottom: 10, textAlign: "center",
      }}>◆ {eyebrow}</div>

      {/* optional icon */}
      {iconName && (
        <div style={{ display: "flex", justifyContent: "center", marginBottom: 10 }}>
          <ItemSprite icon={iconName} size={44} tone={iconTone} />
        </div>
      )}

      {/* title */}
      <div style={{
        fontFamily: "var(--f-display)", fontSize: 18, fontWeight: 700,
        color: "var(--c-paper-bright)", letterSpacing: "0.01em",
        lineHeight: 1.1, marginBottom: 10, textAlign: "center",
      }}>{title}</div>

      {/* description */}
      {description && (
        <div style={{
          fontFamily: "var(--f-body)", fontSize: 13, lineHeight: 1.45,
          color: "var(--c-paper-warm)", textAlign: "center",
          marginBottom: 12, textWrap: "pretty",
        }}>{description}</div>
      )}

      {/* optional detail / stakes box */}
      {detail && (
        <div style={{
          padding: "8px 10px",
          background: "rgba(13,29,45,0.5)",
          border: `1px dashed ${borderColor}`,
          fontFamily: "var(--f-mono)", fontSize: 11,
          color: "var(--c-paper-warm)",
          lineHeight: 1.5,
          marginBottom: 12,
          letterSpacing: "0.04em",
        }}>{detail}</div>
      )}

      {/* actions */}
      <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
        <StampButton label={confirmLabel} hint={confirmHint} tone={confirmTone} />
        <StampButton label={cancelLabel} tone="faded" />
      </div>
    </div>
  </>
);


// ───────────────────────────────────────────────────────────
// 1 · DELETE SAVE — destructive confirmation over SavesPage
// ───────────────────────────────────────────────────────────
const DialogDeleteSave = () => (
  <PhoneShell>
    <SavesPage />
    {/* Layer dialog */}
    <ConfirmDialog
      eyebrow="ACTION DESTRUCTIVE"
      title="Effacer cette sauvegarde ?"
      description="Le slot « Antre du Dragon » sera supprimé définitivement. Cette action ne peut pas être annulée."
      detail={"Slot 2 · t.189 · 87 pts\nIl y a 3 jours · 18:30"}
      confirmLabel="Effacer définitivement"
      confirmHint="DELETE"
      confirmTone="hostile"
      cancelLabel="Garder la sauvegarde"
      borderColor="var(--c-danger)"
      shadow="#5a1a14"
      iconName="close"
      iconTone="danger"
    />
  </PhoneShell>
);

// Wrap SavesPage to render *inside* a PhoneShell within ours — we need
// the dialog absolute-positioned over the PhoneShell. SavesPage already
// is a PhoneShell, so nesting another doesn't work. Switch approach:
// render SavesPage directly and overlay the dialog on top.
const DialogDeleteSaveFixed = () => (
  <div style={{ position: "relative", width: PHONE_W, height: PHONE_H }}>
    <SavesPage />
    <ConfirmDialog
      eyebrow="ACTION DESTRUCTIVE"
      title="Effacer cette sauvegarde ?"
      description="Le slot « Antre du Dragon » sera supprimé définitivement. Cette action ne peut pas être annulée."
      detail={"Slot 2 · t.189 · 87 pts\nIl y a 3 jours · 18:30"}
      confirmLabel="Effacer définitivement"
      confirmHint="DELETE"
      confirmTone="hostile"
      cancelLabel="Garder la sauvegarde"
      borderColor="var(--c-danger)"
      shadow="#5a1a14"
      iconName="close"
      iconTone="danger"
    />
  </div>
);


// ───────────────────────────────────────────────────────────
// 2 · ATTACK DRAGON — risky combat decision
// ───────────────────────────────────────────────────────────
const DialogAttackDragon = () => (
  <div style={{ position: "relative", width: PHONE_W, height: PHONE_H }}>
    <AdventureChrome
      sceneLabel="dragon_lair.webp"
      sceneBrief="bloodless dragon"
      locationName="ANTRE DU DRAGON"
      subtitle="Souterrain · Profondeur VII"
      description="Le dragon sommeille, enroulé autour d'une stalagmite. Ta lanterne fait briller ses écailles vertes."
      lampState="bright"
      lampTurns={204}
      scorePill={{ value: "087", tone: "treasure" }}
      turnPill={{ value: "189" }}
      actionCount={4}
      tabActive="inventory"
    >
      <StampButton icon="back"  label="Repartir doucement" hint="BACK" tone="primary" />
      <StampButton icon="south" label="Aller au sud" hint="S" />
      <StampButton icon="eye"   label="Examiner le dragon" hint="LOOK" tone="meta" />
      <StampButton icon="close" label="L'attaquer à mains nues" hint="!" tone="hostile" />
    </AdventureChrome>
    <ConfirmDialog
      eyebrow="DÉCISION CRITIQUE"
      title="Attaquer le dragon à mains nues ?"
      description="Tu n'as aucune arme. Le dragon est ancien et féroce. Pourtant, dans la légende de cette grotte, quelqu'un l'a fait — et a survécu."
      detail={"Issue probable : MORT · −10 pts\nIssue canon (rare) : VICTOIRE · +20 pts"}
      confirmLabel="Avec mes poings ?"
      confirmHint="YES"
      confirmTone="hostile"
      cancelLabel="Sage décision, je passe"
      borderColor="var(--c-danger)"
      shadow="#5a1a14"
      iconName="dwarf"
      iconTone="danger"
    />
  </div>
);


// ───────────────────────────────────────────────────────────
// 3 · QUIT GAME — neutral warning, with autosave reminder
// ───────────────────────────────────────────────────────────
const DialogQuit = () => (
  <div style={{ position: "relative", width: PHONE_W, height: PHONE_H }}>
    <AdventureHall />
    <ConfirmDialog
      eyebrow="QUITTER L'AVENTURE ?"
      title="Sauvegardée à chaque tour"
      description="Ton aventure est sauvée automatiquement après chaque action. Tu pourras reprendre depuis le menu principal quand tu veux."
      detail={"Sauvegarde auto · HALL DES BRUMES\nt.047 · 23 pts · il y a 12 sec"}
      confirmLabel="Revenir au menu"
      confirmHint="HOME"
      confirmTone="primary"
      cancelLabel="Continuer l'aventure"
      borderColor="var(--c-amber)"
      shadow="var(--c-amber-shadow)"
      iconName="lamp"
      iconTone="lit"
    />
  </div>
);

Object.assign(window, {
  ConfirmDialog,
  DialogDeleteSave: DialogDeleteSaveFixed,
  DialogAttackDragon, DialogQuit,
});
