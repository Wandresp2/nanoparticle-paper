// Estilos y utilidades comunes para la presentación
const C = {
  ink: "0B0B0B", ink2: "52514E", muted: "8A8984", line: "E3E2DE",
  panel: "F3F2EF", soft: "EAF2FB",
  blue: "2A78D6", orange: "EB6834", gray: "BDBCB6", band: "1F3A5F", warn: "B5401A",
};
const FONT = "Calibri";
const REF = "Moore, T. L. et al. Unleashing the Power of Machine Learning in Nanomedicine Formulation Development. Adv. Funct. Mater. 2026, 36, e14387. DOI: 10.1002/adfm.202514387";

function header(pptx, s, title, kicker) {
  s.background = { color: "FFFFFF" };
  s.addShape(pptx.shapes.RECTANGLE, { x: 0, y: 0, w: 13.333, h: 0.95, fill: { color: C.band }, line: { color: C.band } });
  s.addText(kicker, { x: 0.45, y: 0.08, w: 12.4, h: 0.3, fontFace: FONT, fontSize: 11, color: "BFD3EA", bold: true });
  s.addText(title, { x: 0.45, y: 0.36, w: 12.4, h: 0.5, fontFace: FONT, fontSize: 24, color: "FFFFFF", bold: true });
}

function footer(pptx, s, n, total = 3) {
  s.addShape(pptx.shapes.LINE, { x: 0.45, y: 7.08, w: 12.43, h: 0, line: { color: C.line, width: 0.75 } });
  s.addText(REF, { x: 0.45, y: 7.1, w: 11.6, h: 0.3, fontFace: FONT, fontSize: 9, color: C.muted });
  s.addText(`${n}/${total}`, { x: 12.05, y: 7.1, w: 0.83, h: 0.3, fontFace: FONT, fontSize: 9, color: C.muted, align: "right" });
}

// Viñeta con partes en negrita: parts = [[texto, negrita], ...] o un string
function bullet(parts, extra = {}) {
  const arr = Array.isArray(parts) ? parts : [[parts, false]];
  return arr.map(([t, b], i) => ({
    text: t,
    options: { bold: !!b, bullet: i === 0 ? { indent: 14 } : undefined, breakLine: i === arr.length - 1, ...extra },
  }));
}

function section(s, { x, y, w, h, title, body, fontSize = 13 }) {
  const runs = [{ text: title, options: { bold: true, color: C.blue, fontSize: fontSize + 1, breakLine: true } }, ...body];
  s.addText(runs, { x, y, w, h, fontFace: FONT, fontSize, color: C.ink, valign: "top", paraSpaceAfter: 2, margin: 0 });
}

// Caja destacada con barra lateral azul
function callout(pptx, s, { x, y, w, h, runs, fontSize = 13 }) {
  s.addShape(pptx.shapes.RECTANGLE, { x, y, w, h, fill: { color: C.soft }, line: { color: C.blue, width: 1 } });
  s.addShape(pptx.shapes.RECTANGLE, { x, y, w: 0.09, h, fill: { color: C.blue }, line: { color: C.blue } });
  s.addText(runs, { x: x + 0.25, y: y + 0.05, w: w - 0.35, h: h - 0.1, fontFace: FONT, fontSize, valign: "middle", margin: 0 });
}

function panelBg(pptx, s, x, w) {
  s.addShape(pptx.shapes.RECTANGLE, { x, y: 1.2, w, h: 5.75, fill: { color: C.panel }, line: { color: C.panel } });
}

module.exports = { C, FONT, header, footer, bullet, section, callout, panelBg };
