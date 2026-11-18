// Diapositiva 2: por qué Random Forest, resultados y conclusiones
const { C, FONT, header, footer, bullet, section, panelBg } = require("./helpers");

module.exports = function slide2(pptx) {
  const s = pptx.addSlide();
  header(pptx, s, "¿Por qué ganó Random Forest? Resultados y conclusiones", "PARTE A · PROPUESTA  |  2. Modelo y resultados");

  section(s, {
    x: 0.45, y: 1.2, w: 8.4, h: 2.2, title: "¿Por qué Random Forest? (explicado fácil)",
    body: [
      ...bullet([["La relación receta → partícula ", 0], ["no es lineal", 1], [": los modelos lineales solo explican ~30 % del tamaño (r² ≈ 0.3).", 0]]),
      ...bullet([["RF es una ", 0], ["\"votación\" de cientos de árboles de decisión", 1], [": cada árbol aprende reglas del tipo \"si TFR alto y FRR bajo → partícula pequeña\"; al promediarlos capta umbrales e interacciones y se sobreajusta menos con pocos datos.", 0]]),
      ...bullet([["Tuvo el ", 0], ["menor error promedio", 1], [" en los 3 objetivos y los 2 tipos de partícula; además es rápido e interpretable con SHAP.", 0]]),
      ...bullet([["Ojo: ", 1], ["empate técnico con bagged trees, kNN y XGBoost (diferencias dentro de ±1 DE).", 0]], { color: C.ink2 }),
    ],
  });

  s.addText("Resultados en datos de prueba (Tabla 2): r² (RMSE)", { x: 0.45, y: 3.5, w: 8.4, h: 0.3, fontFace: FONT, fontSize: 14, bold: true, color: C.blue, margin: 0 });
  const hdr = (t) => ({ text: t, options: { bold: true, color: "FFFFFF", fill: { color: C.band }, align: "center" } });
  const cell = (t, o = {}) => ({ text: t, options: { align: "center", ...o } });
  const good = { bold: true };
  const weak = { bold: true, color: C.warn };
  s.addTable(
    [
      [hdr("Objetivo"), hdr("Lípidos (LNP + liposomas)"), hdr("PLGA")],
      [cell("Tamaño (dH)", { align: "left" }), cell("0.92  (9.5 nm)", good), cell("0.96  (7.5 nm)", good)],
      [cell("Uniformidad (PdI)", { align: "left" }), cell("0.79  (0.053)"), cell("0.56  (0.047)", weak)],
      [cell("Encapsulación (EE)", { align: "left" }), cell("0.47  (10.6 %)", weak), cell("0.98  (2.2 %)", good)],
    ],
    { x: 0.45, y: 3.85, w: 8.4, colW: [2.3, 3.4, 2.7], rowH: 0.3, fontFace: FONT, fontSize: 12, color: C.ink, border: { type: "solid", pt: 0.75, color: C.line }, fill: { color: "FFFFFF" } }
  );

  section(s, {
    x: 0.45, y: 5.2, w: 8.4, h: 1.8, title: "Conclusiones",
    body: [
      ...bullet([["El tamaño (y la EE en PLGA) se predicen ", 0], ["muy bien", 1], ["; PdI y EE en lípidos son el punto débil (datos ruidosos y pocos liposomas cargados).", 0]]),
      ...bullet([["El modelo ", 0], ["interpola pero no extrapola", 1], [": falla con materiales o rangos fuera de su base de datos.", 0]]),
      ...bullet([["Diseño inverso para 100 nm: ", 0], ["90 nm (LNP) y 97 nm (PLGA)", 1], [", al nivel de los mejores LLMs y sin inventar referencias.", 0]]),
    ],
  });

  // Gráfico: r² en CV de los 13 algoritmos (dH, lípidos, Tabla S1)
  const algos = [
    ["Random Forest", 0.860], ["Bagged trees", 0.858], ["k-vecinos (kNN)", 0.844], ["XGBoost", 0.832],
    ["Bagged MLP", 0.756], ["Bagged MARS", 0.678], ["SVM radial", 0.483], ["SVM polinomial", 0.349],
    ["Ridge", 0.327], ["LASSO", 0.325], ["Reg. lineal", 0.325], ["Reg. Poisson", 0.305], ["SVM lineal", 0.277],
  ];
  const gx = 9.1, gw = 3.95;
  panelBg(pptx, s, gx - 0.1, gw + 0.15);
  s.addText(
    [
      { text: "Comparación de los 13 algoritmos", options: { bold: true, fontSize: 13, color: C.ink, breakLine: true } },
      { text: "r² en validación cruzada · tamaño (dH), lípidos", options: { fontSize: 10, color: C.ink2 } },
    ],
    { x: gx, y: 1.27, w: gw, h: 0.55, fontFace: FONT, margin: 0 }
  );
  const labels = algos.map((a) => a[0]);
  s.addChart(
    pptx.charts.BAR,
    [
      { name: "Random Forest", labels, values: algos.map((a, i) => (i === 0 ? a[1] : 0)) },
      { name: "Otros algoritmos", labels, values: algos.map((a, i) => (i === 0 ? 0 : a[1])) },
    ],
    {
      x: gx - 0.05, y: 1.85, w: gw + 0.05, h: 4.45,
      barDir: "bar", barGrouping: "stacked", barGapWidthPct: 45,
      chartColors: [C.blue, C.gray],
      catAxisOrientation: "maxMin",
      catAxisLabelFontSize: 10, catAxisLabelColor: C.ink2, catAxisLabelFontFace: FONT, catAxisLineShow: false,
      valAxisMinVal: 0, valAxisMaxVal: 1, valAxisHidden: true, valGridLine: { style: "none" },
      showValue: true, dataLabelFormatCode: "0.00;;;", dataLabelFontSize: 9, dataLabelColor: C.ink, dataLabelFontFace: FONT,
      showLegend: true, legendPos: "b", legendFontSize: 10, legendColor: C.ink2, legendFontFace: FONT,
    }
  );
  s.addText(
    [
      { text: "Árboles arriba, lineales abajo → el problema es no lineal. ", options: { bold: true, color: C.ink } },
      { text: "Fuente: Tabla S1.", options: { color: C.muted } },
    ],
    { x: gx, y: 6.33, w: gw, h: 0.55, fontFace: FONT, fontSize: 10, margin: 0, valign: "top" }
  );

  footer(pptx, s, 2);
};
