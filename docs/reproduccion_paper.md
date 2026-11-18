# Reproducción del paper y corrida de referencia en R

Este documento explica **qué se reprodujo del paper, qué se simplificó y por qué**, y **para qué sirve correr el código R original del autor**: qué se gana, cuánto tarda y cómo hacerlo. También propone cómo acercar la reproducción a los números publicados sin forzar los resultados.

> Documentos relacionados:
> - `docs/supuestos_y_validaciones.md`: registro técnico de cada decisión, con su riesgo y cómo validarla.
> - `notebooks/Parte_B_reproduccion.ipynb`, sección 7: análisis de discrepancias con todos los números.
> - `README.md`: instalación y ejecución.

---

## 1. Qué se reprodujo

La Parte B reimplementa en **Python / scikit-learn** el flujo del autor (`recursos/01_mfNP.R` a `04_AlgScreening.R`) para reproducir dos resultados:

| Resultado del paper | Qué es | Notebook |
|---|---|---|
| **Tabla 2** | Random Forest afinado: RMSE y r² en entrenamiento y prueba, para lípidos y PLGA × tamaño (dH), uniformidad (PdI) y encapsulación (EE) | `Parte_B_reproduccion.ipynb`, sección 4 |
| **Tablas S1 y S2** (SI) | Comparación de 13 algoritmos con validación cruzada | `Parte_B_reproduccion.ipynb`, sección 5 |

### 1.1 Resultados obtenidos (ejecución del 15-nov-2026, semilla 1987)

> La comparación con la corrida del código R original del autor (17-nov-2026) está en la **sección 5**. Muestra que la reimplementación en Python es fiel y que el propio código del autor tampoco reproduce algunos valores publicados.

**Tabla 2: r² en prueba (1 = predicción perfecta)**

| | Tamaño (dH) | Uniformidad (PdI) | Encapsulación (EE) |
|---|---|---|---|
| **PLGA** (Python vs paper) | 0.957 vs 0.964 ✅ | 0.703 vs 0.560 | 0.992 vs 0.984 ✅ |
| **Lípidos** (Python vs paper) | 0.817 vs 0.922 ⚠️ | 0.856 vs 0.787 | 0.827 vs 0.472 ⚠️ |

- **PLGA: reproducción exitosa.** En tamaño y encapsulación, el r² difiere en menos de 0.01.
- **Lípidos: reproducción parcial.**
  - Tamaño: queda por debajo del paper.
  - Encapsulación: el valor del paper (0.472) es difícil de explicar con sus propios números. Su r² de entrenamiento (0.668) es muy bajo para un Random Forest de este tipo, y su propio r² de validación cruzada (0.929) sí coincide con el nuestro.
- El mejor `min_n` sale 2 en los 6 modelos, igual que reporta el paper.

**Tablas S1/S2: 11 de 13 algoritmos**

- Los **modelos lineales coinciden casi exactamente** con el paper. Esto confirma que los datos y su preparación son equivalentes a los del autor.
- Se mantiene la conclusión del paper: los ensambles de árboles y kNN son los mejores, y los modelos lineales los peores. El Random Forest queda entre los 3 mejores en los 6 casos, aunque no siempre en primer lugar.
- Las mayores diferencias son XGBoost (lípidos · dH: 31 vs 17 nm) y el SVM radial (peor en los 6 casos).

---

## 2. Qué se simplificó y por qué

### 2.1 Las simplificaciones

| Simplificación | El autor | Esta reproducción |
|---|---|---|
| **Búsqueda de hiperparámetros del Random Forest** (Tabla 2) | Rejilla de 10 × 10 × 10 = **1000 combinaciones** por modelo, con el número de árboles entre 1 y 2000. ~**60 000** entrenamientos en total | Número de árboles **fijo en 500**, y búsqueda solo sobre `mtry` y `min_n` (70–110 combinaciones por modelo). ~**5 400** entrenamientos |
| **Algoritmos** (Tablas S1/S2) | 13 algoritmos | **11**: no se implementaron bagged MARS ni bagged MLP |
| **Traducción R → Python** | Paquetes de R (`randomForest`, `kknn`, `kernlab`, `glmnet`…) | Equivalentes de scikit-learn. No siempre existe una traducción exacta (detalle en `docs/supuestos_y_validaciones.md`, §4) |

> **Analogía:** es como buscar la mejor receta de pastel. El autor probó 1000 combinaciones de temperatura, tiempo y azúcar. Aquí se fijó la temperatura en un valor razonable y solo se variaron el tiempo y el azúcar.

### 2.2 Por qué se simplificó

1. **Tiempo de cómputo en Python.**
   - La versión simplificada de la Tabla 2 tardó ~18 min (6 núcleos), y la Parte B completa ~33 min.
   - La rejilla del autor hace ~11 veces más entrenamientos, con árboles en promedio el doble de grandes. **En Python** tardaría unas **6–7 horas** (estimación, no medida).
   - En R es mucho más rápida, ~17–20 min según el autor (§3.3). La diferencia se debe a que scikit-learn tiene más costo fijo por árbol que el `randomForest` de R.
2. **Memoria del computador.** Con 12 procesos en paralelo, la ejecución agotó la RAM (16 GB) y se detuvo. La rejilla completa aumenta ese riesgo.
3. **El propio paper lo justifica.** Su Figura S3 muestra que con más de ~250 árboles el error ya no mejora. Fijar 500 árboles es una elección conservadora.
4. **MARS y MLP:**
   - scikit-learn no tiene MARS, y el paquete de Python que lo implementaba (`py-earth`) está abandonado.
   - MLP es una red neuronal, y se decidió no incluir redes en la implementación propia.
   - Ninguno de los dos es el mejor algoritmo del paper, así que no cambian sus conclusiones.
5. **Decisión del responsable del proyecto**, con la condición explícita de documentarla como validación pendiente (`docs/supuestos_y_validaciones.md`, §1.1 y §1.2).

### 2.3 Riesgo de las simplificaciones

Pueden explicar **parte** de las diferencias con el paper, sobre todo en lípidos. **Todavía no se sabe cuánta.** Para eso está la corrida en R (sección 3).

---

## 3. Por qué correr el código R del autor

### 3.1 El problema: tres posibles causas mezcladas

Cuando un resultado no coincide con el paper, hoy hay tres posibles causas imposibles de separar:

| Posible causa | Qué es | Por qué importa |
|---|---|---|
| **1. El azar** | R y Python eligen **mediciones distintas para la prueba**, aunque usen la misma semilla (1987), porque sus generadores aleatorios son diferentes | Los conjuntos de prueba son pequeños (24–52 filas). Cambiar qué recetas caen ahí mueve mucho el r². La Parte C lo muestra: en lípidos · dH, nuestra partición es más "difícil" que la típica |
| **2. La simplificación** | 500 árboles fijos en vez de 1000 combinaciones | Podría elegir una configuración distinta de la del autor |
| **3. La implementación** | Diferencias entre los paquetes de R y de Python | Por ejemplo, cómo se traduce `min_n` o cómo se eligen los 10 puntos de la búsqueda aleatoria |

Correr el código original es como **tener el examen resuelto por el profesor**: permite revisar cada causa por separado.

### 3.2 Qué se gana

| Qué produce la corrida R | Archivo | Qué pregunta responde |
|---|---|---|
| **Las métricas que da hoy el código del autor** | `resultados/referencia_R/tabla2_rf_R.csv` y `cv_algoritmos_R.csv` | ¿Su propio código reproduce los números del paper? Si no los reproduce (p. ej. el 0.472 de lípidos · EE), los números publicados probablemente salieron de otra versión del código o de los datos. Eso sería un hallazgo, no un error nuestro |
| **Las filas exactas que eligió para la prueba y para cada fold** | `resultados/referencia_R/particiones_R.csv` | Si Python, con **esas mismas filas**, se acerca al paper, la diferencia era **el azar** (causa 1) |
| **La configuración que eligió el autor** (`mtry`, árboles, `min_n`) | `tabla2_rf_R.csv` | ¿Es muy distinta de nuestros 500 árboles? Valida o descarta **la simplificación** (causa 2) |
| **Los resultados de bagged MARS y bagged MLP** | `cv_algoritmos_R.csv` | Completa la comparación de los 13 algoritmos y cierra la validación pendiente §1.2 |

**En resumen:** convierte las explicaciones del análisis de discrepancias de **"probablemente"** a **"comprobado"**. Esto pesa en la nota: la Parte B vale el 30 % y la rúbrica evalúa "fidelidad al método original, comparación de métricas, análisis de discrepancias".

**¿Es obligatoria?** No. Las normas indican que no reproducir exactamente un resultado no baja la nota si se analizan bien las causas. Pero sin la corrida en R esas causas quedan como hipótesis.

### 3.3 Cuánto tarda

> **Corrección (17-nov-2026):** una versión anterior de este documento estimaba "3–8 horas". Esa estimación salía de los tiempos de **Python**, y estaba equivocada para R. El `randomForest` de R está escrito en C y, con datos tan pequeños (~200 filas), es mucho más rápido que scikit-learn.

**Tiempos medidos por el autor** (SI, Tabla S6: rejilla completa de 1000 combinaciones, 13 de 16 núcleos, portátiles AMD Ryzen 9 6900HS / Intel i7-1260P):

| Modelo RF | dH | PdI | EE |
|---|---|---|---|
| Lípidos | 136 s | 205 s | 186 s |
| PLGA | 129 s | 177 s | 164 s |

La Tabla 2 completa le tomó **≈ 17–20 min**. La memoria máxima fue de solo 57–107 MB por modelo (Tabla S7).

**Estimación para este equipo** (12 núcleos lógicos, corriendo con 6):

| Etapa | Tiempo aproximado |
|---|---|
| Instalar R y los paquetes (una sola vez) | 10–20 min |
| Preparación de datos (`01_mfNP.R`) | segundos |
| Tabla 2 completa (`02` y `03`) | **~20–40 min** |
| Comparación de 13 algoritmos (`04`) | **~15–60 min**. El SI solo trae una figura (Fig. S12), sin números |
| **Total** | **≈ 40 min – 1.5 h** |

**Tiempo real de la corrida** (17-nov-2026, 6 procesos, `resultados/referencia_R/tiempos_R.csv`):

| Script | Tiempo |
|---|---|
| `01_mfNP.R` | 6 s |
| `02_rf_lipid_model.R` (RF lípidos, rejilla completa) | 23.5 min |
| `03_rf_PLGA_model.R` (RF PLGA, rejilla completa) | 38.4 min |
| `04_AlgScreening.R` (13 algoritmos) | 16.1 min |
| **Total** | **78 min** |

Tardó unas 3–4 veces más que lo que reporta el autor para la Tabla 2. Es esperable: se usaron 6 procesos en lugar de 13, y en Windows cada proceso es una sesión de R aparte que recibe los datos por comunicación entre procesos.

### 3.4 Riesgo de memoria

El código del autor usa automáticamente el **80 % de los núcleos**, unos 10 procesos (`registerDoParallel` en `recursos/01_mfNP.R`, línea 71). Cada modelo usa poca memoria (Tabla S7), pero cada proceso de R carga sus paquetes. Por seguridad, el notebook limita los procesos a 6, volviendo a registrar el paralelismo **después** de `source("01_mfNP.R")`. Así **no se modifican** los scripts originales del autor.

### 3.5 ¿Se puede acelerar la corrida R reduciendo la rejilla? No conviene (validado en el código)

La idea natural era aprovechar lo que dice el autor (más de ~250 árboles no mejora, Fig. S3) y probar menos combinaciones. **Se descartó** por dos razones:

1. **No hace falta.** Con los tiempos medidos por el autor, la corrida original completa dura alrededor de una hora (§3.3).
2. **Cambiaría las particiones de 4 de los 6 modelos.** En el código del autor, la semilla (`set.seed(seed)`) se fija justo antes de crear la partición **solo** en lípidos · PdI (`02_rf_lipid_model.R`, línea 10) y lípidos · dH (línea 80). Las otras cuatro particiones se crean **sin volver a fijar la semilla**:
   - lípidos · EE (línea 150);
   - PLGA · PdI, dH y EE (`03_rf_PLGA_model.R`, líneas 4, 73 y 144).

   Esas particiones dependen de cuántos números aleatorios consumió la búsqueda de hiperparámetros anterior. Si la búsqueda se reduce, esas particiones cambian y se pierde lo que se busca con la corrida R:

| Qué se quiere obtener de R | Corrida original | Corrida con rejilla reducida |
|---|---|---|
| Filas exactas de prueba del autor | ✅ 6 de 6 modelos | ❌ solo 2 de 6 |
| Validar la simplificación de Python (500 árboles) | ✅ se compara contra la rejilla completa | ❌ se simplificaría lo mismo que se quiere validar |
| Saber si el código del autor reproduce su paper | ✅ | ❌ ya no sería su código |

**Decisión:** correr el código del autor **sin modificar**, solo limitando el número de procesos (§3.4).

### 3.6 Versiones de R: se usa `tune` 1.3.0 (no la actual)

Al instalar R (R 4.6.2, noviembre de 2026) se instala `tune` 2.1.0. El NEWS de `tune` 2.0.0 tiene dos cambios que afectan directamente al código del autor:

1. **"The `foreach` package is no longer supported."** El autor activa el paralelismo con `registerDoParallel()` (`foreach`). Con `tune` 2.x eso se ignora y todo correría en **un solo núcleo**: varias horas en lugar de ~1 h.
2. **"There will be a lack of reproducibility between objects created in this version of tune and previous versions."** Cambió la forma de generar las semillas, así que las 4 particiones que dependen de la búsqueda (§3.5) no podrían coincidir con las del autor.

**Solución adoptada:** instalar **`tune` 1.3.0 y `tidymodels` 1.3.0** (21-feb-2025), las últimas compatibles con `foreach` y de la época del paper. Van en una **biblioteca separada** (`%LOCALAPPDATA%/R/lib-tune-1.3.0`) para no alterar la instalación principal. El notebook `00R_referencia_autor.ipynb`:
- pone esa biblioteca primero en `.libPaths()`;
- exporta `R_LIBS`, para que los procesos paralelos (que en Windows son sesiones nuevas de R) carguen las mismas versiones. Sin esto, todos los ajustes fallaban con "All models failed".

**Limitación:** no se conocen las versiones exactas que usó el autor (no las reporta). `tune` 1.3.0 es la mejor aproximación, pero otros paquetes (`rsample`, `parsnip`, `dials`, `randomForest`) son versiones actuales. Si la corrida no reproduce la Tabla 2 del paper, esta es una causa posible.

> **Consecuencia adicional:** como 4 particiones dependen del consumo de números aleatorios de `tune`, **si las versiones de los paquetes de R difieren de las que usó el autor**, esas particiones podrían no coincidir con las de su corrida original (y por lo tanto con el paper), aunque el código sea el mismo. Esto se verifica al comparar `tabla2_rf_R.csv` con la Tabla 2 publicada.

### 3.7 Cómo ejecutarla

1. Instalar R y el kernel de Jupyter: ver `README.md`, sección "R".
2. Ejecutar `notebooks/00R_referencia_autor.ipynb`. Trabaja sobre una **copia** de `recursos/`, así que los archivos originales no se tocan.
3. Volver a ejecutar `notebooks/Parte_B_reproduccion.ipynb`. Detecta los archivos de `resultados/referencia_R/` y agrega automáticamente:
   - la comparación con la misma partición que R;
   - las métricas del código original, incluidos MARS y MLP.
4. Actualizar `docs/supuestos_y_validaciones.md` (estados ⏳ → ✅) y la sección 7 de la Parte B.

---

## 4. Cómo acercar la reproducción a los números del paper

### 4.1 Regla de honestidad

Las normas del parcial (`contexto/Instrucciones.pdf`, §7) dicen:

> "reportar resultados negativos o reproducciones fallidas es válido y se valora. Ajustar el análisis para que coincida con el paper sin justificarlo se penaliza."

Por eso el objetivo **no es forzar los números**, sino **eliminar una por una las causas de diferencia** y reportar cuánto aporta cada una.

### 4.2 Estrategias, en orden de prioridad

| # | Estrategia | Qué elimina | Estado | Requiere |
|---|---|---|---|---|
| 1 | **Usar la misma partición que R** (filas exactas de train/test y de cada fold) | El azar (causa 1). Probablemente la causa principal | ✅ **Hecho (17-nov-2026).** Con la partición de R, Python da el mismo r² que el código del autor (diferencia de 0.001–0.017). El azar explicaba diferencias de hasta ~0.13 | Corrida R |
| 2 | **Comparar con los hiperparámetros que eligió el autor** y reentrenar el RF de Python con ellos | La simplificación de la rejilla (causa 2) | ✅ **Ya no es necesaria.** Con la misma partición, la rejilla reducida de Python (500 árboles) iguala a la rejilla completa del autor, aunque elija otros `mtry`/árboles (el autor eligió 223–1777 árboles). La simplificación no cambia los resultados | — |
| 3 | **Verificar si el código del autor reproduce su propio paper**, sobre todo el 0.472 de lípidos · EE | Distingue "error nuestro" de "el paper usó otra versión" | ✅ **Hecho.** El código del autor, ejecutado hoy, **no** reproduce la Tabla 2 publicada en lípidos · dH (0.834 vs 0.922) ni en lípidos · EE (0.951 vs 0.472). Ver §5 | Corrida R |
| 4 | **Evaluar en Python los mismos 10 puntos de la búsqueda aleatoria** que probó R (Tablas S1/S2) | La mayor diferencia de S1/S2 (XGBoost, SVM radial), causada por sorteos distintos | ➖ **Opcional.** R, con sus propios sorteos, reproduce el SI (p. ej. XGBoost en lípidos · dH: 16.5 vs 17), lo que confirma que la diferencia de Python es el sorteo. Solo haría falta para igualar Python número a número | Editar notebook R y Parte B |
| 5 | **Comparar predicciones fila a fila** entre R y Python con la misma partición, y probar las dos traducciones de `min_n` (`min_samples_split = min_n` y `= min_n + 1`) | Diferencias de implementación (causa 3) | ➖ **Ya no es necesaria.** Las métricas agregadas coinciden (± 0.02 en r²), así que no hay diferencias de implementación que investigar | — |
| 6 | **Repetir la Tabla 2 con 20–50 semillas** y reportar el rango del r² | Muestra si el valor del paper cae dentro de la variabilidad normal | ✅ **Aproximado sin cómputo nuevo** con las 500 particiones simuladas de la Parte C (§5.3). Las repeticiones con el RF real se harán **dentro de la Parte D**, donde son necesarias para H1, fijando hiperparámetros (`min_n = 2`, `mtry` alto) para que tarden segundos y no 18 min por semilla | Parte D |

### 4.3 Qué queda

Nada pendiente para la Parte B:
- las estrategias 1–3 ya se aplicaron;
- la 2 y la 5 dejaron de ser necesarias;
- la 4 es opcional;
- la 6 se resolvió de forma aproximada con la simulación de la Parte C (§5.3).

Las repeticiones con varias particiones se harán en la **Parte D**, porque allí son obligatorias para comparar la partición por medición con la partición por receta (H1).

---

## 5. Resultados de la corrida R (17-nov-2026)

Corrida del código original del autor (`01`–`04`, sin modificar) con R 4.6.2, `tune` 1.3.0 y 6 procesos: **78 min** (§3.3).

### 5.1 Tabla 2: r² de prueba

| Modelo | Paper | Código R del autor | Python con la partición de R | Python con partición propia |
|---|---|---|---|---|
| Lípidos · dH | 0.922 | 0.834 | 0.839 | 0.817 |
| Lípidos · PdI | 0.787 | 0.869 | 0.868 | 0.856 |
| Lípidos · EE | 0.472 | 0.951 | 0.957 | 0.827 |
| PLGA · dH | 0.964 | 0.945 | 0.944 | 0.957 |
| PLGA · PdI | 0.560 | 0.607 | 0.590 | 0.703 |
| PLGA · EE | 0.984 | 0.976 | 0.977 | 0.992 |

**Qué se concluye de cada una de las tres causas (§3.1):**

| Causa | Resultado | Conclusión |
|---|---|---|
| **3. Implementación** (R vs Python con las mismas filas) | Diferencia de r² de prueba de 0.001–0.017; de entrenamiento, ≤ 0.003 | ✅ **La reimplementación en Python es fiel** al código del autor |
| **2. Simplificación** (500 árboles vs rejilla completa) | Lo anterior se obtiene **con** la rejilla reducida. El autor eligió otros hiperparámetros (223–1777 árboles, `mtry` 6–9), pero el resultado es el mismo. `min_n = 2` en los 6 modelos, igual que en Python | ✅ **La simplificación no afecta los resultados** |
| **1. Azar** (partición propia vs partición de R) | R y Python comparten solo 1–13 filas de prueba por modelo. El r² de prueba cambia hasta ~0.13 según la partición | ⚠️ **Una sola partición no permite comparar con precisión de centésimas** |

**Y frente al paper** (ver la reinterpretación en §5.3): el propio código del autor **no reproduce** la Tabla 2 publicada en lípidos · dH (0.834 vs 0.922), lípidos · EE (0.951 vs 0.472) y el RMSE de PLGA · EE (5.7 vs 2.2 %). En lípidos · dH, cuya partición se fija con `set.seed()` justo antes, el r² de **entrenamiento** coincide exactamente (0.950), pero el de prueba no. Las causas posibles, que no se pueden distinguir con la información disponible, son:
- versiones distintas de los paquetes de R (el autor no las reporta);
- una versión distinta de la base de datos;
- una versión distinta del código.

### 5.2 Tablas S1/S2

- **El código R reproduce bien el SI** en los 13 algoritmos (p. ej. lípidos · dH: RF 15.9 vs 16; XGBoost 16.5 vs 17; bagged MARS 24.2 vs 24; bagged MLP 21.2 vs 20).
- Las diferencias de Python en XGBoost y SVM radial se deben al sorteo de la búsqueda aleatoria (validación M8).
- Bagged MARS y bagged MLP no son el mejor algoritmo en ningún objetivo, así que excluirlos de Python no cambia las conclusiones (validación §1.2).

### 5.3 ¿Cuánto cambia el resultado según la partición? (500 particiones simuladas)

**Pregunta:** ¿las diferencias entre el paper, el código R y Python se explican solo porque cada uno usó una partición distinta?

**Método (sin cómputo nuevo):** la Parte C evaluó el "memorizador" en **500 particiones** generadas con el mismo procedimiento del autor (`resultados/parte_C/simulacion_500_particiones.csv`). Sus predicciones tienen una correlación de 0.96–0.997 con las del Random Forest, así que su r² en esas 500 particiones aproxima cuánto variaría la Tabla 2 del RF al cambiar la semilla.

| Modelo | r² en 90 % de las particiones (p5 – p95) | Mediana | Paper (percentil) | Código R (percentil) | Python (percentil) |
|---|---|---|---|---|---|
| Lípidos · dH | 0.61 – 0.97 | 0.875 | 0.922 (p76) | 0.834 (p34) | 0.817 (p30) |
| Lípidos · PdI | 0.62 – 0.88 | 0.783 | 0.787 (p53) | 0.869 (p92) | 0.856 (p88) |
| Lípidos · EE | 0.75 – 0.98 | 0.937 | **0.472 (p0)** | 0.951 (p65) | 0.827 (p8) |
| PLGA · dH | 0.50 – 0.98 | 0.828 | 0.964 (p80) | 0.945 (p75) | 0.957 (p77) |
| PLGA · PdI | 0.47 – 0.76 | 0.624 | 0.560 (p22) | 0.607 (p41) | 0.703 (p82) |
| PLGA · EE | 0.86 – 1.00 | 0.988 | 0.984 (p42) | 0.976 (p35) | 0.992 (p65) |

**Conclusiones:**

1. **La partición mueve mucho el r²:** entre 0.14 y 0.49 de ancho en el 90 % central. Con conjuntos de prueba de 24–52 filas, comparar con una sola partición y precisión de centésimas no tiene sentido.
2. **5 de los 6 valores del paper son explicables por el azar de la partición** (percentiles 22–80). Esto **reinterpreta §5.1**: la diferencia en lípidos · dH (paper 0.922 vs código R 0.834) cae dentro de la variación normal y **no requiere otra explicación**.
3. **El único valor anómalo del paper es lípidos · EE (r² = 0.472).** Ninguna de las 500 particiones da un valor tan bajo; el 95 % supera 0.75. **No es azar.** Es coherente con su propia validación cruzada (0.929, Tabla S1) y con lo que dan su código actual (0.951) y Python (0.827). Probablemente el valor publicado salió de otra versión del código o de los datos, o de un error de reporte.
4. Las reproducciones en R y en Python caen dentro del rango esperado en los 6 modelos (percentiles 8–92).

**Limitación:** el memorizador aproxima al RF, pero no es idéntico. En la partición de la Parte B, su r² difiere del RF en ≤ 0.05, salvo en PLGA · EE (0.938 vs 0.992), por la regla de respaldo para recetas nuevas.

**✅ Confirmado con el RF real en la Parte D** (`resultados/parte_D/tabla2_100_semillas.csv`; 100 particiones, semillas 0–99):
- el paper queda en los percentiles 14–77 en 5 de 6 modelos;
- lípidos · EE (0.472) queda por debajo de las 100 repeticiones (el 90 % central va de 0.876 a 0.975);
- el código R del autor está entre los percentiles 14 y 89.

Las conclusiones de esta sección se mantienen.

### 5.4 Fuga por réplicas en la partición del autor (relevante para la Parte C)

En las filas exactas que elige el código del autor, entre el **83 % y el 100 %** de las filas de prueba tienen su réplica en entrenamiento, igual que en la partición de Python. El gap **no depende de la implementación** (`resultados/parte_C/evidencia1_fuga_particion_R_autor.csv`).

---

## 6. Estado actual (resumen)

| | Estado |
|---|---|
| Preparación de datos idéntica a la del autor | ✅ Verificada (`00_preparacion_datos.ipynb`) |
| Reimplementación fiel al código del autor | ✅ Verificada con la misma partición (r² ± 0.02) |
| Tabla 2 frente al paper | ✅ Dentro de la variación por partición en 5 de 6 modelos; lípidos · EE del paper es anómalo (§5.3) |
| Tablas S1/S2 | ✅ R reproduce el SI; Python reproduce las conclusiones (11 de 13 algoritmos) |
| Análisis de discrepancias | ✅ Con causas comprobadas (`Parte_B_reproduccion.ipynb`, §7) |
| Corrida de referencia en R | ✅ Hecha (78 min) |
| Validación de la rejilla reducida y de MARS/MLP | ✅ Validadas |
| Variabilidad por partición | ✅ Aproximada con 500 particiones (§5.3): 5 de 6 valores del paper son explicables por azar; lípidos · EE es anómalo |
