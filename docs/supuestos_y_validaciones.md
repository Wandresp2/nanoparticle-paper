# Supuestos, desviaciones y validaciones pendientes

Este documento registra **cada decisión** que se aparta del código o del texto del autor, o que este no especifica. Para cada una indica por qué se tomó, qué riesgo tiene sobre los resultados y cómo validarla.

Sirve de base para el **análisis de discrepancias** de la Parte B. Las instrucciones del parcial piden documentar como supuesto cualquier paso que el paper no detalle.

> En `docs/reproduccion_paper.md` hay una explicación en lenguaje sencillo de **por qué** se simplificó, **qué se gana al correr el código R** (tiempos, riesgos de memoria y pasos) y las **estrategias para acercar la reproducción al paper**.

**Estados posibles:**
- ✅ validado;
- ⏳ validación pendiente;
- ➖ no requiere validación (decisión de fidelidad).

**Fuentes del autor:**
- `recursos/01_mfNP.R` … `04_AlgScreening.R` y `recursos/extra/functions.R`;
- el paper (Tabla 2);
- el SI final (`contexto/adfm71140-sup-0001-suppmat.pdf`, Tablas S1 y S2).

---

## 1. Validaciones pendientes prioritarias

Las pidió explícitamente el responsable del proyecto. Deben resolverse antes de cerrar la Parte B.

### 1.1 Rejilla reducida del Random Forest (Tabla 2) ✅

| | |
|---|---|
| **Qué hace el autor** | `grid_regular(levels = 10)` sobre `mtry` ∈ [1, p+1], `trees` ∈ [1, 2000] y `min_n` ∈ [2, 40]: **1000 combinaciones × 10-fold CV** para cada uno de los 6 modelos (≈ 60 000 ajustes). Archivos `02_rf_lipid_model.R` y `03_rf_PLGA_model.R` |
| **Qué se hace en Python** | `trees` **fijo en 500**; `mtry` ∈ {1, …, p} (todos los enteros, que incluyen los niveles del autor); `min_n` en los mismos 10 niveles del autor. Son 110 combinaciones (lípidos) y 70 (PLGA) por modelo |
| **Por qué** | Costo de cómputo. El SI (Fig. S3) indica que el error deja de mejorar con más de ~250 árboles, y que el mejor `min_n` es el mínimo y el mejor `mtry` el máximo |
| **Riesgo** | (a) Que la configuración óptima del autor use un número de árboles muy distinto de 500. (b) Que la rejilla completa elija otro `mtry`/`min_n` por diferencias pequeñas de CV. En ambos casos cambiarían las métricas de la Tabla 2 |
| **Cómo validar** | 1. Correr `notebooks/00R_referencia_autor.ipynb` y comparar los hiperparámetros que elige el autor (`tabla2_rf_R.csv`: `mtry`, `trees`, `min_n`) con los de Python. 2. Con la partición exportada de R, repetir en Python el RF con `trees` ∈ {50, 250, 500, 1000, 2000} y medir cuánto varían el RMSE y el r² de test. 3. **Criterio:** si la variación del RMSE de test es menor que el error estándar de la CV (`cv_rmse_se`), la rejilla reducida no afecta las conclusiones |
| **Resultado de la validación (17-nov-2026)** | Con la **partición exacta de R**, el RF de Python con rejilla reducida da el mismo r² de prueba que el código del autor con la rejilla completa: diferencias de 0.001–0.017 en prueba y ≤ 0.003 en entrenamiento. El autor eligió 223–1777 árboles y `mtry` 6–9, distintos de Python, pero con resultados equivalentes. `min_n = 2` en los 6 modelos de ambos. **La rejilla reducida no afecta las conclusiones.** Detalle en `docs/reproduccion_paper.md` §5.1 |
| **Estado** | ✅ Validado con la corrida R |

### 1.2 Bagged MARS y bagged MLP no implementados en Python ✅

| | |
|---|---|
| **Qué hace el autor** | `bag_mars()` (motor `earth`) y `bag_mlp()` (motor `nnet`, red de 1 capa oculta), ambos con búsqueda aleatoria de 10 puntos (`04_AlgScreening.R`) |
| **Qué se hace en Python** | **No se implementan.** En las tablas comparativas aparecen como "no implementado". La comparación de algoritmos en Python cubre **11 de 13** |
| **Por qué** | Decisión del proyecto: scikit-learn no tiene un MARS equivalente, y el paquete `py-earth` está abandonado. Para el MLP se prefirió no introducir redes neuronales en la implementación propia |
| **Riesgo** | Bajo para las conclusiones del paper: ninguno de los dos es el mejor algoritmo (Tablas S1/S2: bagged MARS está entre los peores; bagged MLP es intermedio). Sí se pierde la comparación completa de los 13 |
| **Cómo validar** | Correr `00R_referencia_autor.ipynb`. `cv_algoritmos_R.csv` incluye ambos algoritmos con el código original. La Parte B los añade automáticamente a la comparación (sección 5) para confirmar que su posición en el ranking coincide con el SI |
| **Resultado de la validación (17-nov-2026)** | El código R del autor reproduce los valores del SI para ambos algoritmos. RMSE de CV, R vs SI: bagged MARS en lípidos · dH 24.2 vs 24, en PLGA · dH 15.1 vs 15 y en PLGA · EE 10.7 vs 10.7; bagged MLP en lípidos · dH 21.2 vs 20 y en PLGA · EE 3.7 vs 4.6. Ninguno es el mejor algoritmo en ningún objetivo, así que **excluirlos de Python no cambia las conclusiones** de la comparación |
| **Estado** | ✅ Validado con la corrida R |

### 1.3 Observaciones de la primera ejecución (15-nov-2026) que orientan las validaciones

- **Configuración usada:** RF con rejilla reducida; `min_n = 2` elegido en los 6 modelos, igual que en el paper.
- **PLGA:** r² de prueba ≈ paper en dH (0.957 vs 0.964) y EE (0.992 vs 0.984).
- **Lípidos:**
  - dH queda por debajo (0.817 vs 0.922);
  - EE queda muy por encima (0.827 vs 0.472). El r² de entrenamiento del paper en EE (0.668) es inusualmente bajo para un RF con `min_n = 2`.
- **S1/S2:** los modelos lineales coinciden casi exactamente con el SI, lo que confirma que datos y preprocesamiento son equivalentes. Las mayores diferencias (XGBoost en lípidos · dH; SVM radial en los 6 modelos) se atribuyen a la búsqueda aleatoria de 10 puntos con otro generador (M8).
- **(Resuelto el 17-nov-2026 con la corrida R; ver §1.1, §1.2, P1, P2, P4 y M8.)** Prioridad que se había fijado al instalar R: (1) comparar con `tabla2_rf_R.csv` y con la partición exacta de R (P2), para explicar lípidos · dH y lípidos · EE; (2) validar la rejilla reducida (1.1); (3) MARS/MLP (1.2).

Detalle completo: sección 7 de `notebooks/Parte_B_reproduccion.ipynb`.

---

## 2. Datos y preprocesamiento

| # | Decisión | Motivo | Riesgo / impacto | Cómo se validó / validar | Estado |
|---|---|---|---|---|---|
| D1 | Emulación en Python de `prep_main()` y `ml_prep()` | Implementación propia exigida por las normas | Que las tablas de entrada difieran de las del autor | El notebook `00` verifica que se reproduce **exactamente** `df_summary.csv` (189 formulaciones, mismos promedios) y que las tablas tienen las mismas dimensiones y columnas que `dfML_lipid` (243 × 16) y `dfML_PNP` (324 × 12) | ✅ |
| D2 | Los datos **no se limpian** (zeta −7137 mV, 9 filas con EE > 100 %, EE de LNP = 0, triplicados muy dispersos) | Fidelidad: el autor no los limpia | El zeta no se usa. EE > 100 % y EE = 0 en LNP sí entran en el modelo de EE de lípidos | Análisis de sensibilidad en la Parte D (p. ej. recortar EE a 100 % y modelar EE solo con partículas cargadas) | ➖ |
| D3 | `meta_formulation_id` reconstruido como la combinación única de las X (redondeo a 6 decimales) | El autor descarta su `id` en `ml_prep` | Agrupar recetas distintas por error, o separar réplicas | `00` verifica 81 + 108 formulaciones, cada una con exactamente 3 réplicas y un solo tipo de partícula | ✅ |

## 3. Partición y validación cruzada

| # | Decisión | Motivo | Riesgo / impacto | Cómo validar | Estado |
|---|---|---|---|---|---|
| P1 | Emulación de `rsample::initial_split(strata = y)`: cuartiles del objetivo, `floor(n·0.85)` por estrato, fusión de estratos con < 10 % | rsample no existe en Python | Pequeñas diferencias en el tamaño de train/test por estrato | Comparar los tamaños con `particiones_R.csv` | ✅ Los tamaños de train/test coinciden exactamente con los de R en los 6 modelos (24/38/38 y 36/51/52 filas de prueba) |
| P2 | Semilla 1987 en NumPy (`default_rng`) y en `KFold` | Misma semilla que el autor | **R y Python generan filas distintas con la misma semilla.** Los conjuntos de prueba no coinciden con los del paper, y con test de 23–49 filas el r² de test puede variar varias centésimas solo por cuáles filas caen en él | La Parte B (sección 4) repite el RF con la **partición exacta exportada desde R**. Así separa el efecto del azar del de la implementación | ✅ Confirmado: R y Python comparten solo 1–13 filas de prueba por modelo. Con la partición de R, Python iguala al autor (± 0.02 en r²); con la propia, el r² cambia hasta ~0.13 |
| P3 | `vfold_cv` sin estratificar → `KFold(shuffle=True)` | Igual que el autor (no estratifica la CV) | Ninguno conceptual | — | ➖ |
| P4 | La corrida R de referencia se ejecuta **sin reducir la rejilla**, aunque sería más rápida | En el código del autor, la semilla se fija antes de la partición solo en lípidos · PdI y lípidos · dH. Las otras 4 particiones dependen de los números aleatorios que consumió la búsqueda anterior | Reducir la rejilla cambiaría 4 de 6 particiones. Incluso sin modificarlo, otras versiones de `tune`/`rsample` podrían generar particiones distintas de las del autor | Comparar `tabla2_rf_R.csv` con la Tabla 2 del paper. Detalle en `docs/reproduccion_paper.md` §3.5 | ✅ Corrida completa sin modificar los scripts (78 min). El código del autor **no** reproduce la Tabla 2 publicada en lípidos · dH ni en lípidos · EE; ver `docs/reproduccion_paper.md` §5.1 |

## 4. Modelos (equivalencias R → Python)

| # | Algoritmo | Equivalencia usada | Diferencia conocida / riesgo | Estado |
|---|---|---|---|---|
| M1 | Random Forest (`randomForest`) | `RandomForestRegressor`, `max_features = mtry`, **`min_samples_split = min_n + 1`** | En `randomForest`, `nodesize` (= `min_n`) indica que un nodo se divide solo si tiene **más** de `nodesize` observaciones. Por eso `min_samples_split = min_n + 1`. En `mtry` > p, `randomForest` lo recorta a p; aquí también | ✅ Equivalente: con la misma partición, mismo r² que R (± 0.02) |
| M2 | bagged trees (`baguette::bag_tree`, `rpart`) | `BaggingRegressor(DecisionTreeRegressor)` con **11 bolsas** (valor por defecto de `baguette`) | `cost_complexity` de `rpart` es relativo al error del nodo raíz, por eso se usa `ccp_alpha = cp · Var(y)` (aproximación). `min_n` → `min_samples_split` | ➖ Aproximación documentada; las diferencias de S1/S2 se explican por el sorteo (M8) |
| M3 | XGBoost (`boost_tree`) | `XGBRegressor`; `mtry` → `colsample_bynode = mtry/p`; `min_n` → `min_child_weight`; `sample_size` → `subsample` | **No se usa `stop_iter`** (parada temprana). En parsnip, sin conjunto de validación, la parada temprana se evalúa sobre el propio entrenamiento y casi nunca se activa | ➖ Aproximación documentada; las diferencias de S1/S2 se explican por el sorteo (M8) |
| M4 | kNN (`kknn`) | `KNeighborsRegressor` con `p = dist_power` | `kknn` muestrea entre 10 funciones de peso (rectangular, triangular, gaussiana, óptima…). sklearn solo ofrece `uniform` (≈ rectangular) y `distance` (≈ inv). **Además, con réplicas de X idénticas, `weights="distance"` da peso total a la réplica exacta: es un memorizador perfecto** (relevante para la Parte C) | ➖ Aproximación documentada; las diferencias de S1/S2 se explican por el sorteo (M8) |
| M5 | LASSO / Ridge (`glmnet`) | `Lasso(alpha = λ)` y `Ridge(alpha = n·λ)` | Las escalas de penalización de glmnet y sklearn no son idénticas (glmnet usa 1/(2n)·RSS y estandariza internamente). Con λ ≤ 1 y X estandarizadas el efecto es pequeño | ➖ Aproximación documentada; las diferencias de S1/S2 se explican por el sorteo (M8) |
| M6 | Regresión lineal (`lm`) y Poisson (`glm`) | `LinearRegression` y `PoissonRegressor(alpha = 0)` | `lm` elimina coeficientes colineales (NA) y sklearn usa mínimos cuadrados de norma mínima. Las predicciones son equivalentes | ➖ |
| M7 | SVM lineal / polinomial / RBF (`kernlab`) | `SVR` + **escalado de y** (`TransformedTargetRegressor`) | `ksvm` escala X **e y** por defecto (`scaled = TRUE`), por eso el `margin` (ε) actúa sobre y estandarizada. Kernel polinomial: `gamma = scale_factor`, `coef0 = 1`. RBF: `gamma = rbf_sigma` | ➖ Aproximación documentada; las diferencias de S1/S2 se explican por el sorteo (M8) |
| M8 | Rangos de hiperparámetros | Rangos por defecto de `dials` (p. ej. `learn_rate` 10⁻¹⁰–10⁻¹, `neighbors` 1–10, `cost` 2⁻¹⁰–2⁵) | Los valores concretos de la búsqueda aleatoria **no coinciden** con los de R (otro generador). Con solo 10 puntos, algunos algoritmos pueden caer en configuraciones peores o mejores por azar. **Confirmado con R (17-nov-2026):** el código del autor reproduce el SI en XGBoost (lípidos · dH: 16.5 vs 17 nm) y en SVM radial (PLGA · EE: 9.1 vs 8.9 %), donde Python se alejaba (31.1 y 12.5). La diferencia de Python viene de los puntos sorteados en la búsqueda aleatoria, no de los datos ni del preprocesamiento | ✅ |

## 5. Métricas

| # | Decisión | Detalle | Estado |
|---|---|---|---|
| E1 | r² = **correlación² entre observado y predicho** | Es lo que calculan `yardstick::rsq` (CV) y `summary(lm(y ~ pred))$r.squared` (Tabla 2). Puede ser alto aunque las predicciones estén sesgadas. Por eso la Parte B reporta **también** r² = 1 − SSE/SST | ➖ |
| E2 | Error de la CV = **error estándar** (`std_err`) | El SI dice "media ± 1 SD", pero el código guarda el `std_err` de `show_best()`. Se compara solo la media | ➖ |
| E3 | r² de las Tablas S1/S2 = mejor r² medio entre las 10 configuraciones | El autor toma `show_best(metric = "rsq")[1, ]`, que puede ser una configuración distinta de la de mejor RMSE. Se replica y también se guarda el r² de la configuración de mejor RMSE (`rsq_de_config_rmse`) | ➖ |
| E4 | Valores del paper transcritos a mano | Tabla 2 del artículo y Tablas S1/S2 del SI (extraídas con `pdftotext` y verificadas) | ✅ |

## 6. Entorno

| # | Decisión | Detalle | Estado |
|---|---|---|---|
| X1 | Python 3.14, scikit-learn 1.9.1, xgboost 3.4.1, pandas 3.1.1, numpy 2.5.5 | Versiones fijadas en `requirements.txt`. El autor usó R + tidymodels (versiones no reportadas) | ➖ |
| X3 | Corrida R con **`tune` 1.3.0 y `tidymodels` 1.3.0** (biblioteca separada), en R 4.6.2 | `tune` 2.x ya no admite `foreach` (el código del autor correría en un solo núcleo) y cambió la generación de semillas. Las demás versiones de R son las actuales; el autor no reporta las suyas. Ver `docs/reproduccion_paper.md` §3.6 | ➖ |
| X2 | El entorno virtual (`.venv`) está dentro de una carpeta de OneDrive | La sincronización puede hacer más lentas la instalación y la ejecución. Se recomienda pausar la sincronización o excluir `.venv` | ➖ |

## 7. Parte D (nuevo trabajo)

El diseño completo, con hipótesis, criterios y controles, está en **`docs/parte_D_diseno.md`**, registrado antes de ejecutar. Aquí solo se listan los supuestos técnicos.

| # | Decisión | Detalle | Estado |
|---|---|---|---|
| D1 | Hiperparámetros del RF **fijos** (los de la Parte B) | Así, frente a la línea base, solo cambia la partición. Riesgo: se eligieron con validación por medición y pueden favorecer la memorización (`min_n = 2`) | ✅ Control con ajuste anidado por grupos en PLGA · PdI (notebook §6) |
| D2 | Partición por receta estratificada por cuartiles del **promedio de la receta** | Es la regla del autor (`initial_split`, 85 %, cuartiles) aplicada a recetas en lugar de filas | ➖ |
| D3 | Repeticiones emparejadas por número de semilla en la prueba *t* corregida | Las filas de prueba de los dos esquemas no coinciden, así que el emparejamiento es aproximado. Por eso se añade el experimento controlado de fuga, que sí está emparejado exactamente (mismas filas de prueba) | ➖ |
| D4 | Conformal por validación cruzada con el modelo completo | Residuos fuera de fold (5 folds) y el modelo entrenado con todo el entrenamiento. Es una simplificación de CV+ (Barber *et al.*, 2021), con cobertura aproximada | ➖ |
| D5 | Quantile Random Forest implementado a mano | Pesos de Meinshausen (2006) a partir de las hojas del mismo RF de scikit-learn (`apply`). Así no hace falta instalar `quantile-forest` | ➖ |
| D6 | `mtry` limitado a las columnas con varianza > 0 del entrenamiento | En subconjuntos (p. ej. solo recetas con fármaco) algunas columnas son constantes y `VarianceThreshold` las elimina | ➖ |
| D7 | Recetas sin fármaco = EE de 0 | Se verificó en los datos: no hay ninguna receta sin fármaco con EE > 0 ni ninguna con fármaco con EE = 0. Motiva la sensibilidad de EE (notebook §7) | ✅ |
