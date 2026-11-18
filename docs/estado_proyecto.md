# Estado del proyecto y guía para retomarlo

> **Para qué sirve:** reúne en un solo lugar el estado del parcial, las decisiones tomadas, el entorno técnico y los próximos pasos, para poder **retomar el trabajo sin el historial del chat**.
>
> Última actualización: **17-nov-2026** (Parte D completada).

---

## 1. El proyecto en 5 líneas

- **Curso:** Minería de datos. Parcial: reproducir un paper de ML clásico, encontrar un gap y resolverlo con los mismos datos (Partes A–D; instrucciones en `contexto/Instrucciones.pdf`).
- **Paper:** Moore *et al.*, *Unleashing the Power of Machine Learning in Nanomedicine Formulation Development*, Adv. Funct. Mater. 2026, e14387. Usa Random Forest para predecir **tamaño (dH), uniformidad (PdI) y encapsulación (EE)** de nanopartículas (LNP, liposomas y PLGA) fabricadas por microfluídica.
- **Datos:** 189 recetas × 3 réplicas = 567 mediciones. Los compartió el autor junto con su código R (`recursos/`).
- **Gap:** el paper separa entrenamiento y prueba **por medición**. Las réplicas de una misma receta quedan a ambos lados, así que el modelo "ya vio" las recetas de prueba. ¿Predice realmente recetas nuevas?

---

## 2. Mapa de documentos (qué leer para cada cosa)

| Archivo | Contenido |
|---|---|
| `README.md` | Estructura del repositorio, instalación (Python y R), orden de ejecución y tiempos |
| `Explicacion_paper_MicrofluidicML.md` | Explicación del paper: pregunta, métodos, resultados, lectura crítica, gaps posibles |
| `Analisis_datos_y_codigo_R.md` | Qué contienen los CSV, cómo los manipula el código R (`prep_main`, `ml_prep`, particiones) y primera evidencia de la fuga |
| `docs/reproduccion_paper.md` | **Parte B en detalle:** qué se reprodujo, qué se simplificó y por qué, para qué sirvió la corrida R, resultados R vs Python vs paper y variabilidad por partición |
| `docs/supuestos_y_validaciones.md` | Registro técnico de cada decisión y equivalencia R → Python, con su validación (todas cerradas ✅) |
| `docs/anexo_uso_IA.md` | Declaración de uso de IA (exigida por las normas). **El estudiante debe revisarlo antes de entregar** |
| `docs/estado_proyecto.md` | Este documento |
| `notebooks/00_preparacion_datos.ipynb` | Emulación de la limpieza del autor → `datos_procesados/` |
| `notebooks/00R_referencia_autor.ipynb` | Corrida del código R original del autor (kernel R) → `resultados/referencia_R/` |
| `notebooks/Parte_B_reproduccion.ipynb` | Reproducción: Tabla 2 (RF) y Tablas S1/S2 (algoritmos); §7 con el análisis de discrepancias |
| `notebooks/Parte_C_gap.ipynb` | Gap: evidencias, relevancia física, viabilidad, hipótesis H1–H3 y 8 referencias verificadas |
| `docs/parte_D_diseno.md` | **Diseño de la Parte D registrado antes de ejecutar**: decisiones, hipótesis operativas y criterios de aceptación |
| `notebooks/Parte_D_nuevo_trabajo.ipynb` | Nuevo trabajo: 100 particiones por medición vs por receta, experimento controlado de fuga, error vs ruido, intervalos de incertidumbre, controles, veredicto, discusión física y conclusiones (§9–§12) |
| `presentacion/` | Diapositivas de la Parte A (`node build_pptx.js`) y esquema de la sustentación |

---

## 3. Estado por parte

| Parte (peso) | Estado | Dónde |
|---|---|---|
| **A**: Propuesta (10 %) | ✅ Hecha | `presentacion/Parte_A_Propuesta_MicrofluidicML.pptx` |
| **B**: Reproducción (30 %) | ✅ Completa, con corrida de referencia en R y análisis de discrepancias con causas comprobadas | `notebooks/Parte_B_reproduccion.ipynb`, `docs/reproduccion_paper.md` |
| **C**: Gap (15 %) | ✅ Completa: evidencia cuantitativa, literatura e hipótesis | `notebooks/Parte_C_gap.ipynb` |
| **D**: Nuevo trabajo (25 %) | ✅ Completa: diseño registrado, ejecutada (57 min), veredicto, discusión física y conclusiones | `notebooks/Parte_D_nuevo_trabajo.ipynb`, `docs/parte_D_diseno.md`, `resultados/parte_D/` |
| Código reproducible (10 %) | 🟡 Notebooks ejecutables, `requirements.txt`, README y semillas listos. Primer commit hecho (17-nov-2026). **Falta:** vincular y subir el repositorio privado remoto | `README.md`, sección "Repositorio" |
| Informe y sustentación (10 %) | ⏳ **Siguiente paso** | — |

---

## 4. Resultados clave

### 4.1 Parte B: reproducción

- **La preparación de datos es idéntica a la del autor:** se reproduce exactamente su `df_summary.csv` y las tablas `dfML_lipid` (243 × 16) y `dfML_PNP` (324 × 12).
- **La reimplementación en Python es fiel:** con las **mismas filas de prueba que R**, Python da el mismo r² que el código del autor (diferencia de 0.001–0.017).
- **La simplificación no afecta:** ese resultado se obtiene con la rejilla reducida (500 árboles), frente a las 1000 combinaciones del autor.
- **El azar de la partición pesa mucho:** el r² de prueba varía entre 0.14 y 0.49 de ancho (90 % central de 500 particiones simuladas).
- **5 de los 6 valores de la Tabla 2 del paper son explicables por la partición.** El único **anómalo es lípidos · EE (r² = 0.472)**: ninguna de las 500 particiones lo reproduce, ni el propio código del autor (0.951), y contradice su validación cruzada (0.929).
- **Tablas S1/S2:** el código R reproduce el SI (incluidos MARS y MLP). Python reproduce las conclusiones con 11 de 13 algoritmos. Sus diferencias en XGBoost y SVM radial se deben al sorteo de la búsqueda aleatoria.

| r² de prueba | Paper | Código R del autor | Python, partición de R | Python, partición propia |
|---|---|---|---|---|
| Lípidos · dH | 0.922 | 0.834 | 0.839 | 0.817 |
| Lípidos · PdI | 0.787 | 0.869 | 0.868 | 0.856 |
| Lípidos · EE | 0.472 | 0.951 | 0.957 | 0.827 |
| PLGA · dH | 0.964 | 0.945 | 0.944 | 0.957 |
| PLGA · PdI | 0.560 | 0.607 | 0.590 | 0.703 |
| PLGA · EE | 0.984 | 0.976 | 0.977 | 0.992 |

### 4.2 Parte C: gap

- **Fuga:** el **83–100 %** de las filas de prueba tienen su réplica en entrenamiento, tanto en la partición de Python como en la del código del autor. En 500 particiones simuladas, la mediana es del 92–100 %.
- **Memorizador:** sin aprender nada (solo promediando las réplicas vistas) alcanza un r² de 0.72–0.96, igual que el RF. La correlación entre sus predicciones y las del RF es de 0.96–0.997.
- **Ruido:** en dH de lípidos y EE de PLGA, el RMSE del paper queda **por debajo** de la variación entre réplicas.
- **Recetas vistas vs nuevas** (pocas filas, es solo un indicio): en PLGA · dH el RF se equivoca 3.2 veces más en recetas nuevas; en PLGA · EE, al revés.
- **Hipótesis para la Parte D:**
  - **H1:** con partición por receta, el r² baja, sobre todo en PdI y en dH de lípidos.
  - **H2:** en dH y EE de PLGA el error queda cerca del ruido entre réplicas; en PdI, muy por encima.
  - **H3:** los intervalos de incertidumbre (QRF o bootstrap) tienen cobertura cercana a la nominal en dH de PLGA y son más anchos en PdI y en lípidos.

---

## 5. Entorno técnico (lo que hay que saber para volver a ejecutar)

### 5.1 Python
- `.venv/` en la raíz del proyecto (Python 3.14; scikit-learn 1.9.1, xgboost 3.4.1, pandas 3.1.1, numpy 2.5.5). Versiones en `requirements.txt`.
- Kernels de Jupyter disponibles:
  - `python3` (el del `.venv`);
  - `segundo-parcial` (alias del `.venv`);
  - `ir` (R).
- **Memoria:** el equipo tiene 16 GB de RAM.
  - Con 12 procesos en paralelo, la Parte B agotó la memoria y se detuvo.
  - **Usar `N_JOBS = 6`** (primera celda de código de la Parte B). Así nunca bajó de ~1 GB libre.
- El `.venv` está dentro de OneDrive, y la sincronización puede hacer más lentas la instalación y la ejecución.

### 5.2 R (corrida de referencia)
- R 4.6.2 en `C:\Program Files\R\R-4.6.2`. Paquetes en la biblioteca de usuario (`R_LIBS_USER` = `%LOCALAPPDATA%\R\win-library\4.6`).
- **`tune` 1.3.0 y `tidymodels` 1.3.0** en una biblioteca aparte: `%LOCALAPPDATA%\R\lib-tune-1.3.0`. Motivo: `tune` 2.x eliminó el soporte de `foreach` (el código del autor correría en 1 núcleo) y cambió la generación de semillas. El notebook `00R`:
  - pone esa biblioteca primera en `.libPaths()`;
  - **exporta `R_LIBS`**, porque si no, los procesos paralelos cargan otras versiones y todo falla con "All models failed";
  - limita a 6 procesos.
- Problemas encontrados al instalar:
  - descargas que fallaban por tiempo de espera → `options(timeout = 900)`;
  - dependencias que faltaron (`stringi`, `partykit`) → instalarlas aparte.
- En Git Bash, `Rscript -e` con código de varias líneas dio *segmentation fault*. Usar un archivo `.R` o PowerShell.

### 5.3 Ejecución y tiempos medidos

| Notebook | Tiempo | Notas |
|---|---|---|
| `00_preparacion_datos` | < 10 s | Genera `datos_procesados/` |
| `00R_referencia_autor` | 78 min | 01: 6 s · 02: 23.5 min · 03: 38.4 min · 04: 16.1 min (`resultados/referencia_R/tiempos_R.csv`) |
| `Parte_B_reproduccion` | ~33 min sin archivos de R; ~48 min con ellos (agrega la variante "misma partición que R") | `N_JOBS = 6` |
| `Parte_C_gap` | ~2 min | Lee las salidas de la Parte B y las de R |

Orden: `00` → (`00R`) → `Parte_B` → `Parte_C`. Comando: `jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=-1 notebooks/<nombre>.ipynb`.

### 5.4 Cómo se mantienen los notebooks
- **Los notebooks son la fuente de verdad.** Se generaron originalmente con scripts temporales que **no** se conservan. Los cambios se hacen directamente en los `.ipynb` (en Jupyter o con `nbformat`).
- La celda final de la Parte B (§7, análisis de discrepancias) se escribió **después** de ejecutar el notebook. Si se re-ejecuta la Parte B, esa celda de markdown se conserva, pero hay que revisar que sus números sigan siendo válidos.
- `resultados/referencia_R/workdir/` es una copia temporal de `recursos/` que usa la corrida R. Está en `.gitignore`.

---

## 6. Decisiones y preferencias de trabajo del responsable

| Decisión / preferencia | Detalle |
|---|---|
| **Solo notebooks de Jupyter** para todo el código (B, C y D) | Nada de módulos `.py` en el proyecto. La preparación compartida va en `00` y guarda CSV en `datos_procesados/` |
| **Supuestos en `docs/`, no en los notebooks** | `docs/supuestos_y_validaciones.md` |
| **Implementación propia en Python** | El código R del autor es solo de referencia (las normas exigen implementación propia) |
| Alcance de la Parte B | Lípidos y PLGA completos: Tabla 2 + Tablas S1/S2 |
| Rejilla RF reducida (500 árboles) | Validada con R |
| Bagged MARS y bagged MLP no implementados en Python | Validado con R: no cambian las conclusiones |
| La Parte C no incluye un experimento piloto con partición por receta | Eso es la Parte D |
| **Repositorio privado con todo** (datos y código del autor incluidos) | El remoto lo crea el estudiante (no hay `gh` instalado) |
| **El repositorio no contiene nada generado** (17-nov-2026) | `datos_procesados/`, `resultados/` y `presentacion/*.pptx` están en `.gitignore`, pero **se conservan en el disco local**. Los notebooks se suben **sin salidas** con el filtro `nbstrip` (`.gitattributes` + `git config` local; ver README); las copias locales conservan sus salidas |
| **No hacer commits sin pedirlo** | Primer commit hecho a pedido del estudiante (17-nov-2026) |
| **Cuando pide "no edites" → solo explicar** | No tocar archivos |
| Idioma y estilo | Español; explicaciones sencillas y ordenadas |

---

## 7. Parte D: resultados (17-nov-2026)

**Diseño** (decidido por el estudiante y registrado en `docs/parte_D_diseno.md` antes de ejecutar):
- alcance H1 + H2 + H3;
- se predice cada medición;
- 100 particiones 85/15 por esquema (semillas 0–99);
- RF con los hiperparámetros fijos de la Parte B;
- intervalos conformales calibrados por receta, con QRF propio como comparación;
- referencias: regresión lineal y memorizador;
- experimento principal con los datos de la Parte B y sensibilidad de EE aparte.

**Veredicto** (`resultados/parte_D/veredicto_hipotesis.csv`):

| Hipótesis | Veredicto | Dato clave |
|---|---|---|
| H1a · el r² baja con recetas nuevas | 🟡 Parcial | Baja en 6/6 modelos (73–98 % de las repeticiones), pero la *t* corregida de Nadeau-Bengio (muy conservadora) solo da p de Holm < 0.05 en 2/6. Wilcoxon: p < 10⁻⁷ en 6/6 (no era el criterio registrado) |
| H1b · sobre todo PdI y lípidos · dH | ✅ | Caídas: PLGA · PdI −0.33, lípidos · dH −0.12, lípidos · PdI −0.11 |
| H1c · RMSE > ruido | ✅ | 6/6 |
| H1-control · fuga aislada (mismas filas de prueba) | ✅ | Sin las réplicas, el RMSE es 1.27–1.63 veces mayor; 6/6 significativos |
| H2 · PLGA dH/EE cerca del ruido, PdI muy por encima | ❌ | Al revés: PLGA · dH 3.2 veces el ruido; PdI 1.5–1.7 veces (el PdI es muy ruidoso) |
| H3a · cobertura nominal (conformal por receta) | ✅ | 92.7 % en PLGA · dH; 90.5–93.5 % en los 6 modelos |
| H3b · intervalos más anchos en PdI y lípidos | ❌ | El más ancho en relación con el ruido es PLGA · dH (3.7 veces) |
| H3c · calibrar por medición sobreestima la confianza | ✅ | Cobertura de 72–85 % (6/6). El QRF cubre 72–91 % |

**Otros hallazgos:**
- **Control de hiperparámetros** (PLGA · PdI, ajuste anidado por grupos): mejora el r² solo +0.02 (p = 0.45). No explica H1.
- **Regresión lineal ≈ RF con recetas nuevas** en PLGA · dH (r² = 1 − SSE/SST: 0.868 vs 0.871) y en lípidos · EE.
- **Sensibilidad de EE:** en lípidos, con solo los liposomas con curcumina, el r² por receta es 0.11 (1 − SSE/SST ≈ 0). El r² alto se debía a la regla "sin fármaco → EE = 0". PLGA con fármaco mantiene 0.93.
- **Tabla 2 con 100 semillas, ahora con el RF real:** 5 de 6 valores del paper caen en los percentiles 14–77; lípidos · EE (0.472) queda por debajo de las 100 repeticiones.
- **Intervalos al 90 % calibrados por receta:** ±28 nm en el dH de PLGA y ±45 nm en el de lípidos. Es la incertidumbre real para el diseño inverso.

**Notas técnicas:**
- El notebook se generó con un script temporal que no se conserva. Las secciones §9–§12 (interpretación, discusión física, limitaciones y conclusiones) son celdas de texto escritas **después** de ejecutar. Si se re-ejecuta, hay que revisar que sus números sigan valiendo.
- La corrida se lanzó como proceso independiente porque la sesión anterior se cerró a mitad de la ejecución.

## 8. Pendientes

| Pendiente | Prioridad |
|---|---|
| Informe tipo artículo y diapositivas de sustentación (20 min + 5 de preguntas) | **Alta (siguiente paso)** |
| Verificar las referencias nuevas de la Parte D: Karnik 2008, Jahn 2010 y Zhigaltsev 2012 (notebook §12) y Nadeau-Bengio 2003, Meinshausen 2006, Vovk 2005 y Barber 2021 (`docs/parte_D_diseno.md`) | Media |
| Vincular el repositorio privado remoto (GitHub) y hacer `push` | Media; el estudiante da el enlace |
| Revisar y completar `docs/anexo_uso_IA.md` | Antes de entregar |
