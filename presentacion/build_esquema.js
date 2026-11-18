// Esquema de sustentación para validación del docente.
// Uso: node build_esquema.js
const pptxgen = require("pptxgenjs");

const pptx = new pptxgen();
pptx.layout = "LAYOUT_WIDE";
pptx.title = "Esquema de sustentación — MicrofluidicML (para validación del docente)";
pptx.author = "Minería de Datos · Segundo parcial";
pptx.subject = "Storyboard de la oral de 20 min. No contiene resultados: es el plan a validar.";

require("./esquema_slides")(pptx);

pptx
  .writeFile({ fileName: "Esquema_Sustentacion_MicrofluidicML.pptx" })
  .then((f) => console.log("OK:", f));
