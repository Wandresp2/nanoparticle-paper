// Storyboard de la sustentación oral (20 min + 5 de preguntas).
// Contenido deliberadamente de ESQUEMA: qué se diría en cada slide,
// sin resultados ejecutados. Pensado para que el docente valide alcance y énfasis.
const { C, FONT, header, footer, bullet, section, callout, panelBg } = require("./helpers");

const TOTAL = 12;
const K = "ESQUEMA DE SUSTENTACIÓN  ·  PARA VALIDACIÓN DEL DOCENTE  ·  20 min + 5 de preguntas";

function chip(pptx, s, { x, y, w, h, fill, color, text }) {
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x, y, w, h, rectRadius: 0.06, fill: { color: fill }, line: { color: fill },
  });
  s.addText(text, {
    x, y, w, h, fontFace: FONT, fontSize: 11, bold: true, color, align: "center", valign: "middle", margin: 0,
  });
}

function timeChip(pptx, s, label, x = 11.15) {
  chip(pptx, s, { x, y: 1.05, w: 1.75, h: 0.28, fill: C.soft, color: C.blue, text: label });
}

function hdr(t) {
  return { text: t, options: { bold: true, color: "FFFFFF", fill: { color: C.band }, align: "center", valign: "middle" } };
}
function cell(t, o = {}) {
  return { text: t, options: { align: "center", valign: "middle", ...o } };
}
function cellL(t, o = {}) {
  return { text: t, options: { align: "left", valign: "middle", ...o } };
}

module.exports = function addSlides(pptx) {
  slideCover(pptx);
  slideMapa(pptx);
  slidePaper(pptx);
  slideAlcance(pptx);
  slideMetodoB(pptx);
  slideReporteB(pptx);
  slideGap(pptx);
  slideHipotesis(pptx);
  slideResultadosD(pptx);
  slideQuimica(pptx);
  slideEntregables(pptx);
  slideValidar(pptx);
};

function slideCover(pptx) {
  const s = pptx.addSlide();
  s.background = { color: "FFFFFF" };
  s.addShape(pptx.shapes.RECTANGLE, { x: 0, y: 0, w: 0.22, h: 7.5, fill: { color: C.band }, line: { color: C.band } });
  s.addShape(pptx.shapes.RECTANGLE, { x: 0, y: 0, w: 13.333, h: 0.12, fill: { color: C.band }, line: { color: C.band } });

  s.addText("MINERÍA DE DATOS  ·  SEGUNDO PARCIAL", {
    x: 0.7, y: 1.15, w: 12, h: 0.3, fontFace: FONT, fontSize: 13, bold: true, color: C.blue, margin: 0,
  });
  s.addText("Esquema de la sustentación oral", {
    x: 0.7, y: 1.55, w: 12, h: 0.7, fontFace: FONT, fontSize: 32, bold: true, color: C.ink, margin: 0,
  });
  s.addText("Reproducción y extensión de MicrofluidicML\nMoore et al., Adv. Funct. Mater. 2026", {
    x: 0.7, y: 2.3, w: 12, h: 0.7, fontFace: FONT, fontSize: 16, color: C.ink2, margin: 0,
  });

  callout(pptx, s, {
    x: 0.7, y: 3.2, w: 11.9, h: 1.35,
    runs: [
      { text: "Esto no es la presentación del día del parcial. ", options: { bold: true, color: C.blue } },
      { text: "Es el storyboard: orden, tiempos y qué se diría en cada diapositiva. El objetivo es validar con el docente, antes de ejecutar las Partes B–D, si falta algo, sobra algo, o hay que cambiar el énfasis.", options: { color: C.ink } },
    ],
  });

  const boxes = [
    ["Qué sí es", "Plan de 20 min alineado a la rúbrica. Alcance de reproducción, gap, hipótesis y experimentos propuestos."],
    ["Qué no es", "No hay resultados corridos. No es el informe. No desarrolla el código ni rehace la Parte A."],
    ["Qué se pide", "Marcar: ¿agregar, quitar o enfocar? Sobre todo el alcance de B y si el gap (fuga + incertidumbre) es el adecuado."],
  ];
  boxes.forEach((b, i) => {
    const x = 0.7 + i * 4.05;
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x, y: 4.75, w: 3.9, h: 1.85, rectRadius: 0.08, fill: { color: C.panel }, line: { color: C.line, width: 0.75 },
    });
    s.addText(b[0], { x: x + 0.18, y: 4.88, w: 3.54, h: 0.35, fontFace: FONT, fontSize: 14, bold: true, color: C.blue, margin: 0 });
    s.addText(b[1], { x: x + 0.18, y: 5.25, w: 3.54, h: 1.2, fontFace: FONT, fontSize: 13, color: C.ink, margin: 0 });
  });

  footer(pptx, s, 1, TOTAL);
}

function slideMapa(pptx) {
  const s = pptx.addSlide();
  header(pptx, s, "Mapa de los 20 minutos, alineado a la rúbrica", K);
  timeChip(pptx, s, "Guía de tiempo");

  s.addText("La Parte A (propuesta, 10 %) ya está entregada. La oral cubre el resto. Preguntas: 5 min al final.", {
    x: 0.45, y: 1.4, w: 12.4, h: 0.35, fontFace: FONT, fontSize: 13, color: C.ink2, margin: 0,
  });

  s.addTable(
    [
      [hdr("Bloque en la oral"), hdr("Min"), hdr("Rúbrica"), hdr("Qué debe quedar claro"), hdr("¿Se puede recortar?")],
      [cellL("1. Recordatorio del paper", { bold: true }), cell("2"), cell("—"), cellL("Pregunta, datos, RF. Sin rehacer la Parte A."), cell("Sí: si el docente ya lo tiene fresco.")],
      [cellL("2. Reproducción (Parte B)", { bold: true }), cell("7"), cell("30 %"), cellL("Qué se replica, cómo, tabla paper vs. nosotros, discrepancias."), cell("No. Es el bloque más pesado.")],
      [cellL("3. Gap (Parte C)", { bold: true }), cell("3"), cell("15 %"), cellL("Qué no respondió el paper, por qué importa en el lab, por qué es viable."), cell("Poco: 1 slide densa basta.")],
      [cellL("4. Trabajo nuevo (Parte D)", { bold: true }), cell("6"), cell("25 %"), cellL("Hipótesis, diseño, resultados, lectura química."), cell("Sí: recortar extras, no el experimento 1.")],
      [cellL("5. Código y cierre", { bold: true }), cell("2"), cell("10 % + 10 %"), cellL("Repo ejecutable, código propio, anexo de IA, mensaje final."), cell("Mantener corto.")],
    ],
    {
      x: 0.45, y: 1.85, w: 12.4, colW: [2.7, 0.85, 1.35, 5.1, 2.4], rowH: 0.72,
      fontFace: FONT, fontSize: 12, color: C.ink, border: { type: "solid", pt: 0.75, color: C.line }, fill: { color: "FFFFFF" },
    }
  );

  callout(pptx, s, {
    x: 0.45, y: 5.7, w: 12.4, h: 1.2,
    runs: [
      { text: "Criterio de diseño. ", options: { bold: true, color: C.blue } },
      { text: "Más tiempo a reproducción y trabajo nuevo (55 % de la nota). El paper se resume, no se vuelve a explicar. Lo opcional (diseño inverso, SHAP extra, lípidos) se marca en naranja en las slides siguientes para que el docente decida si entra o no.", options: { color: C.ink } },
    ],
  });

  footer(pptx, s, 2, TOTAL);
}

function slidePaper(pptx) {
  const s = pptx.addSlide();
  header(pptx, s, "Recordatorio del paper (máximo 2 minutos)", K);
  timeChip(pptx, s, "~2 min");

  section(s, {
    x: 0.45, y: 1.4, w: 8.3, h: 1.35, title: "En una frase",
    body: bullet([["Fabricaron ~200 recetas de nanopartículas en un chip microfluídico, midieron ", 0], ["tamaño (dH), uniformidad (PdI) y encapsulación (EE)", 1], [", y entrenaron ML clásico para predecir la partícula y proponer recetas (MicrofluidicML).", 0]]),
  });

  callout(pptx, s, {
    x: 0.45, y: 2.85, w: 8.3, h: 1.2,
    runs: [
      { text: "Pregunta del paper. ", options: { bold: true, color: C.blue } },
      { text: "¿Se pueden predecir dH, PdI y EE a partir de los parámetros de fabricación, con ML clásico y una base pequeña y propia, y usar el modelo para diseñar recetas?", options: { color: C.ink } },
    ],
  });

  section(s, {
    x: 0.45, y: 4.2, w: 8.3, h: 2.5, title: "Lo que el profesor ya vio en la Parte A (no se vuelve a desarrollar)",
    body: [
      ...bullet([["Datos: ", 1], ["189 formulaciones × 3 réplicas = 567 mediciones (LNP, liposomas, PLGA).", 0]]),
      ...bullet([["X: ", 1], ["TFR, FRR, concentración de cada reactivo, razón material:fármaco.", 0]]),
      ...bullet([["Modelo ganador: ", 1], ["Random Forest (13 algoritmos en screening). Predice muy bien dH; PdI y EE en lípidos son el punto débil.", 0]]),
      ...bullet([["Mensaje del paper: ", 1], ["el modelo interpola, no extrapola; compite con LLMs sin alucinar.", 0]]),
    ],
  });

  panelBg(pptx, s, 9.05, 3.85);
  s.addText("Qué se dice / qué no", {
    x: 9.2, y: 1.35, w: 3.55, h: 0.35, fontFace: FONT, fontSize: 14, bold: true, color: C.ink, margin: 0,
  });
  s.addText(
    [
      { text: "Sí decir\n", options: { bold: true, color: C.blue, fontSize: 13, breakLine: true } },
      { text: "Problema de laboratorio, las 3 salidas, que RF ganó, y que vamos a reproducir un resultado concreto.\n\n", options: { color: C.ink, fontSize: 13, breakLine: true } },
      { text: "No decir\n", options: { bold: true, color: C.warn, fontSize: 13, breakLine: true } },
      { text: "No recontar los 13 algoritmos, ni SHAP, ni la pelea vs ChatGPT. Eso ya está en la propuesta y come minutos de B y D.", options: { color: C.ink, fontSize: 13 } },
    ],
    { x: 9.2, y: 1.8, w: 3.55, h: 4.85, fontFace: FONT, valign: "top", margin: 0 }
  );

  footer(pptx, s, 3, TOTAL);
}

function slideAlcance(pptx) {
  const s = pptx.addSlide();
  header(pptx, s, "Alcance propuesto: qué entra y qué se deja fuera", K);
  timeChip(pptx, s, "Decisión clave");

  s.addText("Reproducción parcial bien delimitada (permitida por las instrucciones). Esto es lo primero a validar.", {
    x: 0.45, y: 1.4, w: 12.4, h: 0.3, fontFace: FONT, fontSize: 13, color: C.ink2, margin: 0,
  });

  // Two columns: entra / no entra
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 0.45, y: 1.8, w: 6.05, h: 3.55, rectRadius: 0.08, fill: { color: "F3F8F4" }, line: { color: "1A7F4E", width: 1.25 },
  });
  s.addText("Entra en la oral y en el repo", {
    x: 0.65, y: 1.95, w: 5.65, h: 0.35, fontFace: FONT, fontSize: 15, bold: true, color: "1A7F4E", margin: 0,
  });
  s.addText(
    [
      ...bullet([["Parte B — principal: ", 1], ["Tabla 2, Random Forest, solo PLGA (dH, PdI, EE): RMSE y r² en train/test.", 0]]),
      ...bullet([["Parte B — secundario: ", 1], ["Tabla S2, screening de los 13 algoritmos en PLGA (media ± DE, 10-fold CV).", 0]]),
      ...bullet([["Parte C: ", 1], ["gap de generalización real (split por receta) + incertidumbre.", 0]]),
      ...bullet([["Parte D — núcleo: ", 1], ["GroupKFold vs. split aleatorio, y predicción con intervalo vs. ruido de réplicas.", 0]]),
    ],
    { x: 0.65, y: 2.4, w: 5.65, h: 2.75, fontFace: FONT, fontSize: 13, color: C.ink, valign: "top", margin: 0 }
  );

  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 6.7, y: 1.8, w: 6.15, h: 3.55, rectRadius: 0.08, fill: { color: "FBF4F1" }, line: { color: C.warn, width: 1.25 },
  });
  s.addText("Se deja fuera (salvo que el docente lo pida)", {
    x: 6.9, y: 1.95, w: 5.75, h: 0.35, fontFace: FONT, fontSize: 15, bold: true, color: C.warn, margin: 0,
  });
  s.addText(
    [
      ...bullet("Rehacer modelos de lípidos (LNP + liposomas) en la Tabla 2."),
      ...bullet("Comparación experimental vs ChatGPT / Gemini / DeepSeek."),
      ...bullet("Validación con datos de la literatura (Fig. S11)."),
      ...bullet("Entrenar de nuevo el grid search de 1000 combinaciones como resultado central."),
      ...bullet([["Opcional, marcado más adelante: ", 1], ["diseño inverso con intervalos; SHAP extra; variables físicas.", 0]]),
    ],
    { x: 6.9, y: 2.4, w: 5.75, h: 2.75, fontFace: FONT, fontSize: 13, color: C.ink, valign: "top", margin: 0 }
  );

  callout(pptx, s, {
    x: 0.45, y: 5.55, w: 12.4, h: 1.35,
    runs: [
      { text: "Por qué PLGA. ", options: { bold: true, color: C.blue } },
      { text: "Es el subconjunto más grande (324 mediciones), un solo material, resultados más limpios (dH r² 0.96, EE r² 0.98) y el punto más reproducible. Lípidos mezclan dos arquitecturas y la EE sale mal (r² 0.47): sirven mejor como discusión del gap que como línea base. ", options: { color: C.ink } },
      { text: "Pregunta al docente: ¿este recorte es suficiente para el 30 % de reproducción?", options: { bold: true, color: C.blue } },
    ],
  });

  footer(pptx, s, 4, TOTAL);
}

function slideMetodoB(pptx) {
  const s = pptx.addSlide();
  header(pptx, s, "Parte B — Cómo se reproduciría (mismo flujo, código propio)", K);
  timeChip(pptx, s, "~3 min");

  const steps = [
    ["1", "Datos", "mfNP_database.csv (567 filas). Una columna por reactivo, razón material:fármaco, propiedades del fármaco. Quitar varianza cero. Escalado [0,1]."],
    ["2", "Filtro físico", "dH y EE solo con PdI ≤ 0.25 (monodispersas). PdI se entrena con todas las muestras. Igual que el paper."],
    ["3", "Split", "85 / 15, estratificado por el target, semilla fija. Misma lógica que initial_split del código de los autores (por medición, no por receta)."],
    ["4", "Modelos", "RF con grid de mtry, trees, min_n. Screening de los 13 algoritmos con random search + 10-fold CV. Métricas: RMSE y r²."],
    ["5", "Honestidad", "Si no coincide: documentar supuestos (semilla, rangos de hiperparámetros, partículas vacías en EE, librería). No forzar el número del paper."],
  ];
  steps.forEach((st, i) => {
    const y = 1.2 + i * 0.85;
    s.addShape(pptx.shapes.OVAL, { x: 0.45, y: y + 0.15, w: 0.42, h: 0.42, fill: { color: C.blue }, line: { color: C.blue } });
    s.addText(st[0], { x: 0.45, y: y + 0.15, w: 0.42, h: 0.42, fontFace: FONT, fontSize: 13, bold: true, color: "FFFFFF", align: "center", valign: "middle", margin: 0 });
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x: 1.05, y, w: 8.0, h: 0.78, rectRadius: 0.06, fill: { color: "FFFFFF" }, line: { color: C.line, width: 0.75 },
    });
    s.addText(
      [
        { text: st[1], options: { bold: true, fontSize: 14, color: C.ink, breakLine: true } },
        { text: st[2], options: { fontSize: 12, color: C.ink2 } },
      ],
      { x: 1.2, y, w: 7.7, h: 0.78, fontFace: FONT, valign: "middle", margin: 0 }
    );
  });

  panelBg(pptx, s, 9.25, 3.65);
  s.addText("Normas que se respetan", {
    x: 9.4, y: 1.35, w: 3.35, h: 0.4, fontFace: FONT, fontSize: 14, bold: true, color: C.ink, margin: 0,
  });
  s.addText(
    [
      ...bullet("Implementación propia (Python + scikit-learn). El R de los autores se consulta, no se entrega como propio."),
      ...bullet("Semillas fijadas y versiones en requirements.txt."),
      ...bullet("Cada supuesto no reportado por el paper se declara como supuesto."),
      ...bullet("Reproducción fallida se reporta: las instrucciones lo valoran."),
    ],
    { x: 9.4, y: 1.85, w: 3.35, h: 4.7, fontFace: FONT, fontSize: 13, color: C.ink, valign: "top", margin: 0 }
  );

  footer(pptx, s, 5, TOTAL);
}

function slideReporteB(pptx) {
  const s = pptx.addSlide();
  header(pptx, s, "Parte B — Cómo se reportaría el resultado (slide tipo)", K);
  timeChip(pptx, s, "~4 min");

  s.addText("En la oral esta tabla llevaría los números corridos. Hoy muestra el formato y los valores del paper (PLGA, Tabla 2).", {
    x: 0.45, y: 1.35, w: 12.4, h: 0.3, fontFace: FONT, fontSize: 13, color: C.ink2, margin: 0,
  });

  s.addTable(
    [
      [hdr("Objetivo"), hdr("RMSE paper (test)"), hdr("r² paper (test)"), hdr("RMSE nuestro"), hdr("r² nuestro"), hdr("¿Coincide?")],
      [cellL("dH (nm)"), cell("7.5"), cell("0.964"), cell("—"), cell("—"), cell("a completar")],
      [cellL("PdI"), cell("0.047"), cell("0.560"), cell("—"), cell("—"), cell("a completar")],
      [cellL("EE (%)"), cell("2.2"), cell("0.984"), cell("—"), cell("—"), cell("a completar")],
    ],
    {
      x: 0.45, y: 1.75, w: 12.4, colW: [2.0, 2.15, 2.05, 2.1, 2.0, 2.1], rowH: 0.38,
      fontFace: FONT, fontSize: 13, color: C.ink, border: { type: "solid", pt: 0.75, color: C.line }, fill: { color: "FFFFFF" },
    }
  );

  s.addText("Secundario, si el tiempo alcanza: misma lógica para Tabla S2 (13 algoritmos, CV). Al menos RF, XGBoost, bagged trees, kNN y un lineal.", {
    x: 0.45, y: 3.05, w: 12.4, h: 0.35, fontFace: FONT, fontSize: 13, color: C.ink2, margin: 0,
  });

  section(s, {
    x: 0.45, y: 3.5, w: 6.2, h: 3.2, title: "Qué se diría al lado de la tabla",
    body: [
      ...bullet("Qué tan cerca quedamos del paper (orden de magnitud vs. coincidencia decimal)."),
      ...bullet("Si PdI sigue siendo el más difícil y EE el más fácil: eso ya es un resultado de reproducción."),
      ...bullet("Causas de diferencia, en este orden: split aleatorio, semilla, hiperparámetros no reportados, librería (randomForest vs sklearn), tratamiento de EE = 0."),
    ],
  });

  section(s, {
    x: 6.9, y: 3.5, w: 5.95, h: 3.2, title: "Criterio de éxito (para validar)",
    body: [
      ...bullet([["No es ", 0], ["sacar 0.964 exacto.", 1]]),
      ...bullet("Es: mismo flujo, mismas métricas, comparación explícita y análisis de discrepancias."),
      ...bullet("La línea base de B se reutiliza sin cambios como control del trabajo nuevo en D."),
    ],
  });

  footer(pptx, s, 6, TOTAL);
}

function slideGap(pptx) {
  const s = pptx.addSlide();
  header(pptx, s, "Parte C — El gap: ¿el modelo predice recetas que nunca vio?", K);
  timeChip(pptx, s, "~3 min");

  section(s, {
    x: 0.45, y: 1.25, w: 8.35, h: 1.15, title: "Qué no respondió el paper",
    body: [
      ...bullet([["Hay 3 réplicas por receta, pero el split 85/15 es ", 0], ["al azar por medición", 1], [" (Fig. S5 y el código: initial_split). Réplicas de la misma receta pueden quedar en train y en test.", 0]]),
      ...bullet("Las predicciones son un punto, sin intervalo. No se compara el error del modelo con el ruido experimental entre réplicas."),
    ],
  });

  section(s, {
    x: 0.45, y: 2.5, w: 8.35, h: 1.35, title: "Por qué importa en el laboratorio (no solo en métricas)",
    body: bullet("El uso real es proponer una receta nueva, no repetir una ya medida. Si el r² está inflado por fuga de réplicas, no sabemos si el modelo puede reemplazar experimentos. El intervalo dice si 100 nm es 100 ± 3 o 100 ± 40."),
  });

  section(s, {
    x: 0.45, y: 3.95, w: 8.35, h: 1.2, title: "Por qué es viable con estos datos",
    body: bullet("El CSV ya permite agrupar por formulación (mismas TFR, FRR, concentraciones, fármaco). Las 3 réplicas dan un piso de error irreducible. No hacen falta datos externos (prohibidos sin autorización)."),
  });

  callout(pptx, s, {
    x: 0.45, y: 5.3, w: 8.35, h: 1.55,
    runs: [
      { text: "Tipos de gap (según instrucciones). ", options: { bold: true, color: C.blue, breakLine: true } },
      { text: "Núcleo: generalización + incertidumbre.\n", options: { color: C.ink, breakLine: true } },
      { text: "Opcional (naranja): diseño inverso con probabilidad; ingeniería de variables físicas; PdI como clasificación. ¿El docente prefiere recortar a uno solo?", options: { color: C.ink } },
    ],
  });

  // Visual: split
  panelBg(pptx, s, 9.05, 3.85);
  s.addText("Dónde queda cada réplica", {
    x: 9.2, y: 1.35, w: 3.55, h: 0.35, fontFace: FONT, fontSize: 13, bold: true, color: C.ink, margin: 0,
  });
  const legend = (x, color, label, y = 1.78) => {
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x, y, w: 0.2, h: 0.2, rectRadius: 0.03, fill: { color }, line: { color } });
    s.addText(label, { x: x + 0.26, y: y - 0.04, w: 1.4, h: 0.28, fontFace: FONT, fontSize: 10, color: C.ink2, margin: 0, valign: "middle" });
  };
  legend(9.2, C.blue, "Train");
  legend(10.85, C.orange, "Test");

  const recetas = ["Receta A", "Receta B", "Receta C"];
  const draw = (y0, title, assign, verdict, vcol) => {
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x: 9.2, y: y0, w: 3.55, h: 2.15, rectRadius: 0.07, fill: { color: "FFFFFF" }, line: { color: C.line, width: 0.75 },
    });
    s.addText(title, { x: 9.35, y: y0 + 0.08, w: 3.25, h: 0.32, fontFace: FONT, fontSize: 12, bold: true, color: C.ink, margin: 0 });
    recetas.forEach((r, i) => {
      const y = y0 + 0.45 + i * 0.38;
      s.addText(r, { x: 9.35, y, w: 1.05, h: 0.3, fontFace: FONT, fontSize: 10, color: C.ink2, valign: "middle", margin: 0 });
      for (let k = 0; k < 3; k++) {
        const col = assign[i][k] === "T" ? C.blue : C.orange;
        const x = 10.45 + k * 0.7;
        s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x, y, w: 0.58, h: 0.28, rectRadius: 0.04, fill: { color: col }, line: { color: "FFFFFF" } });
        s.addText(`R${k + 1}`, { x, y, w: 0.58, h: 0.28, fontFace: FONT, fontSize: 9, bold: true, color: "FFFFFF", align: "center", valign: "middle", margin: 0 });
      }
    });
    s.addText(verdict, { x: 9.35, y: y0 + 1.72, w: 3.25, h: 0.32, fontFace: FONT, fontSize: 10, bold: true, color: vcol, margin: 0 });
  };
  draw(2.15, "Paper: por medición", [["T", "T", "P"], ["T", "P", "T"], ["T", "T", "T"]], "Ya vio la receta", C.warn);
  draw(4.5, "Propuesta: por receta", [["T", "T", "T"], ["P", "P", "P"], ["T", "T", "T"]], "Mide recetas nuevas", "1A7F4E");

  footer(pptx, s, 7, TOTAL);
}

function slideHipotesis(pptx) {
  const s = pptx.addSlide();
  header(pptx, s, "Parte D — Hipótesis y diseño (se fija antes de correr nada)", K);
  timeChip(pptx, s, "~2 min");

  callout(pptx, s, {
    x: 0.45, y: 1.25, w: 12.4, h: 1.35,
    runs: [
      { text: "H1. ", options: { bold: true, color: C.blue } },
      { text: "Al particionar por formulación, el r² de prueba del RF bajará de forma relevante, sobre todo en PdI (y en EE si se incluye lípidos).\n", options: { color: C.ink, breakLine: true } },
      { text: "H2. ", options: { bold: true, color: C.blue } },
      { text: "El error de dH en PLGA quedará cerca del ruido entre réplicas; el de PdI estará claramente por encima (piso de la DLS).", options: { color: C.ink } },
    ],
  });

  s.addTable(
    [
      [hdr("#"), hdr("Experimento"), hdr("Qué se compara"), hdr("Prioridad")],
      [cell("1", { bold: true }), cellL("Split por medición vs. split por receta (GroupKFold / leave-one-formulation-out)."), cellL("RMSE y r² contra la línea base de la Parte B."), cell("Núcleo", { bold: true, color: "1A7F4E" })],
      [cell("2", { bold: true }), cellL("Incertidumbre: Quantile RF, GP o bootstrap. Ancho del intervalo vs. SD de las 3 réplicas."), cellL("Calibración: ¿el 90 % de las recetas nuevas cae en el intervalo?"), cell("Núcleo", { bold: true, color: "1A7F4E" })],
      [cell("3"), cellL("Extrapolación: dejar fuera un nivel de TFR o FRR, o un tipo de partícula."), cellL("Caída de desempeño fuera del rango visto."), cell("Si alcanza", { color: C.orange, bold: true })],
      [cell("4"), cellL("Diseño inverso con intervalo: receta para 100 nm, ahora con P(90–110 nm)."), cellL("Misma idea del paper, pero con confianza."), cell("Si el docente lo pide", { color: C.orange, bold: true })],
    ],
    {
      x: 0.45, y: 2.8, w: 12.4, colW: [0.6, 5.3, 4.5, 2.0], rowH: 0.72,
      fontFace: FONT, fontSize: 12, color: C.ink, border: { type: "solid", pt: 0.75, color: C.line }, fill: { color: "FFFFFF" },
    }
  );

  s.addText("Reglas de D: mismos datos · solo ML clásico (sin deep learning) · hipótesis escrita antes de ver números · interpretación química, no solo métricas.", {
    x: 0.45, y: 5.85, w: 12.4, h: 0.95, fontFace: FONT, fontSize: 14, color: C.ink, margin: 0,
  });

  footer(pptx, s, 8, TOTAL);
}

function slideResultadosD(pptx) {
  const s = pptx.addSlide();
  header(pptx, s, "Parte D — Cómo se verían los resultados (slide tipo)", K);
  timeChip(pptx, s, "~3 min");

  s.addText("Estructura de la diapositiva de resultados. Los números se llenan al ejecutar; el docente valida si este es el gráfico correcto para pedir.", {
    x: 0.45, y: 1.3, w: 12.4, h: 0.35, fontFace: FONT, fontSize: 13, color: C.ink2, margin: 0,
  });

  // Left: table structure
  s.addText("Figura A — r² de prueba: split del paper vs. split por receta", {
    x: 0.45, y: 1.7, w: 6.3, h: 0.35, fontFace: FONT, fontSize: 13, bold: true, color: C.blue, margin: 0,
  });
  s.addTable(
    [
      [hdr("Target"), hdr("r² paper-like"), hdr("r² por receta"), hdr("Δ")],
      [cellL("dH PLGA"), cell("—"), cell("—"), cell("—")],
      [cellL("PdI PLGA"), cell("—"), cell("—"), cell("—")],
      [cellL("EE PLGA"), cell("—"), cell("—"), cell("—")],
    ],
    {
      x: 0.45, y: 2.1, w: 6.3, colW: [1.6, 1.7, 1.7, 1.3], rowH: 0.36,
      fontFace: FONT, fontSize: 12, color: C.ink, border: { type: "solid", pt: 0.75, color: C.line }, fill: { color: "FFFFFF" },
    }
  );
  s.addText("Lectura esperada si H1 es cierta: Δ negativo, más grande en PdI.", {
    x: 0.45, y: 3.3, w: 6.3, h: 0.35, fontFace: FONT, fontSize: 12, color: C.ink2, margin: 0,
  });

  s.addText("Figura B — error del modelo vs. ruido de réplicas", {
    x: 6.95, y: 1.7, w: 5.9, h: 0.35, fontFace: FONT, fontSize: 13, bold: true, color: C.blue, margin: 0,
  });
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 6.95, y: 2.1, w: 5.9, h: 1.55, rectRadius: 0.06, fill: { color: C.panel }, line: { color: C.line, width: 0.75 },
  });
  s.addText("Barras agrupadas por target:\n· SD entre las 3 réplicas (piso experimental)\n· RMSE del RF con split por receta\n· Ancho medio del intervalo 90 %", {
    x: 7.15, y: 2.22, w: 5.5, h: 1.3, fontFace: FONT, fontSize: 13, color: C.ink, margin: 0,
  });

  callout(pptx, s, {
    x: 0.45, y: 3.85, w: 12.4, h: 2.95,
    fontSize: 13,
    runs: [
      { text: "Qué se afirmaría, y qué no.\n", options: { bold: true, color: C.blue, breakLine: true } },
      { text: "Sí, si sale: parte del r² publicado es optimista porque el test no es una receta nueva; PdI está limitado por la DLS; dH en PLGA sí está cerca del ruido de laboratorio.\n\n", options: { color: C.ink, breakLine: true } },
      { text: "No: no se afirmaría que el paper está “mal”, ni que el modelo no sirve. El mensaje es de alcance: interpola recetas vistas; la cifra de generalización hay que medirla aparte.\n\n", options: { color: C.ink, breakLine: true } },
      { text: "Si H1 no se cumple (el r² no baja): también es un resultado. Se reporta y se discute por qué (pocas recetas, RF que memoriza el diseño factorial de 3 niveles, etc.).", options: { color: C.ink } },
    ],
  });

  footer(pptx, s, 9, TOTAL);
}

function slideQuimica(pptx) {
  const s = pptx.addSlide();
  header(pptx, s, "Interpretación física/química (obligatoria en D, no solo métricas)", K);
  timeChip(pptx, s, "~1.5 min");

  const cards = [
    ["Tamaño (dH)", "En PLGA lo controla sobre todo la concentración de polímero (nanoprecipitación). Si el RMSE del modelo ≈ SD de réplicas, el ML ya está al límite de la medición, no de la química."],
    ["Uniformidad (PdI)", "PdI > 0.25 hace poco fiable la DLS. Un r² bajo con split por receta no sería “modelo malo”: sería ruido físico. Por eso H2 separa dH de PdI."],
    ["Encapsulación (EE)", "En PLGA, curcumina hidrofóbica + polímero hidrofóbico → EE limpia y fácil de predecir. En lípidos es otro mecanismo: por eso no se mezclan en la línea base."],
    ["Uso en el lab", "Una receta de 100 nm solo es accionable si el intervalo cabe en 90–110 nm. Si el intervalo es de ±40 nm, el modelo no ahorra experimentos aunque el r² del paper sea 0.96."],
  ];
  cards.forEach((c, i) => {
    const col = i % 2;
    const row = Math.floor(i / 2);
    const x = 0.45 + col * 6.4;
    const y = 1.3 + row * 2.15;
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x, y, w: 6.2, h: 2.0, rectRadius: 0.08, fill: { color: C.panel }, line: { color: C.line, width: 0.75 },
    });
    s.addText(c[0], { x: x + 0.25, y: y + 0.15, w: 5.7, h: 0.4, fontFace: FONT, fontSize: 16, bold: true, color: C.blue, margin: 0 });
    s.addText(c[1], { x: x + 0.25, y: y + 0.6, w: 5.7, h: 1.2, fontFace: FONT, fontSize: 14, color: C.ink, margin: 0 });
  });

  footer(pptx, s, 10, TOTAL);
}

function slideEntregables(pptx) {
  const s = pptx.addSlide();
  header(pptx, s, "Lo que acompaña la oral (no se presenta minuto a minuto)", K);
  timeChip(pptx, s, "~1 min");

  const items = [
    ["Repo", "Notebooks o scripts de principio a fin. README: cómo poner los CSV y ejecutar. requirements.txt. Semillas fijas."],
    ["Código propio", "Se puede leer el R de Moore et al.; la entrega es implementación propia, explicable línea a línea."],
    ["Informe corto", "Tipo artículo: pregunta, método, tabla de reproducción, gap, resultados de D, discusión química, limitaciones."],
    ["Anexo de IA", "Obligatorio: qué herramienta se usó y para qué. El estudiante defiende el código en la oral."],
  ];
  items.forEach((it, i) => {
    const y = 1.25 + i * 1.05;
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x: 0.45, y, w: 8.35, h: 0.95, rectRadius: 0.07, fill: { color: "FFFFFF" }, line: { color: C.line, width: 0.75 },
    });
    s.addShape(pptx.shapes.RECTANGLE, { x: 0.45, y, w: 0.1, h: 0.95, fill: { color: C.blue }, line: { color: C.blue } });
    s.addText(it[0], { x: 0.75, y: y + 0.08, w: 7.85, h: 0.32, fontFace: FONT, fontSize: 15, bold: true, color: C.ink, margin: 0 });
    s.addText(it[1], { x: 0.75, y: y + 0.42, w: 7.85, h: 0.42, fontFace: FONT, fontSize: 13, color: C.ink2, margin: 0 });
  });

  panelBg(pptx, s, 9.05, 3.85);
  s.addText("Mensaje de cierre (20 s)", {
    x: 9.2, y: 1.35, w: 3.55, h: 0.45, fontFace: FONT, fontSize: 14, bold: true, color: C.ink, margin: 0,
  });
  s.addText("Reproducimos el RF en PLGA como línea base. Luego medimos lo que el paper no midió: el error en recetas no vistas y la incertidumbre frente al ruido de laboratorio. Eso decide si MicrofluidicML sirve para diseñar, o solo para interpolar.", {
    x: 9.2, y: 1.9, w: 3.55, h: 4.6, fontFace: FONT, fontSize: 14, color: C.ink, margin: 0,
  });

  footer(pptx, s, 11, TOTAL);
}

function slideValidar(pptx) {
  const s = pptx.addSlide();
  header(pptx, s, "Qué le pido al docente que valide", K);
  timeChip(pptx, s, "Esta slide es la importante");

  s.addText("Marcar sí / no / cambiar. Con esto se ajusta el plan antes de escribir código.", {
    x: 0.45, y: 1.28, w: 12.4, h: 0.28, fontFace: FONT, fontSize: 13, color: C.ink2, margin: 0,
  });

  s.addTable(
    [
      [hdr("#"), hdr("Decisión"), hdr("Propuesta actual"), hdr("¿OK?")],
      [cell("1"), cellL("Alcance de B"), cellL("Solo PLGA: Tabla 2 (RF) + Tabla S2 (13 algoritmos). Sin lípidos, sin LLMs, sin literatura."), cell("")],
      [cell("2"), cellL("Gap de C y D"), cellL("Fuga por réplicas (GroupKFold) + incertidumbre vs. ruido de réplicas. Hipótesis H1 y H2."), cell("")],
      [cell("3"), cellL("Qué recortar"), cellL("Extrapolación (exp. 3) y diseño inverso (exp. 4) solo si hay tiempo o si se piden."), cell("")],
      [cell("4"), cellL("Stack"), cellL("Python + scikit-learn, código propio. R de los autores como referencia, no como entrega."), cell("")],
      [cell("5"), cellL("Tiempo de la oral"), cellL("2 + 7 + 3 + 6 + 2 min. Más peso en B y D, paper muy corto."), cell("")],
      [cell("6"), cellL("Énfasis extra"), cellL("No incluir SHAP de nuevo (ya está en el paper) salvo que se pida interpretabilidad extra."), cell("")],
    ],
    {
      x: 0.45, y: 1.6, w: 12.4, colW: [0.55, 2.15, 8.3, 1.4], rowH: 0.62,
      fontFace: FONT, fontSize: 12, color: C.ink, border: { type: "solid", pt: 0.75, color: C.line }, fill: { color: "FFFFFF" },
    }
  );

  callout(pptx, s, {
    x: 0.45, y: 5.5, w: 12.4, h: 1.4,
    runs: [
      { text: "Si hay que cambiar una sola cosa, que sea esta. ", options: { bold: true, color: C.blue } },
      { text: "¿El 30 % de reproducción queda cubierto con PLGA, o debo meter también lípidos / dH de los dos grupos? Del resto (gap, Python, recortar diseño inverso) estoy más seguro; el alcance de B es donde más me interesa el criterio del curso.", options: { color: C.ink } },
    ],
  });

  footer(pptx, s, 12, TOTAL);
}
