// Diapositiva 1: de qué trata, pregunta, datos y procedimiento
const { C, FONT, header, footer, bullet, section, callout, panelBg } = require("./helpers");

module.exports = function slide1(pptx) {
  const s = pptx.addSlide();
  header(pptx, s, "ML para diseñar nanomedicinas fabricadas por microfluídica", "PARTE A · PROPUESTA  |  1. El paper y su pregunta");

  section(s, {
    x: 0.45, y: 1.2, w: 8.4, h: 1.25, title: "¿De qué trata?",
    body: [
      ...bullet([["Se fabricaron ", 0], ["nanopartículas para medicamentos", 1], [" (LNP, liposomas y PLGA, vacías o con curcumina) mezclando dos líquidos en un chip microfluídico y variando la \"receta\".", 0]]),
      ...bullet([["Se entrenaron modelos de ML para ", 0], ["predecir qué partícula sale de cada receta", 1], [" y luego usarlos al revés para proponer recetas.", 0]]),
    ],
  });

  callout(pptx, s, {
    x: 0.45, y: 2.55, w: 8.4, h: 1.2,
    runs: [
      { text: "Pregunta problema", options: { bold: true, color: C.blue, fontSize: 14, breakLine: true } },
      { text: "¿Se puede predecir el tamaño (dH), la uniformidad (PdI) y la eficiencia de encapsulación (EE) de una nanopartícula a partir de sus parámetros de fabricación, con ML clásico y una base de datos pequeña y propia, y usar ese modelo para diseñar recetas?", options: { color: C.ink } },
    ],
  });

  section(s, {
    x: 0.45, y: 3.9, w: 8.4, h: 0.8, title: "¿Por qué importa?",
    body: bullet("Hoy la receta se encuentra por prueba y error; el tamaño, la uniformidad y la carga de fármaco determinan el efecto biológico y deben ser reproducibles."),
  });

  section(s, {
    x: 0.45, y: 4.8, w: 8.4, h: 2.2, title: "Datos (compartidos por el autor, junto con el código en R)",
    body: [
      ...bullet([["Muestras: ", 1], ["189 formulaciones × 3 réplicas = ", 0], ["567 mediciones", 1], [" (lípidos: 243 · PLGA: 324).", 0]]),
      ...bullet([["Variables X: ", 1], ["caudal total (TFR), relación de flujos acuoso:orgánico (FRR), concentración de cada reactivo y razón material:fármaco (3 niveles cada una).", 0]]),
      ...bullet([["Objetivos y: ", 1], ["dH (nm), PdI (0–1) y EE (%) → 3 regresiones por grupo (lípidos / PLGA).", 0]]),
      ...bullet([["A reproducir: ", 1], ["Tabla 2 (Random Forest, RMSE y r² en train/test) para PLGA + Tabla S2 (13 algoritmos).", 0]]),
    ],
  });

  // Gráfico: flujo del procedimiento
  const gx = 9.25, gw = 3.65;
  panelBg(pptx, s, gx - 0.15, gw + 0.3);
  s.addText("Procedimiento (MicrofluidicML)", { x: gx, y: 1.28, w: gw, h: 0.35, fontFace: FONT, fontSize: 13, bold: true, color: C.ink, margin: 0 });
  const steps = [
    ["Fabricar y medir", "Chip microfluídico · DLS (dH, PdI) · UV-Vis (EE)"],
    ["Separar datos", "85 % entrenamiento / 15 % prueba"],
    ["Comparar 13 algoritmos", "Validación cruzada 10-fold · RMSE y r²"],
    ["Afinar Random Forest", "Grid search de 1000 combinaciones"],
    ["Evaluar e interpretar", "Datos de prueba · SHAP"],
    ["Diseño inverso", "Receta para 100 nm vs ChatGPT, Gemini y DeepSeek"],
  ];
  const top = 1.75, stepH = 0.7, gap = 0.17;
  steps.forEach(([t, d], i) => {
    const y = top + i * (stepH + gap);
    if (i < steps.length - 1) {
      s.addShape(pptx.shapes.LINE, { x: gx + 0.21, y: y + 0.5, w: 0, h: stepH + gap - 0.3, line: { color: C.blue, width: 1.5 } });
    }
    s.addShape(pptx.shapes.OVAL, { x: gx, y: y + 0.14, w: 0.42, h: 0.42, fill: { color: C.blue }, line: { color: C.blue } });
    s.addText(String(i + 1), { x: gx, y: y + 0.14, w: 0.42, h: 0.42, fontFace: FONT, fontSize: 13, bold: true, color: "FFFFFF", align: "center", valign: "middle", margin: 0 });
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: gx + 0.55, y, w: gw - 0.55, h: stepH, rectRadius: 0.06, fill: { color: "FFFFFF" }, line: { color: C.line, width: 0.75 } });
    s.addText(
      [
        { text: t, options: { bold: true, fontSize: 12, color: C.ink, breakLine: true } },
        { text: d, options: { fontSize: 10, color: C.ink2 } },
      ],
      { x: gx + 0.65, y, w: gw - 0.7, h: stepH, fontFace: FONT, valign: "middle", margin: 0 }
    );
  });

  footer(pptx, s, 1);
};
