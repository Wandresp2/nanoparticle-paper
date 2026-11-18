// Diapositiva 3: gap y cómo atacarlo
const { C, FONT, header, footer, bullet, section, callout, panelBg } = require("./helpers");

module.exports = function slide3(pptx) {
  const s = pptx.addSlide();
  header(pptx, s, "Gap: ¿el modelo realmente predice recetas que nunca vio?", "PARTE A · PROPUESTA  |  3. Gap y próximos pasos");

  section(s, {
    x: 0.45, y: 1.2, w: 8.4, h: 1.2, title: "¿Qué encontramos?",
    body: [
      ...bullet([["Cada receta se midió ", 0], ["3 veces", 1], [" (189 × 3 = 567), pero el paper separa entrenamiento y prueba ", 0], ["al azar por medición", 1], [", no por receta (Fig. S5).", 0]]),
      ...bullet("Además, las predicciones son un solo número, sin intervalo de confianza."),
    ],
  });

  section(s, {
    x: 0.45, y: 2.5, w: 8.4, h: 1.45, title: "¿Por qué es un gap?",
    body: [
      ...bullet([["Réplicas de la misma receta quedan en entrenamiento y en prueba → el modelo ", 0], ["\"ya vio la respuesta\"", 1], [" (fuga de información) y el r² reportado puede ser optimista.", 0]]),
      ...bullet([["En el laboratorio el modelo se usaría para recetas ", 0], ["nuevas", 1], ["; hoy no sabemos su error real ni cuánto confiar en cada predicción.", 0]]),
    ],
  });

  section(s, {
    x: 0.45, y: 4.0, w: 8.4, h: 1.75, title: "¿Cómo atacarlo? (mismos datos, solo ML clásico)",
    body: [
      ...bullet([["1. Partición por receta", 1], [" (GroupKFold) y prueba de extrapolación: dejar fuera un nivel de TFR/FRR o un tipo de partícula.", 0]]),
      ...bullet([["2. Cuantificar la incertidumbre", 1], [" con Quantile Random Forest, procesos gaussianos o bootstrap, y compararla con el ruido entre réplicas.", 0]]),
      ...bullet([["3. Diseño inverso con intervalo", 1], [": \"100 nm ± x nm, con probabilidad p\".", 0]]),
    ],
  });

  callout(pptx, s, {
    x: 0.45, y: 5.85, w: 8.4, h: 1.1,
    runs: [
      { text: "Hipótesis: ", options: { bold: true, color: C.blue } },
      { text: "al separar los datos por receta, el r² de prueba bajará, sobre todo en PdI y en la EE de lípidos.", options: { color: C.ink, breakLine: true } },
      { text: "Línea base: ", options: { bold: true, color: C.blue } },
      { text: "reproducción de la Tabla 2 con los datos y el código R del autor.", options: { color: C.ink } },
    ],
  });

  // Gráfico: split por medición vs split por receta
  const gx = 9.25, gw = 3.65;
  panelBg(pptx, s, gx - 0.15, gw + 0.3);
  s.addText("¿Dónde queda cada réplica?", { x: gx, y: 1.28, w: gw, h: 0.35, fontFace: FONT, fontSize: 13, bold: true, color: C.ink, margin: 0 });

  const legend = (x, color, label) => {
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x, y: 1.74, w: 0.22, h: 0.22, rectRadius: 0.04, fill: { color }, line: { color } });
    s.addText(label, { x: x + 0.3, y: 1.7, w: 1.4, h: 0.3, fontFace: FONT, fontSize: 10, color: C.ink2, margin: 0, valign: "middle" });
  };
  legend(gx, C.blue, "Entrenamiento");
  legend(gx + 1.75, C.orange, "Prueba");

  const recetas = ["Receta A", "Receta B", "Receta C"];
  const drawPanel = (y0, title, subtitle, assign, verdict, verdictColor) => {
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: gx, y: y0, w: gw, h: 2.35, rectRadius: 0.08, fill: { color: "FFFFFF" }, line: { color: C.line, width: 0.75 } });
    s.addText(
      [
        { text: title, options: { bold: true, fontSize: 12, color: C.ink, breakLine: true } },
        { text: subtitle, options: { fontSize: 10, color: C.ink2 } },
      ],
      { x: gx + 0.15, y: y0 + 0.08, w: gw - 0.3, h: 0.5, fontFace: FONT, margin: 0 }
    );
    recetas.forEach((r, i) => {
      const y = y0 + 0.7 + i * 0.42;
      s.addText(r, { x: gx + 0.15, y, w: 1.1, h: 0.32, fontFace: FONT, fontSize: 10, color: C.ink2, valign: "middle", margin: 0 });
      for (let k = 0; k < 3; k++) {
        const col = assign[i][k] === "T" ? C.blue : C.orange;
        const x = gx + 1.3 + k * 0.7;
        s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x, y, w: 0.6, h: 0.32, rectRadius: 0.05, fill: { color: col }, line: { color: "FFFFFF", width: 1.5 } });
        s.addText(`R${k + 1}`, { x, y, w: 0.6, h: 0.32, fontFace: FONT, fontSize: 9, bold: true, color: "FFFFFF", align: "center", valign: "middle", margin: 0 });
      }
    });
    s.addText(verdict, { x: gx + 0.15, y: y0 + 1.95, w: gw - 0.3, h: 0.32, fontFace: FONT, fontSize: 10, bold: true, color: verdictColor, margin: 0, valign: "middle" });
  };

  drawPanel(2.1, "Paper: separación por medición", "Las réplicas se reparten al azar",
    [["T", "T", "P"], ["T", "P", "T"], ["T", "T", "T"]], "✗ El modelo ya vio la receta en entrenamiento", C.warn);
  drawPanel(4.55, "Propuesta: separación por receta", "Todas las réplicas van juntas",
    [["T", "T", "T"], ["P", "P", "P"], ["T", "T", "T"]], "✓ Mide el error en recetas nuevas", "1A7F4E");

  footer(pptx, s, 3);
};
