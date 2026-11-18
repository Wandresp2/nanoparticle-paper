# Anexo · Declaración de uso de herramientas de IA

Las normas del parcial (`contexto/Instrucciones.pdf`, §7) permiten usar herramientas de IA como apoyo, siempre que se declare **qué se usó y para qué**, y que el estudiante pueda explicar cada línea del código.

> Este anexo se va completando a lo largo del proyecto. **Debe revisarlo y completarlo el estudiante** antes de la entrega.

| Herramienta | Para qué se usó | Parte |
|---|---|---|
| Claude Code (Anthropic, modelo Claude Opus) | Lectura y explicación del paper y del material suplementario; borrador del documento explicativo | A |
| Claude Code | Generación de las diapositivas de la propuesta (pptxgenjs) | A |
| Claude Code | Análisis exploratorio de los CSV y lectura del código R del autor (`Analisis_datos_y_codigo_R.md`) | B, C |
| Claude Code | Redacción de los notebooks `00_preparacion_datos`, `Parte_B_reproduccion`, `Parte_C_gap` y `00R_referencia_autor`, según las decisiones de diseño tomadas por el estudiante (lenguaje, alcance, rejilla reducida, algoritmos excluidos, formato solo notebooks) | B, C |
| Claude Code | Búsqueda y verificación de referencias bibliográficas para la Parte C | C |
| Claude Code | Redacción de `README.md`, `docs/supuestos_y_validaciones.md` y `docs/reproduccion_paper.md` | B |
| Claude Code | Diseño experimental de la Parte D a partir de las decisiones del estudiante (alcance, partición repetida, hiperparámetros fijos, intervalos conformales, criterios de aceptación), redacción de `docs/parte_D_diseno.md` y del notebook `Parte_D_nuevo_trabajo` | D |
| Claude Code | Instalación de R y paquetes (incl. `tune` 1.3.0 en biblioteca separada), ejecución del código R original del autor como referencia y comparación de resultados R / Python / paper | B, C |

**Verificaciones hechas por el estudiante** (completar):
- [ ] Revisé y puedo explicar cada celda de los notebooks.
- [ ] Verifiqué que las referencias citadas existen y dicen lo que se afirma.
- [ ] Revisé las decisiones de `docs/supuestos_y_validaciones.md`.
