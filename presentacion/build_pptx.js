// Genera la presentación de la Parte A. Uso: node build_pptx.js
const pptxgen = require("pptxgenjs");

const pptx = new pptxgen();
pptx.layout = "LAYOUT_WIDE"; // 13.333 x 7.5 in
pptx.title = "Parte A - Propuesta: MicrofluidicML";

require("./slide1")(pptx);
require("./slide2")(pptx);
require("./slide3")(pptx);

pptx.writeFile({ fileName: "Parte_A_Propuesta_MicrofluidicML.pptx" }).then((f) => console.log("OK:", f));
