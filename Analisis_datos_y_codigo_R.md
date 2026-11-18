# Análisis de los datos y de su manipulación en el código R (MicrofluidicML)

> **Paper:** Moore et al., *Unleashing the Power of Machine Learning in Nanomedicine Formulation Development*, Adv. Funct. Mater. 2026, e14387.
> **Material recibido del autor:** 3 archivos CSV (`recursos/data/`) + 8 scripts R (`recursos/01_…R` a `08_…R`) + funciones auxiliares (`recursos/extra/functions.R`).
> **Alcance de este documento:** entender **qué contienen los datos** y **cómo los transforma el código R** antes de entrenar los modelos. Aquí **no** se analiza el modelado de ML (eso es la Parte B). El objetivo es dejar la base para conectar con el **gap** (sección 8 de `Explicacion_paper_MicrofluidicML.md`) y para desarrollar las Partes B, C y D.

---

## Índice

1. [Mapa general: archivos y orden de ejecución](#1-mapa-general-archivos-y-orden-de-ejecución)
2. [Los datos crudos (CSV) vistos como nanopartículas](#2-los-datos-crudos-csv-vistos-como-nanopartículas)
3. [Calidad de los datos crudos](#3-calidad-de-los-datos-crudos)
4. [Cómo manipula los datos el código R, paso a paso](#4-cómo-manipula-los-datos-el-código-r-paso-a-paso)
5. [Las tablas finales que recibe cada modelo](#5-las-tablas-finales-que-recibe-cada-modelo)
6. [Consecuencias de esa manipulación (lectura crítica)](#6-consecuencias-de-esa-manipulación-lectura-crítica)
7. [Conexión con el gap: evidencia cuantitativa de la fuga por réplicas](#7-conexión-con-el-gap-evidencia-cuantitativa-de-la-fuga-por-réplicas)
8. [Decisiones para las siguientes partes del parcial](#8-decisiones-para-las-siguientes-partes-del-parcial)
9. [Anexo: cómo se obtuvieron los números de este documento](#9-anexo-cómo-se-obtuvieron-los-números-de-este-documento)

---

## 1. Mapa general: archivos y orden de ejecución

### 1.1 Archivos de datos (`recursos/data/`)

Son **CSV**, no `.xlsx`, aunque se abren en Excel.

| Archivo | Filas | Nivel | Qué es | ¿Lo usa el ML? |
|---|---|---|---|---|
| `mfNP_database.csv` | 567 | **Medición** (1 fila = 1 lectura de DLS/UV-Vis) | Base de datos principal: receta + propiedades medidas | **Sí**, es la única entrada de los modelos |
| `df_summary.csv` | 189 | **Formulación** (promedio de 3 réplicas) | Lo **genera** `01_mfNP.R` (`write.csv`) | **No.** Solo se escribe, ningún script lo vuelve a leer |
| `data_genAI_v_mfNP.csv` | 108 | Medición | Validación final: recetas de LLMs vs MicrofluidicML, fabricadas y medidas | Solo en `06_GenAI.R` (gráfica comparativa, sin ML) |

### 1.2 Scripts R y su papel

Los scripts **no son independientes**: comparten variables en la memoria de R y deben correrse en orden, en la misma sesión. Por ejemplo, `04` usa los `train` creados en `02` y `03`.

```
extra/functions.R ──► define prep_main(), ml_prep(), tablas auxiliares (dat_payload, …)
        │                 (lo carga 01 con source())
        ▼
01_mfNP.R ──► lee mfNP_database.csv → limpia (prep_main) → df_summary.csv
        │      → separa lípidos / PLGA → ml_prep() → dfML_lipid, dfML_PNP
        ▼
02_rf_lipid_model.R ─┐  particiones train/test + folds de CV + RF afinado
03_rf_PLGA_model.R  ─┤  (lípidos y PLGA; 3 objetivos cada uno)
        ▼            │
04_AlgScreening.R ◄──┘  reutiliza esas particiones para comparar 13 algoritmos
05_rSHAP.R             SHAP sobre dfML_lipid / dfML_PNP
06_GenAI.R             lee data_genAI_v_mfNP.csv (independiente)
07_modelCompare.R      errores de cada algoritmo (usa objetos de 04)
08_Figures.R           figuras (lee data/df_split.csv, que NO vino en el envío)
```

En este documento solo interesan las partes de **manipulación de datos**: `functions.R` (`prep_main`, `ml_prep`), `01` completo y las primeras líneas de `02`/`03`, donde se arman las particiones.

---

## 2. Los datos crudos (CSV) vistos como nanopartículas

### 2.1 Qué representa cada fila de `mfNP_database.csv`

Cada fila responde a: *"mezclé esta fase orgánica con esta fase acuosa en el chip de microfluídica, a estos caudales, y obtuve partículas con este tamaño, polidispersidad, carga y encapsulación"*.

La física de fondo es la **nanoprecipitación**. El material (lípido o polímero) está disuelto en un solvente orgánico (etanol o acetonitrilo). Al mezclarse rápidamente con agua en el chip, el material deja de ser soluble y se autoensambla en partículas. Los caudales (TFR, FRR) controlan qué tan rápida es esa mezcla y cuánto se diluye el solvente, y eso define el tamaño final.

### 2.2 Diccionario de columnas

**Contexto (igual en todas las filas, así que no aporta información):**

| Columna | Valor | Comentario |
|---|---|---|
| `mfr`, `instr`, `chip` | Precision NanoSystems / NanoAssemblr Benchtop / Benchtop Cartridge | Un solo equipo |
| `commit_id` | 17 valores | Lote o día de experimento + iniciales del operador (p. ej. `20240113231601clapis_ist`) |

**Variables de entrada (X), es decir, la receta:**

| Columna | Significado físico | Unidades |
|---|---|---|
| `class` | Familia: `Lipid-based Nanoparticles` / `Polymeric Nanoparticles` | — |
| `np_type` | `Lipid Nanoparticle` (LNP), `Liposome`, `PLGA Nanoparticle` | — |
| `org_phase` | Solvente orgánico: etanol (lípidos) o acetonitrilo (PLGA) | — |
| `aq_phase` | Buffer: citrato pH 3.6 (LNP), PBS pH 7.4 (liposomas), Tris pH 7.2 (PLGA) | — |
| `tfr` | **Total Flow Rate**, caudal total en el chip | mL/min |
| `frr_aq`, `frr_org`, `frr` | **Flow Rate Ratio** acuoso:orgánico. `frr_org` siempre vale 1, así que `frr = frr_aq` | — |
| `orgReagN_reag` / `orgReagN_conc` (N = 1…6) | Nombre y concentración de cada lípido o polímero en la fase orgánica. Solo se usan N = 1…4 | mM |
| `totOrg_conc` | Concentración total de material. Es exactamente la suma de `orgReagN_conc` | mM |
| `aqReagN_*`, `totAq_conc` | Reactivos en la fase acuosa. **Siempre vacíos o en 0** | mM |
| `payload` | Fármaco encapsulado: **solo curcumina**, o vacío | — |
| `payloadConc_mM` | Concentración de curcumina | mM |

**Variables de salida (y), las propiedades medidas:**

| Columna | Qué mide | Técnica | Rango |
|---|---|---|---|
| `hdiam_nm` | Diámetro hidrodinámico (Z-average) | DLS | 28 – 361 nm |
| `pdi` | Índice de polidispersidad (uniformidad). El código usa ≤ 0.25 como "monodispersa" | DLS | 0.04 – 0.72 |
| `zetaPot_mV` | Potencial zeta (carga superficial). **No se modela en el paper** | ELS | — |
| `percEE` | Eficiencia de encapsulación: % de la curcumina que quedó dentro de la partícula | UV-Vis | 0 – 115 % |

### 2.3 El diseño experimental de cada tipo de partícula

| | **LNP** | **Liposoma** | **PLGA** |
|---|---|---|---|
| Material (proporción molar) | Colesterol : DODAP : DSPC : DSPE-PEG2k = 38.5 : 50 : 10 : 1.5 | Colesterol : DPPC : DSPE-PEG2k = 30 : 60 : 10 | Resomer RG 504 H (PLGA 50:50) |
| Solvente / buffer | Etanol / citrato pH 3.6 | Etanol / PBS pH 7.4 | Acetonitrilo / Tris pH 7.2 |
| TFR (mL/min) | 2, 4, 8 | 1, 4, 8 | **3**, 6, 13 |
| FRR | 1, 3, 5 | 3, 6, 9 | 3, 4, 5 |
| Concentración total | 20, 40, 60 mM | 12.0, 24.0, 47.9 mM (≈ 10, 20, 40 mg/mL)† | 0.109, 0.217, 0.435 mM (≈ 5, 10, 20 mg/mL)† |
| Curcumina | **Nunca** | Vacíos + 3 dosis (0.136, 0.543, 1.086 mM ≈ 0.05, 0.2, 0.4 mg/mL†), **cruzadas** con la concentración de lípido | Vacías + 3 **proporciones fármaco:polímero** fijas (≈ 1.7, 2.5 y 5 % en masa†) |
| Formulaciones | 27 | 27 vacías + 27 con curcumina = 54 | 27 vacías + 81 con curcumina = 108 |
| Mediciones (×3 réplicas) | **81** | **162** | **324** |

† Conversión a mg/mL hecha por mí con los pesos moleculares (curcumina 368.4 g/mol; PLGA ≈ 46 kDa, dentro del rango 38–54 kDa del fabricante). Cuadra con números redondos: 0.1357 mM × 368.4 = 0.050 mg/mL.

**Observaciones clave del diseño:**

1. **Cada grupo es un factorial completo 3 × 3 × 3** (TFR × FRR × concentración). Solo hay 3 niveles por variable.
2. **La proporción entre lípidos nunca cambia** dentro de un tipo de partícula. Solo cambia la concentración total. Las columnas de cada lípido son, por tanto, **múltiplos exactos** unas de otras (correlación = 1).
3. **Total: 189 formulaciones × 3 réplicas = 567 mediciones.** Cada formulación tiene exactamente 3 filas.
4. **Una inconsistencia del paper queda resuelta:** el TFR de PLGA en los datos es **3, 6, 13** (los Métodos decían 4).
5. **Los lotes coinciden con bloques del diseño.** Por ejemplo, las 81 mediciones de liposomas vacíos vienen de un solo `commit_id`, y las de liposomas con curcumina de otro. El tipo de partícula y la presencia de fármaco están confundidos con el día y el operador.

### 2.4 Tendencias físicas visibles en los datos crudos

Correlaciones de Spearman sobre las 567 filas, por tipo de partícula. Coinciden con lo que explica el paper:

| Tipo | Relación | ρ | Lectura física |
|---|---|---|---|
| PLGA | concentración de PLGA → dH | **+0.90** | Más polímero → más material por núcleo → partículas más grandes |
| PLGA | concentración de curcumina → EE | **+0.84** | Muy ligado a la proporción fármaco:polímero |
| Liposoma | TFR → dH | **−0.63** | Mezcla más rápida → partículas más pequeñas |
| Liposoma | TFR → PdI | **+0.66** | …pero menos uniformes |
| Liposoma | concentración de curcumina → EE | **+0.83** | — |
| LNP | FRR → dH | **−0.43** | Más dilución del etanol → partículas más pequeñas |

---

## 3. Calidad de los datos crudos

| # | Problema | Dónde | Efecto en el código del autor |
|---|---|---|---|
| 1 | **Potencial zeta imposible: −7137 mV** (probablemente −71.37) | Fila 365 (PLGA, TFR 6, FRR 4) | Ninguno, porque el zeta nunca es objetivo ni predictor |
| 2 | **EE > 100 %** (hasta 115.4 %) | 9 filas de liposomas con curcumina | Se usan tal cual en el modelo de EE de lípidos |
| 3 | **EE sin sentido en LNP**: 45 filas con `NA` y 36 con 0 | LNP (nunca llevan fármaco) | Se convierten todas a EE = 0 y **entran al modelo de EE** (ver §6.5) |
| 4 | **Réplicas muy dispersas** (p. ej. 36 / 313 / 28 nm) | Pocas formulaciones, sobre todo liposomas vacíos con TFR alto y una LNP | Se usan tal cual. Inflan el "ruido" de la DLS |
| 5 | **Mismo valor con distinto redondeo** (0.1357220412595 vs 0.135722041259501 mM) | Curcumina en liposomas | Inocuo en la práctica, pero cuidado al agrupar con `==` |
| 6 | `+AC0` en el texto | `data_genAI_v_mfNP.csv` | Es un "-" mal codificado (UTF-7). `06_GenAI.R` lo limpia con `gsub` |
| 7 | Falta `data/df_split.csv` | Lo lee `08_Figures.R` | Esa figura (efecto del % de entrenamiento) no se puede regenerar |

**Ruido experimental entre réplicas** (desviación estándar dentro de cada formulación). Es el "piso" de error que ningún modelo puede bajar:

| | dH: SD mediana | dH: SD agrupada* | PdI: SD mediana | EE: SD mediana |
|---|---|---|---|---|
| Lípidos | 3.2 nm | 10.8 nm | 0.020 | ≈ 0 % |
| PLGA | 1.6 nm | 4.6 nm | 0.022 | 0.6 % |

\* La SD agrupada (raíz del promedio de las varianzas) pesa mucho los triplicados extremos. La mediana describe la formulación típica. Ambas sirven: la agrupada es la comparable con un RMSE.

Si un modelo predijera **perfectamente el promedio de cada formulación**, explicaría como máximo esta parte de la variación entre mediciones (el resto es ruido de réplica):

| | dH | PdI | EE |
|---|---|---|---|
| Techo de r² (todas las partículas) | 0.90 | 0.88 | 0.99 |

---

## 4. Cómo manipula los datos el código R, paso a paso

### Paso 0 — Lectura (`01_mfNP.R`, línea 46)

```r
df_main <- read.csv("data/mfNP_database.csv")
```

Se leen las 567 filas tal cual. También se fijan constantes que afectan los datos:

| Constante | Valor | Para qué |
|---|---|---|
| `seed` | 1987 | Semilla de todas las particiones |
| `pdi_lim` | 0.250 | Umbral monodispersa / polidispersa y **filtro de los modelos de diámetro** |
| `trainPerc` | 0.85 | 85 % entrenamiento / 15 % prueba |
| `vfolds` | 10 | 10-fold CV dentro del entrenamiento |

### Paso 1 — `prep_main()` (`extra/functions.R`, líneas 83–158): limpieza general

| Acción | Código | Efecto real en estos datos |
|---|---|---|
| Convierte 19 columnas a numéricas | `as.numeric(as.character(x))` | Ya eran numéricas. Sin efecto |
| Unifica nombres de `np_type` (`"Liposomes"` → `"Liposome"`, etc.) | `x[which(x$np_type == …)]` | Ya venían unificados. Sin efecto (el código es genérico para una base mayor) |
| **Reemplaza todos los 0 y los textos vacíos por `NA`** | `x[x == 0] <- NA` | `totAq_conc`: 567 → NA; `payloadConc_mM`: 198 → NA; `percEE`: 198 → NA. Ahora **todas** las partículas vacías tienen EE = `NA` |
| Crea columnas de texto `orgReagents`, `aqReagents`, `orgRatios`, `aqRatios` | `paste(...)` | Descriptivas. No llegan al ML |
| Crea un **identificador de formulación** `id` (tipo + fases + TFR + FRR + reactivos + fármaco) | `x$id <- paste0(...)` | **Es la columna que permitiría agrupar réplicas.** No llega al ML (ver Paso 4) |

Después, en `01_mfNP.R`:

```r
df$dispersity <- ifelse(df$pdi <= pdi_lim, "monodisperse", "polydisperse")
```

Esto etiqueta cada medición. Un 33 % de las mediciones (190/567) tiene PdI > 0.25.

### Paso 2 — Resumen por formulación → `df_summary.csv` (`01_mfNP.R`, líneas 80–139)

- Agrupa por **todas las columnas de la receta** (tipo, TFR, FRR, fases, reactivos, fármaco) y calcula media y SD de dH, PdI y EE.
  - Resultado: **189 filas**, una por formulación. Confirma que hay exactamente 3 réplicas por formulación.
- `mean(percEE)` se calcula **sin** `na.rm = TRUE`. Como en el Paso 1 los 0 se volvieron `NA`, `meanEE = NA` en las 81 formulaciones vacías (27 por tipo).
- Etiqueta `dispersity` según el PdI **medio**: 126 monodispersas / 63 polidispersas.
- Construye otro `id` (texto con toda la receta) y escribe el CSV.
- **Este resumen se usa solo para describir los datos y para gráficas 3D. Ningún modelo se entrena con él.**

### Paso 3 — Separación por familia (`01_mfNP.R`, líneas 142–143)

```r
dfLipid <- df[which(df$class == "Lipid-based Nanoparticles"), ]   # 243 filas: LNP + liposomas JUNTOS
dfPNP   <- df[which(df$class == "Polymeric Nanoparticles"),]      # 324 filas: PLGA
```

LNP y liposomas se modelan **juntos**: un solo modelo "lípidos" para dos arquitecturas distintas.

### Paso 4 — `ml_prep()` (`extra/functions.R`, líneas 238–388): la tabla para ML

Es la transformación más importante. Se aplica a `dfLipid` y a `dfPNP`.

| # | Acción | Detalle |
|---|---|---|
| 4.1 | `NA → 0` en todo el data frame | Deshace el Paso 1: el "vacío" vuelve a ser 0. Así, **0 significa a la vez** "reactivo ausente", "sin fármaco" y "EE no aplica" |
| 4.2 | **Nueva variable** `reag_payload_ratio = (totOrg_conc + totAq_conc) / payloadConc_mM` | Relación material:fármaco. En las partículas vacías da división por 0 (`Inf`) y **se reemplaza por 0** |
| 4.3 | **Descriptores del fármaco** `payloadMW`, `XlogP3`, `polarSA` | Se buscan en la tabla `dat_payload` (PubChem, 11 fármacos). Curcumina: 368.4 g/mol, 3.2, 93.1 Å². Sin fármaco: 0 |
| 4.4 | **Selección de columnas** | Se conservan solo: reactivos y sus concentraciones, `tfr`, `frr`, `payload`, `reag_payload_ratio`, los 3 descriptores y los 4 objetivos. **Se descartan**: `np_type`, `class`, `org_phase`, `aq_phase`, `totOrg_conc`, `payloadConc_mM`, `commit_id`, `id`, `dispersity` |
| 4.5 | **Pivot de reactivos: "una columna por reactivo"** | Los pares `orgReagN_reag`/`orgReagN_conc` se pasan a formato largo, se suman por nombre de reactivo y se vuelven a formato ancho. Resultado: columnas `Cholesterol`, `DODAP`, `DPPC`, `DSPC`, `DSPE-PEG2k` (lípidos) o `Resomer RG 504 H` (PLGA), con la concentración en mM o 0 si el reactivo no está. Se elimina la columna `"0"` de los huecos vacíos |
| 4.6 | Reactivos acuosos | Como todos son 0, la tabla acuosa queda vacía y se descarta |
| 4.7 | `NA → 0` otra vez y limpieza de nombres | Espacios, `-`, `:` y paréntesis se cambian por `.` (p. ej. `DSPE.PEG2k`, `Resomer.RG.504.H`) |

> **Punto crítico para el gap:** el identificador de formulación (`id`) que se construyó en el Paso 1 **se pierde en el Paso 4.4**. A partir de aquí no queda ninguna columna que diga "estas 3 filas son réplicas de la misma receta". Por eso las particiones siguientes no pueden respetar los grupos, aunque se quisiera. (Sí se pueden reconstruir: las réplicas tienen **todas las X idénticas**. Verifiqué que hay exactamente 81 combinaciones únicas de X en lípidos y 108 en PLGA.)

### Paso 5 — Subconjuntos y particiones por objetivo (`02` lípidos y `03` PLGA)

Para cada uno de los 6 modelos (2 familias × 3 objetivos):

```r
# Ejemplo: diámetro de lípidos (02_rf_lipid_model.R, líneas 82–89)
diam_split_lipid <- initial_split(dfML_lipid[which(dfML_lipid$pdi <= pdi_lim),],
                                  prop = trainPerc, strata = hdiam_nm)
dfDiam_lipid_train <- training(diam_split_lipid)
dfDiam_lipid_test  <- testing(diam_split_lipid)
diam_folds_lipid   <- vfold_cv(dfDiam_lipid_train, v = vfolds)
```

| Acción | Qué hace | Comentario |
|---|---|---|
| **Filtro PdI ≤ 0.25 solo en los modelos de diámetro** | Quita las mediciones polidispersas | El filtro es **por medición, no por formulación** (ver §6.6) |
| `initial_split(..., prop = 0.85, strata = <objetivo>)` | Partición aleatoria **por fila** 85/15, estratificada por cuartiles del objetivo | **No agrupa réplicas** → fuga (ver §7) |
| `vfold_cv(train, v = 10)` | 10 folds aleatorios **por fila** | Mismo problema dentro de la CV |
| **Cada objetivo tiene su propia partición** | Las filas de prueba de PdI, dH y EE son distintas | Las métricas de los 3 objetivos no se calculan sobre el mismo conjunto de prueba |
| `subset(select = -c(payload, <otros objetivos>, zetaPot_mV))` | Quita del modelo el nombre del fármaco y los demás objetivos | Bien: no se usan otras propiedades medidas como predictores |
| `step_zv(all_predictors())` | Quita columnas de varianza cero | En PLGA no hay ninguna |
| `step_normalize(all_numeric_predictors())` | Estandariza (media 0, SD 1) | Se estima **dentro de cada fold** (lo hace la *recipe*). Buena práctica: el escalado no filtra información |

### Paso 6 — Uso de los datos en los demás scripts (solo lo relevante a datos)

- **`04_AlgScreening.R`** reutiliza **las mismas** particiones y folds de `02`/`03` para los 13 algoritmos. La comparación de algoritmos hereda la misma fuga.
  - Detalle de código: la *recipe* de EE de lípidos se arma con `varPdI_lipid_train` (el train de PdI) en vez del de EE. Es **inocuo**: la recipe solo usa ese data frame para saber los nombres y roles de las columnas, y el ajuste se hace en `ee_folds_lipid`.
- **`05_rSHAP.R`** calcula SHAP sobre `dfML_lipid` / `dfML_PNP` **completos** (train + test, 243 y 324 filas).
- **`06_GenAI.R`** limpia `+AC0`, renombra algoritmos y promedia diámetro y PdI por algoritmo.
- **`07_modelCompare.R`** (para la Parte B, no es manipulación): los errores de PdI se calculan prediciendo sobre `dfDiam_lipid_train`, es decir, sobre filas de **entrenamiento** de otra partición. Habrá que revisarlo al reproducir la Fig. 4.
- **`02`/`03`** calculan r² como `summary(lm(y ~ pred))$r.squared` (correlación al cuadrado), **no** como 1 − SSE/SST. También es para la Parte B, pero explica por qué los r² del paper pueden no coincidir con los de `sklearn.metrics.r2_score`.

---

## 5. Las tablas finales que recibe cada modelo

### 5.1 `dfML_lipid` (243 × 16)

| Grupo | Columnas |
|---|---|
| Composición (mM) | `Cholesterol`, `DODAP`, `DPPC`, `DSPC`, `DSPE.PEG2k` |
| Proceso | `tfr`, `frr` |
| Fármaco | `reag_payload_ratio`, `payloadMW`, `XlogP3`, `polarSA` (+ `payload`, que se excluye al modelar) |
| Objetivos | `hdiam_nm`, `pdi`, `percEE` (+ `zetaPot_mV`, excluido) |

Ejemplo de 3 filas (liposomas vacíos, TFR 1, FRR 3, las tres concentraciones):

| Cholesterol | DODAP | DPPC | DSPC | DSPE.PEG2k | tfr | frr | ratio | MW | XlogP3 | polarSA | dH | PdI | EE |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 3.59 | 0 | 7.19 | 0 | 1.20 | 1 | 3 | 0 | 0 | 0 | 0 | 84.6 | 0.201 | 0 |
| 7.19 | 0 | 14.38 | 0 | 2.40 | 1 | 3 | 0 | 0 | 0 | 0 | 100.8 | 0.130 | 0 |
| 14.38 | 0 | 28.76 | 0 | 4.79 | 1 | 3 | 0 | 0 | 0 | 0 | 153.4 | 0.153 | 0 |

### 5.2 `dfML_PNP` (324 × 12)

| Grupo | Columnas |
|---|---|
| Composición (mM) | `Resomer.RG.504.H` |
| Proceso | `tfr`, `frr` |
| Fármaco | `reag_payload_ratio` (0, 0.16, 0.32, 0.48), `payloadMW`, `XlogP3`, `polarSA` |
| Objetivos | `hdiam_nm`, `pdi`, `percEE` |

### 5.3 Los 6 conjuntos de modelado

| Modelo | Filas usadas | Filtro | Train / test (≈ 85/15) | Particularidad |
|---|---|---|---|---|
| Lípidos – dH | 150 de 243 | PdI ≤ 0.25 | ≈ 127 / 23 | 23 formulaciones pierden **todas** sus réplicas y 16 pierden **algunas** |
| Lípidos – PdI | 243 | — | ≈ 206 / 37 | — |
| Lípidos – EE | 243 | — | ≈ 206 / 37 | **162 de 243 (67 %) tienen EE = 0** (81 LNP + 81 liposomas vacíos) |
| PLGA – dH | 227 de 324 | PdI ≤ 0.25 | ≈ 193 / 34 | 21 formulaciones pierden todas sus réplicas y 23 pierden algunas |
| PLGA – PdI | 324 | — | ≈ 275 / 49 | — |
| PLGA – EE | 324 | — | ≈ 275 / 49 | 81 de 324 (25 %) tienen EE = 0 (PLGA vacías) |

---

## 6. Consecuencias de esa manipulación (lectura crítica)

### 6.1 Se pierde la estructura de réplicas → fuga de información

El `id` de formulación existe en `prep_main`, pero `ml_prep` lo descarta. Las particiones `initial_split` y `vfold_cv` trabajan **por fila**. Las 3 réplicas de una receta (mismas X, y casi iguales) pueden caer unas en train y otras en test. **Es el gap principal.** Se cuantifica en la sección 7.

### 6.2 El tipo de partícula no es una variable explícita

`np_type` se descarta. El modelo de lípidos distingue LNP de liposomas solo **de forma implícita**, por qué columnas de lípidos son distintas de 0 (`DODAP`/`DSPC` > 0 → LNP; `DPPC` > 0 → liposoma). Tampoco entran el solvente, el buffer ni el pH, pero dentro de cada familia son constantes por tipo, así que van "codificados" en lo mismo.

### 6.3 Las columnas de composición son colineales

Como la proporción entre lípidos es fija:
- En LNP: `Cholesterol` = 0.77 × `DODAP` = 3.85 × `DSPC` = …
- En liposomas: `Cholesterol` = 0.5 × `DPPC` = 3 × `DSPE.PEG2k`.

Cada columna de lípido es, en realidad, **la concentración total multiplicada por una constante**. Consecuencia para el SHAP del paper: "el colesterol es la variable más importante para el tamaño" debe leerse como **"la concentración total de lípido es la más importante"**. El colesterol es simplemente la única columna presente en ambos tipos de partícula, así que acumula la importancia que comparten las demás.

### 6.4 El 0 se usa con tres significados

| El 0 significa… | Dónde |
|---|---|
| "Este reactivo no está en la receta" | Columnas de lípidos |
| "No hay fármaco" | `reag_payload_ratio`, `payloadMW`, `XlogP3`, `polarSA` |
| "La EE no aplica" (no había nada que encapsular) | `percEE` |

Problemas concretos:
- **`reag_payload_ratio` no es monótona.** Más material por fármaco → ratio mayor, pero "sin fármaco" (que sería ratio infinito) se codifica como **0**, el extremo opuesto. Los árboles pueden manejarlo; los modelos lineales, kNN y SVM no.
- **Los 3 descriptores del fármaco son el mismo interruptor 0/1** repetido 3 veces (solo hay curcumina). No aportan información química, solo dicen "tiene curcumina / no tiene". Por eso `XlogP3` aparece "importante" en el SHAP de EE.
- `payloadConc_mM` no entra directamente, pero se puede reconstruir como concentración del material / ratio.

### 6.5 El objetivo EE mezcla dos problemas distintos

En el modelo de EE de lípidos, **el 67 % de las filas son EE = 0**, y 81 de ellas son LNP, que **nunca** tuvieron fármaco. El modelo tiene que aprender dos cosas:
1. "¿Hay fármaco?" Es trivial con el interruptor de §6.4.
2. "¿Cuánto se encapsula?" Es lo interesante, pero solo hay 81 filas (los liposomas con curcumina).

Esto ayuda a explicar los resultados raros del paper en EE de lípidos (r² de CV 0.929 vs r² de test 0.472): el r² depende mucho de cuántos ceros caen en cada partición. Lo mismo, aún más marcado, en el modelo agnóstico (Tabla S3), que mezcla además PLGA.

### 6.6 El filtro de PdI rompe triplicados

En los modelos de diámetro se filtra PdI ≤ 0.25 **por medición**:

| | Formulaciones con 3/3 réplicas | 2/3 | 1/3 | 0/3 (eliminadas) |
|---|---|---|---|---|
| Lípidos (81) | 42 | 8 | 8 | 23 |
| PLGA (108) | 64 | 12 | 11 | 21 |

- Se quedan las réplicas "buenas" de formulaciones dudosas. Esto es un **sesgo de selección**: el dH de esas formulaciones parece más reproducible de lo que es.
- El modelo de dH no puede predecir nada para el **28 % (lípidos) y 19 % (PLGA)** de las recetas que no dejan ninguna réplica.
- Desde el punto de vista físico el filtro tiene sentido: el Z-average de la DLS no es confiable en muestras polidispersas. Pero sería más coherente filtrar **por formulación** (con el PdI medio).

### 6.7 Lo que el código hace bien

- El escalado (`step_normalize`) se estima dentro de cada fold, sin fuga.
- No se usan otras propiedades medidas (zeta, PdI…) como predictores de un objetivo.
- Semilla fija (1987) en todas las particiones.
- La partición estratificada por cuartiles del objetivo mantiene la distribución de y en train y test.

---

## 7. Conexión con el gap: evidencia cuantitativa de la fuga por réplicas

> **Nota (actualización):** las cifras de esta sección vienen de una simulación exploratoria preliminar. **Las cifras definitivas y reproducibles** están en `notebooks/Parte_C_gap.ipynb` (`resultados/parte_C/`):
> - las medianas en 500 particiones son del 92–100 % de las filas de prueba con réplica en entrenamiento;
> - el memorizador alcanza r² de 0.72–0.96 en la partición de la Parte B.
>
> Las conclusiones no cambian.

### 7.1 ¿Cuántas filas de prueba tienen una "hermana" en entrenamiento?

Simulé 500 veces la misma partición del autor (85/15 por fila, estratificada por cuartiles del objetivo) sobre las tablas `dfML_*`, identificando cada formulación por sus X:

| Modelo | % filas de test con ≥ 1 réplica de su formulación en train | % formulaciones de test **totalmente nuevas** |
|---|---|---|
| Lípidos – dH | 91.9 % | 7.2 % |
| Lípidos – PdI | 97.9 % | 0.9 % |
| Lípidos – EE | 97.8 % | 0.9 % |
| PLGA – dH | 91.5 % | 7.4 % |
| PLGA – PdI | 98.1 % | 0.8 % |
| PLGA – EE | 97.6 % | 1.0 % |
| 10-fold CV (dentro del train) | **99–100 %** de las filas de validación | ≈ 0 % |

**Lectura:** el "test" del paper casi nunca contiene una receta que el modelo no haya visto. Mide **qué tan bien se reproduce una medición de una receta conocida**, no **qué tan bien se predice una receta nueva**, que es lo que importa para diseñar formulaciones.

### 7.2 Un "modelo" sin ML ya alcanza los números del paper

El "memorizador" no aprende nada: para cada fila de test, predice **el promedio de las réplicas de esa misma formulación que quedaron en train**. Su desempeño, comparado con el Random Forest del paper (Tabla 2):

| Modelo | r² memorizador | r² RF paper (test) | RMSE memorizador | RMSE RF paper (test) |
|---|---|---|---|---|
| Lípidos – dH | 0.896 | 0.922 | 13.7 nm | 9.5 nm |
| Lípidos – PdI | **0.774** | **0.787** | 0.062 | 0.053 |
| Lípidos – EE | 0.941 | 0.472 (CV: 0.929) | 9.1 % | 10.6 % (CV: 9.8 %) |
| PLGA – dH | **0.978** | **0.964** | 5.6 nm | 7.5 nm |
| PLGA – PdI | **0.605** | **0.560** | 0.052 | 0.047 |
| PLGA – EE | **0.991** | **0.984** | 3.4 % | 2.2 % |

(Métricas del memorizador sobre las filas de test con réplica en train, mediana de 500 particiones. r² calculado como 1 − SSE/SST.)

**Interpretación:**
- En **PLGA** y en **PdI de lípidos**, una simple tabla de consulta de réplicas iguala o supera al RF publicado. El RF afinado del paper (min_n = 2, mtry = todas las variables) se comporta de hecho casi como un memorizador: árboles muy profundos que separan cada combinación de X.
- Esto **no prueba** que el RF no sirva para recetas nuevas. Prueba que **el protocolo de validación del paper no puede distinguir** entre "aprendió la física" y "recordó la receta". Esa es justo la pregunta que el paper deja abierta.
- El RMSE de PdI del paper (0.053 lípidos, 0.047 PLGA) ya está muy cerca del ruido entre réplicas (SD agrupada 0.051 y 0.041). Queda poco margen para que un modelo mejore. Esto apoya la **H2** del gap: comparar el error del modelo con el ruido experimental.

### 7.3 Cómo queda formulado el gap con esta evidencia

> **Qué no respondió el paper:** la capacidad de los modelos para predecir **formulaciones no vistas**. Su partición por medición deja réplicas de la misma receta en train y test (> 90 % de las filas de test), y un predictor sin aprendizaje alcanza métricas comparables a las publicadas.
>
> **H1:** con partición **agrupada por formulación** (GroupKFold / leave-one-formulation-out), el r² de prueba del RF bajará de forma significativa respecto al reportado, sobre todo en PdI y en dH de lípidos.
>
> **H2:** el error del RF con partición agrupada quedará cerca del ruido entre réplicas en dH y EE de PLGA (fenómeno bien determinado por la composición), y muy por encima en PdI (fenómeno ruidoso).
>
> **Extensiones naturales (Parte D):** extrapolación (dejar fuera un nivel completo de TFR, FRR o concentración), incertidumbre (Quantile RF / bootstrap / GP) comparada con el ruido de réplica, y variables con significado físico en lugar de concentraciones colineales.

---

## 8. Decisiones para las siguientes partes del parcial

### 8.1 Qué se replica tal cual (Parte B) y qué se corrige (Parte D)

La instrucción de la Parte B es "el mismo esquema del paper". Por eso la reproducción debe **copiar también sus decisiones discutibles**, y la Parte D es donde se corrigen.

| Paso del autor | **Parte B – Reproducción** (línea base) | **Parte D – Nuevo trabajo** |
|---|---|---|
| `prep_main` + `ml_prep` | Replicar igual: 0 = ausente, ratio con Inf → 0, 3 descriptores del fármaco | Variables físicas: concentración total, fracción de solvente = 1/(1+FRR), concentración final tras la mezcla = C/(1+FRR), indicador explícito de fármaco, tipo de partícula |
| Lípidos = LNP + liposomas juntos | Igual | Evaluar también por separado y *leave-one-particle-type-out* |
| Filtro PdI ≤ 0.25 por medición (dH) | Igual | Filtrar por formulación (PdI medio) |
| EE con partículas vacías incluidas | Igual (documentarlo como supuesto) | Modelar EE **solo con partículas cargadas** |
| Partición por fila 85/15 estratificada, semilla 1987 | Igual | **Partición agrupada por formulación** (el `id` se reconstruye con las X) |
| 10-fold CV por fila | Igual | GroupKFold (10) por formulación |
| `step_zv` + `step_normalize` | Igual (`StandardScaler` dentro del pipeline) | Igual |
| r² = cor(y, ŷ)² vía `lm` | Reportar **ambos**: el del autor y 1 − SSE/SST | 1 − SSE/SST + intervalos |
| Datos crudos con errores (zeta, EE > 100 %) | Sin limpiar (el autor no limpió) | Análisis de sensibilidad: ¿cambian los resultados si se recorta EE a 100 %? |

### 8.2 Supuestos que hay que documentar en la Parte B

1. **Lenguaje:** el autor usa R + tidymodels. Si la reproducción se hace en Python (scikit-learn), las particiones con la misma semilla **no darán las mismas filas**, porque los generadores aleatorios son distintos. Esa es una fuente esperada de discrepancia. Alternativa: reproducir en R con el código del autor y luego reimplementar.
2. **Estratificación:** `rsample` estratifica una y numérica en **cuartiles** (`breaks = 4`). En Python hay que crear esos bins a mano.
3. **`ml_prep` en Python:** el resultado debe tener exactamente 16 columnas en lípidos y 12 en PLGA (tabla de §5). Es un buen test de que la reproducción del preprocesamiento es correcta.
4. **El RF del autor** usa el paquete `randomForest` de R, distinto de `RandomForestRegressor` de sklearn (p. ej. `mtry` vs `max_features`, `min_n` vs `min_samples_split`/`min_samples_leaf`).

### 8.3 Hoja de ruta por partes (según `contexto/Instrucciones.pdf`)

| Parte | Peso | Estado | Qué usa de este documento |
|---|---|---|---|
| **A** – Propuesta (1 diapositiva) | 10 % | Hecha (`presentacion/`). Actualizar: los datos **ya se obtuvieron** del autor | §2 (descripción de los datos) |
| **B** – Reproducción | 30 % | Siguiente paso | §4–5 (pipeline a replicar), §8.1–8.2 (supuestos) |
| **C** – Gap | 15 % | Planteado y ahora con evidencia | §6 y §7 (argumento cuantitativo) |
| **D** – Nuevo trabajo | 25 % | Pendiente | §7.3 (hipótesis), §8.1 (columna "Parte D") |
| Código reproducible | 10 % | Pendiente | requirements, semillas, README |
| Informe + sustentación | 10 % | Pendiente | Todo |

---

## 9. Anexo: cómo se obtuvieron los números de este documento

- **Exploración de los CSV:** pandas sobre `mfNP_database.csv`, `df_summary.csv` y `data_genAI_v_mfNP.csv` (conteos, rangos, valores únicos, correlaciones de Spearman por tipo de partícula).
- **Emulación del pipeline R:** reimplementé `prep_main` (0 → NA) y `ml_prep` (NA → 0, ratio material:fármaco con Inf → 0, descriptores de `dat_payload`, pivot de reactivos, limpieza de nombres) en Python. Se obtienen tablas de **243 × 16** (lípidos) y **324 × 12** (PLGA), con las mismas columnas que produce el R.
- **Identificación de formulaciones:** combinación única de todas las X (redondeadas a 3 decimales) → 81 en lípidos y 108 en PLGA, cada una con 3 filas.
- **Simulación de la partición:** 500 repeticiones de una partición 85/15 estratificada por cuartiles del objetivo (aproximación de `rsample::initial_split`), con el filtro PdI ≤ 0.25 en los modelos de diámetro. Para la CV, 10 folds aleatorios sobre todas las filas.
- **Memorizador:** para cada fila de test, la predicción es el promedio del objetivo en las réplicas de su formulación presentes en train. Se reportan medianas sobre las 500 particiones.
- **Ruido de réplica:** SD dentro de cada formulación. "Agrupada" = √(Σ residuos² / (n − n.º de formulaciones)); "mediana" = mediana de las SD por formulación.
- **Techo de r²:** 1 − Σ(y − media de su formulación)² / Σ(y − media global)².

Estos cálculos son exploratorios y no forman parte todavía del repositorio del parcial. Cuando se arme el código de la Parte B, conviene incluirlos como notebook (`00_exploracion_datos`) para que sean reproducibles.
