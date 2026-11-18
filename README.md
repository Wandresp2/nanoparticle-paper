# Reproducción y extensión de *MicrofluidicML* con Machine Learning clásico

Parcial de **Minería de datos**: reproducción (Parte B), identificación de un gap (Parte C) y nuevo trabajo (Parte D) a partir de:

> Moore, T. L.; Pesce, C.; Greco, A.; Pisante, C.; Avancini, G.; Di Francesco, V.; Shamay, Y.; Decuzzi, P. *Unleashing the Power of Machine Learning in Nanomedicine Formulation Development.* **Adv. Funct. Mater.** 2026, 36, e14387. https://doi.org/10.1002/adfm.202514387

**Pregunta del paper:** ¿se puede predecir el tamaño (dH), la polidispersidad (PdI) y la eficiencia de encapsulación (EE) de nanopartículas (LNP, liposomas y PLGA) fabricadas por microfluídica a partir de los parámetros de fabricación, con ML clásico?

**Gap propuesto:** el paper valida separando entrenamiento y prueba **por medición**, aunque cada receta se midió 3 veces. ¿El modelo realmente predice **recetas que nunca vio**?

---

## Estructura

```
notebooks/
  00_preparacion_datos.ipynb     Emulación de prep_main()/ml_prep() del autor → datos_procesados/
  00R_referencia_autor.ipynb     (kernel R) Corre el código original del autor como referencia
  Parte_B_reproduccion.ipynb     Reproducción: Tabla 2 (Random Forest) y Tablas S1/S2 (algoritmos)
  Parte_C_gap.ipynb              Gap: evidencia cuantitativa, relevancia, viabilidad e hipótesis
  Parte_D_nuevo_trabajo.ipynb    Nuevo trabajo: partición por medición vs por receta (100 repeticiones), error vs ruido, intervalos de incertidumbre
datos_procesados/                (generada, no se versiona) Tablas listas para modelar, creadas por 00
resultados/                      (generada, no se versiona) Salidas de los notebooks
  parte_B/                       Tablas (CSV) y figuras (PNG) de la reproducción
  parte_C/                       Tablas y figuras de la evidencia del gap
  parte_D/                       Repeticiones, pruebas de hipótesis, tablas y figuras del nuevo trabajo
  referencia_R/                  Salidas de la corrida R del autor (solo si se ejecuta 00R)
docs/
  estado_proyecto.md             Estado del parcial, decisiones, entorno técnico y pendientes (empezar aquí)
  parte_D_diseno.md              Diseño de la Parte D registrado antes de ejecutar: hipótesis, criterios de decisión y controles
  reproduccion_paper.md          Qué se reprodujo, qué se simplificó y por qué, y qué se gana al correr R
  supuestos_y_validaciones.md    Decisiones, desviaciones respecto al autor y validaciones pendientes
  anexo_uso_IA.md                Declaración de uso de herramientas de IA (exigida por las normas)
recursos/                        Datos y código R compartidos por el autor (ver "Datos")
contexto/                        Paper, material suplementario e instrucciones del parcial
presentacion/                    Scripts de las diapositivas (pptxgenjs); los .pptx se generan con Node
Analisis_datos_y_codigo_R.md     Análisis de los datos y de cómo los manipula el código R
Explicacion_paper_MicrofluidicML.md   Explicación del paper
```

Todo el desarrollo está en **notebooks de Jupyter**. Los supuestos se documentan en `docs/` y no dentro de los notebooks.

## Repositorio: qué se versiona y qué se genera

El repositorio contiene **solo lo necesario para reproducir el proyecto**: notebooks, datos y código del autor, documentación y scripts. **No contiene nada que se genere al ejecutar:**

| No se versiona | Cómo se obtiene |
|---|---|
| `datos_procesados/` | Ejecutar `00_preparacion_datos.ipynb` |
| `resultados/` (tablas, figuras y la corrida R) | Ejecutar los notebooks en orden (sección "Ejecución") |
| Salidas dentro de los notebooks (tablas y figuras) | Se borran al hacer commit. Aparecen al ejecutar los notebooks |
| `presentacion/*.pptx` | En `presentacion/`: `npm install`, luego `node build_pptx.js` (Parte A) y `node build_esquema.js` (esquema de sustentación) |

**Filtro de notebooks.** El archivo `.gitattributes` aplica el filtro `nbstrip`, que borra las salidas de los `.ipynb` **solo en la copia que se guarda en git**; el archivo local no cambia. Para activarlo después de clonar (desde la raíz, con el `.venv` creado):

```bash
git config filter.nbstrip.clean '".venv/Scripts/jupyter" nbconvert --ClearOutputPreprocessor.enabled=True --to=notebook --stdin --stdout --log-level=ERROR'
git config filter.nbstrip.smudge cat
git config filter.nbstrip.required false
```

En Linux o macOS, cambiar `.venv/Scripts/jupyter` por `.venv/bin/jupyter`. Sin el filtro, git guarda los notebooks tal como están, con sus salidas.

## Datos

Los datos **no son públicos**. El paper indica *"available upon reasonable request"*. El autor de correspondencia (Thomas L. Moore, Università di Napoli Federico II) compartió a petición la base de datos y el código R, que están en `recursos/`:

| Archivo | Contenido |
|---|---|
| `recursos/data/mfNP_database.csv` | 567 mediciones (189 formulaciones × 3 réplicas): receta + dH, PdI, potencial zeta y EE |
| `recursos/data/df_summary.csv` | Promedios por formulación (generado por el código del autor) |
| `recursos/data/data_genAI_v_mfNP.csv` | Validación experimental frente a LLMs (no se usa en B/C) |
| `recursos/01_mfNP.R` … `08_Figures.R`, `recursos/extra/functions.R` | Código R original del autor |

Este repositorio es **privado** porque redistribuye esos materiales. Quien no tenga acceso debe solicitarlos al autor y copiarlos en `recursos/` con la misma estructura.

## Instalación

### Python (obligatorio)

Requiere Python 3.14 (probado en Windows 11).

```bash
python -m venv .venv
# Windows:
.venv\Scripts\activate
# Linux / macOS:
source .venv/bin/activate
pip install -r requirements.txt
```

### R (opcional: solo para la corrida de referencia del autor)

Para qué sirve, qué se gana y cuánto tarda: ver `docs/reproduccion_paper.md`, sección 3.

1. **Instalar R** (≥ 4.3). Hay dos opciones:
   - en PowerShell: `winget install RProject.R`;
   - o descargar el instalador desde <https://cran.r-project.org/bin/windows/base/> y ejecutarlo con las opciones por defecto.

   No hace falta Rtools: los paquetes vienen compilados para Windows.
2. **Abrir R desde el entorno del proyecto.** Así el kernel de R queda registrado en el Jupyter del `.venv`. Desde la carpeta del proyecto:
   ```powershell
   .venv\Scripts\activate
   & "C:\Program Files\R\R-4.x.x\bin\R.exe"   # reemplazar 4.x.x por la versión instalada
   ```
   Normalmente el instalador no agrega R al PATH; por eso se usa la ruta completa.
3. **Dentro de R**, instalar los paquetes del autor y el kernel de Jupyter. Tarda unos 10–20 min; la primera vez R pide elegir un *mirror* de CRAN, y cualquiera sirve.
   ```r
   install.packages(c("IRkernel", "tidymodels", "baguette", "earth", "nnet", "doParallel", "glmnet",
                      "kernlab", "kknn", "rpart", "randomForest", "probably", "poissonreg", "xgboost",
                      "readODS", "readxl", "peakRAM", "viridis", "ggsci", "cowplot", "patchwork",
                      "GGally", "ggfortify", "rgl", "plot3D", "xtable", "kernelshap", "shapviz"))
   IRkernel::installspec()
   ```
4. **Instalar `tune` 1.3.0 y `tidymodels` 1.3.0 en una biblioteca aparte.** El código del autor usa `foreach`, que `tune` 2.x ya no admite (ver `docs/reproduccion_paper.md` §3.6). Siguiendo dentro de R:
   ```r
   lib13 <- file.path(Sys.getenv("LOCALAPPDATA"), "R", "lib-tune-1.3.0")
   dir.create(lib13, recursive = TRUE)
   install.packages(c("doFuture", "GPfit"), lib = lib13)
   install.packages("https://cloud.r-project.org/src/contrib/Archive/tune/tune_1.3.0.tar.gz",
                    lib = lib13, repos = NULL, type = "source")
   install.packages("https://cloud.r-project.org/src/contrib/Archive/tidymodels/tidymodels_1.3.0.tar.gz",
                    lib = lib13, repos = NULL, type = "source")
   q()
   ```
   Son paquetes de R puro: no necesitan Rtools. El notebook `00R` usa esta biblioteca automáticamente.
5. **Verificar**, con el `.venv` activado: `jupyter kernelspec list` debe mostrar un kernel llamado `ir`.

> ⚠️ **Memoria:** el código del autor usa el 80 % de los núcleos (~10 procesos). El notebook `00R_referencia_autor.ipynb` lo limita a 6 sin modificar los scripts del autor (ver `docs/reproduccion_paper.md`, §3.4).
>
> Si `R_LIBS_USER` no existe, R intenta instalar en `C:\Program Files\R\...`, que requiere permisos de administrador. Para evitarlo, crear la carpeta de usuario antes de instalar: `dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)`.

## Ejecución (en este orden)

```bash
jupyter nbconvert --to notebook --execute --inplace notebooks/00_preparacion_datos.ipynb
jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=-1 notebooks/Parte_B_reproduccion.ipynb
jupyter nbconvert --to notebook --execute --inplace notebooks/Parte_C_gap.ipynb
jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=-1 notebooks/Parte_D_nuevo_trabajo.ipynb
# Opcional (~1 h; requiere R). Después, volver a ejecutar Parte_B_reproduccion.ipynb:
jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=-1 notebooks/00R_referencia_autor.ipynb
```

También se pueden abrir con `jupyter lab` y ejecutar celda por celda.

| Notebook | Tiempo aproximado |
|---|---|
| `00_preparacion_datos` | < 10 s |
| `Parte_B_reproduccion` | ~33 min con `N_JOBS = 6` (medido en un equipo de 12 núcleos y 16 GB de RAM). `N_JOBS` está en la primera celda de código. Cada proceso consume memoria: con otros programas abiertos, 12 procesos agotaron la RAM |
| `Parte_C_gap` | ~2 min |
| `Parte_D_nuevo_trabajo` | ~57 min con `N_JOBS = 6` (experimento principal 44 min, control de hiperparámetros 9 min, sensibilidad 3 min). Necesita las salidas de las Partes B y C |
| `00R_referencia_autor` | ≈ 40 min – 1.5 h estimados con 6 procesos. El autor midió ~17–20 min para la rejilla completa de la Tabla 2 (SI, Tabla S6); detalle en `docs/reproduccion_paper.md` §3.3 |

## Reproducibilidad

- **Semilla:** 1987 (la misma del autor) en todas las particiones, folds, búsquedas aleatorias y modelos. En la Parte D, las 100 particiones repetidas usan las semillas 0–99 (las mismas de la simulación de la Parte C) y los modelos usan 1987.
- **Versiones:** fijadas en `requirements.txt`.
- **Supuestos y diferencias con el autor:** `docs/supuestos_y_validaciones.md`.
- **Resultados de la reproducción, simplificaciones y plan con R:** `docs/reproduccion_paper.md`.
- R y Python usan generadores aleatorios distintos, así que la misma semilla **no** da las mismas filas de prueba que en el paper. Ese efecto se aísla con `00R_referencia_autor.ipynb`.

## Uso de IA

Ver `docs/anexo_uso_IA.md`.
