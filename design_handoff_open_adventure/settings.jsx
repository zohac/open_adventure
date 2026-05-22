/* eslint-disable */
// settings.jsx — SettingsPage : audio mixer, display, language, accessibility, data.
// Pixel-styled atoms : PixSlider · PixToggle · PixSegment · SettingRow.

// ───────────────────────────────────────────────────────────
// PixSlider — chunky pixel slider with stamp handle
// ───────────────────────────────────────────────────────────
const PixSlider = ({ value = 60, max = 100, color = "var(--c-amber)", showTicks = true }) => (
  <div style={{ position: "relative", height: 28, width: "100%" }}>
    {/* track */}
    <div style={{
      position: "absolute", left: 0, right: 0, top: 11,
      height: 8,
      background: "rgba(122,106,78,0.18)",
      border: "1.5px solid var(--c-paper-ink)",
    }}>
      {/* fill */}
      <div style={{
        position: "absolute", left: 0, top: 0, bottom: 0,
        width: `${(value/max)*100}%`,
        background: color,
        boxShadow: "inset 0 1px 0 rgba(255,255,255,0.18)",
      }} />
    </div>
    {/* ticks */}
    {showTicks && Array.from({ length: 11 }).map((_, i) => (
      <div key={i} style={{
        position: "absolute",
        left: `${i * 10}%`, top: 7, width: 1, height: 4,
        background: "var(--c-paper-ink)",
        opacity: i % 5 === 0 ? 0.9 : 0.45,
      }} />
    ))}
    {/* handle */}
    <div style={{
      position: "absolute",
      left: `calc(${(value/max)*100}% - 8px)`, top: 6,
      width: 16, height: 18,
      background: color,
      border: "2px solid var(--c-ink-void)",
      boxShadow: "1px 1px 0 0 var(--c-ink-void)",
    }} />
    {/* value label */}
    <div style={{
      position: "absolute", right: 0, top: -2,
      fontFamily: "var(--f-mono)", fontSize: 10,
      color: "var(--c-paper-warm)",
      letterSpacing: "0.04em",
    }}>{value}{max === 100 ? "%" : ""}</div>
  </div>
);


// ───────────────────────────────────────────────────────────
// PixToggle — chunky pixel switch
// ───────────────────────────────────────────────────────────
const PixToggle = ({ on = true, color = "var(--c-amber)" }) => (
  <div style={{
    width: 44, height: 22,
    background: on ? color : "rgba(122,106,78,0.18)",
    border: `2px solid ${on ? "var(--c-amber-shadow)" : "var(--c-paper-ink)"}`,
    position: "relative",
    cursor: "pointer",
    flexShrink: 0,
    boxShadow: on ? "2px 2px 0 0 var(--c-amber-shadow)" : "none",
  }}>
    <div style={{
      position: "absolute",
      left: on ? 22 : 2, top: 2,
      width: 14, height: 14,
      background: on ? "var(--c-ink-void)" : "var(--c-paper-warm)",
      transition: "left 80ms steps(2, end)",
    }} />
  </div>
);


// ───────────────────────────────────────────────────────────
// PixSegment — segmented control (2-3 options)
// ───────────────────────────────────────────────────────────
const PixSegment = ({ options = [], value }) => (
  <div style={{
    display: "inline-flex",
    border: "2px solid var(--c-ink-line)",
    background: "rgba(13,29,45,0.6)",
  }}>
    {options.map((o, i) => {
      const active = o.value === value;
      return (
        <button key={o.value} style={{
          padding: "7px 12px",
          background: active ? "var(--c-amber)" : "transparent",
          color: active ? "var(--c-ink-void)" : "var(--c-paper-warm)",
          fontFamily: "var(--f-caps)",
          fontSize: 10,
          letterSpacing: "0.1em",
          textTransform: "uppercase",
          border: "none",
          borderLeft: i > 0 ? "2px solid var(--c-ink-line)" : "none",
          cursor: "pointer",
          minWidth: 50,
        }}>{o.label}</button>
      );
    })}
  </div>
);


// ───────────────────────────────────────────────────────────
// SettingRow — one labelled row with right-aligned control
// ───────────────────────────────────────────────────────────
const SettingRow = ({ icon, label, sub, children, stacked }) => (
  <div style={{
    padding: "12px 12px",
    borderBottom: "1px dashed var(--c-ink-line)",
  }}>
    <div style={{
      display: "flex",
      alignItems: stacked ? "flex-start" : "center",
      gap: 12,
    }}>
      {icon && (
        <div style={{
          width: 26, height: 26, flexShrink: 0,
          border: "1.5px solid var(--c-ink-line)",
          background: "rgba(78,197,184,0.05)",
          display: "flex", alignItems: "center", justifyContent: "center",
        }}>
          <Icon name={icon} size={12} color="var(--c-teal-mist)" />
        </div>
      )}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          fontFamily: "var(--f-display)", fontSize: 14, fontWeight: 600,
          color: "var(--c-paper-bright)", letterSpacing: "0.01em", lineHeight: 1.1,
        }}>{label}</div>
        {sub && (
          <div style={{
            fontFamily: "var(--f-body)", fontSize: 11,
            color: "var(--c-paper-faded)", marginTop: 3, lineHeight: 1.3,
          }}>{sub}</div>
        )}
        {stacked && children && (
          <div style={{ marginTop: 10 }}>{children}</div>
        )}
      </div>
      {!stacked && children && (
        <div style={{ flexShrink: 0 }}>{children}</div>
      )}
    </div>
  </div>
);


// ───────────────────────────────────────────────────────────
// Section header
// ───────────────────────────────────────────────────────────
const SettingSection = ({ eyebrow, title, children }) => (
  <div style={{ marginBottom: 16 }}>
    <div style={{
      padding: "0 4px 8px",
      display: "flex", alignItems: "center", gap: 8,
    }}>
      <div style={{
        fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.18em",
        color: "var(--c-amber)",
      }}>◆ {eyebrow}</div>
    </div>
    <div style={{
      fontFamily: "var(--f-display)", fontSize: 17, fontWeight: 700,
      color: "var(--c-paper-bright)", letterSpacing: "0.01em",
      padding: "0 4px 10px",
    }}>{title}</div>
    <div style={{
      border: "1.5px solid var(--c-ink-line)",
      background: "rgba(13,29,45,0.5)",
    }}>
      {children}
    </div>
  </div>
);


// ───────────────────────────────────────────────────────────
// Audio zone chip (for the mixer preview)
// ───────────────────────────────────────────────────────────
const ZoneChip = ({ label, active, sub }) => (
  <button style={{
    flexShrink: 0,
    padding: "6px 10px",
    background: active ? "rgba(78,197,184,0.12)" : "transparent",
    border: active ? "2px solid var(--c-teal-glow)" : "2px solid var(--c-ink-line)",
    color: active ? "var(--c-teal-glow)" : "var(--c-paper-warm)",
    fontFamily: "var(--f-caps)",
    fontSize: 9,
    letterSpacing: "0.12em",
    textTransform: "uppercase",
    cursor: "pointer",
    display: "flex", flexDirection: "column", alignItems: "center", gap: 2,
    minWidth: 56,
  }}>
    {label}
    {sub && (
      <span style={{ fontFamily: "var(--f-mono)", fontSize: 8, opacity: 0.7 }}>{sub}</span>
    )}
  </button>
);


// ───────────────────────────────────────────────────────────
// SETTINGS PAGE
// ───────────────────────────────────────────────────────────
const SettingsPage = () => (
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
        }}>◆ AJUSTEMENTS</div>
        <div style={{
          fontFamily: "var(--f-display)", fontSize: 20, fontWeight: 700,
          color: "var(--c-paper-bright)", letterSpacing: "0.01em", lineHeight: 1,
        }}>OPTIONS</div>
      </div>
    </div>

    {/* Body */}
    <div style={{
      flex: 1,
      overflow: "auto",
      padding: "12px 12px 16px",
      background: "var(--c-ink-void)",
    }}>
      {/* AUDIO MIXER */}
      <SettingSection eyebrow="01 — AUDIO" title="Mixeur sonore">
        <SettingRow icon="speak" label="Musique d'ambiance" sub="BGM par zone, boucle gapless" stacked>
          <PixSlider value={60} color="var(--c-amber)" />
        </SettingRow>
        <SettingRow icon="speak" label="Effets sonores" sub="Tap, prendre, lampe, alerte nain" stacked>
          <PixSlider value={100} color="var(--c-teal-glow)" />
        </SettingRow>
        <SettingRow icon="speak" label="Couper le son" sub="Désactive BGM et SFX">
          <PixToggle on={false} />
        </SettingRow>

        {/* Zone preview */}
        <div style={{ padding: "12px", borderTop: "1px dashed var(--c-ink-line)" }}>
          <div style={{
            fontFamily: "var(--f-caps)", fontSize: 9, letterSpacing: "0.14em",
            color: "var(--c-paper-faded)", marginBottom: 8,
          }}>ZONES BGM · TAP POUR ÉCOUTER</div>
          <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
            <ZoneChip label="Surface" sub="30s loop" />
            <ZoneChip label="Grotte" active sub="48s loop" />
            <ZoneChip label="Rivière" sub="42s loop" />
            <ZoneChip label="Sanctuaire" sub="60s loop" />
            <ZoneChip label="Danger" sub="22s loop" />
          </div>
        </div>
      </SettingSection>

      {/* AFFICHAGE */}
      <SettingSection eyebrow="02 — VISUEL" title="Affichage">
        <SettingRow icon="eye" label="Taille du texte" sub="Description et journal" stacked>
          <PixSegment value="m" options={[
            { value: "s", label: "Petit" },
            { value: "m", label: "Moyen" },
            { value: "l", label: "Grand" },
          ]} />
        </SettingRow>
        <SettingRow icon="pin" label="Police pixel partout" sub="Sinon : sans-serif lisible">
          <PixToggle on={false} />
        </SettingRow>
        <SettingRow icon="star" label="VFX overlays" sub="Halo lampe, sparkle trésor, brume">
          <PixToggle on />
        </SettingRow>
        <SettingRow icon="lamp" label="Halo de lanterne" sub="Diminuer si épileptie sensible">
          <PixToggle on />
        </SettingRow>
      </SettingSection>

      {/* LANGUE */}
      <SettingSection eyebrow="03 — LANGUE" title="Localisation">
        <SettingRow icon="book" label="Langue de jeu" sub="Descriptions et UI">
          <PixSegment value="fr" options={[
            { value: "fr", label: "Français" },
            { value: "en", label: "English" },
          ]} />
        </SettingRow>
      </SettingSection>

      {/* ACCESSIBILITÉ */}
      <SettingSection eyebrow="04 — A11Y" title="Accessibilité">
        <SettingRow icon="eye" label="Contrastes élevés" sub="Renforce les bordures et ombres">
          <PixToggle on={false} />
        </SettingRow>
        <SettingRow icon="check" label="Confirmer chaque action" sub="Évite les erreurs de tap">
          <PixToggle on={false} />
        </SettingRow>
      </SettingSection>

      {/* DONNÉES */}
      <SettingSection eyebrow="05 — DONNÉES" title="Stockage local">
        <SettingRow icon="book" label="Exporter une sauvegarde" sub="Format JSON versionné">
          <span style={{ fontFamily: "var(--f-display)", fontSize: 18, color: "var(--c-paper-ink)" }}>›</span>
        </SettingRow>
        <SettingRow icon="close" label="Effacer toutes les sauvegardes" sub="Action irréversible · demande confirmation">
          <span style={{ fontFamily: "var(--f-display)", fontSize: 18, color: "var(--c-danger)" }}>›</span>
        </SettingRow>
      </SettingSection>

      {/* Footer */}
      <div style={{
        padding: "10px 4px 0",
        fontFamily: "var(--f-mono)", fontSize: 9,
        color: "var(--c-paper-ink)", textAlign: "center",
        letterSpacing: "0.06em",
        lineHeight: 1.6,
      }}>
        v1.0.0 · BSD 2-clauses<br/>
        100% offline · aucune télémétrie
      </div>
    </div>
  </PhoneShell>
);

Object.assign(window, {
  SettingsPage,
  PixSlider, PixToggle, PixSegment, SettingRow, SettingSection, ZoneChip,
});
