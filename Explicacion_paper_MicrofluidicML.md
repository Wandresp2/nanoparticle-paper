# Explicación del paper: *"Unleashing the Power of Machine Learning in Nanomedicine Formulation Development"*

> Documento de estudio para el Parcial (Parte A: Propuesta).
> Objetivo: entender el paper a fondo, paso a paso y en lenguaje sencillo, y tener identificado un *gap* que se pueda atacar con ML clásico.

---

## 0. ¿Qué contiene cada archivo de la carpeta `recursos/`?

Los cuatro archivos son del **mismo trabajo** pero en **momentos distintos** de su vida editorial: hay **dos parejas "artículo + material suplementario"**, la del preprint y la de la versión publicada.

| Archivo | Qué es | Pareja | Revisado por pares | Páginas aprox. |
|---|---|---|---|---|
| `Adv Funct Materials - 2025 - Moore - ....pdf` | **Versión final publicada** en *Advanced Functional Materials* (en línea 14-ago-2025, vol. 36, 2026) | Publicada | **Sí** | 17 |
| `adfm71140-sup-0001-suppmat.pdf` | **SI FINAL** de la versión publicada (Figuras S1–S13, Tablas S1–S7 + chats con los LLMs) | Publicada | Sí | ~45 |
| `chemrxiv-2025-2lb14-v2.pdf` | **Preprint** (borrador subido a ChemRxiv *antes* de la revisión por pares), v2, 11-mar-2025 | Preprint | **No** | 26 |
| `supporting_information.pdf` | **SI del preprint** (solo 3 figuras y 4 tablas + chats con los LLMs) | Preprint | No | 33 |

👉 **Para el parcial usa la pareja publicada**: el artículo de la revista + `adfm71140-sup-0001-suppmat.pdf`. El preprint y su SI quedan como material histórico: todo lo que tienen también está en la versión publicada.

### 0.1 Artículo publicado (el principal)
Es la versión "oficial" que debes citar. Contiene todo lo del preprint **más** análisis que los revisores seguramente pidieron. Es la referencia para la reproducción.

### 0.2 Preprint de ChemRxiv: ¿qué tiene de diferente?
El núcleo es el mismo (mismos datos, mismos 13 modelos, mismo Random Forest, mismos números en la Tabla 2, mismo SHAP, misma comparación con LLMs). Las diferencias reales son:

**Lo que el artículo publicado AGREGA y el preprint NO tiene:**
1. **Un autor nuevo**: Yosi Shamay (Technion, Israel).
2. **Más detalle del preprocesamiento**: eliminación de variables con varianza cero, escalado min-max a [0,1], "reshape" para que cada reactivo tenga su propia columna, y variables calculadas (razón reactivo:fármaco, propiedades químicas del fármaco).
3. **Justificación explícita** de por qué el PLGA se entrena aparte (los polímeros son materialmente distintos a los lípidos).
4. **Efecto del tamaño del set de entrenamiento** (50 % a 85 %, 10 particiones aleatorias) → nueva Figura 5 y Figuras S4–S5.
5. **Efecto del tamaño de la base de datos** (submuestras de 50 a 230 mediciones, 20 semillas) → Figuras S6–S8. Conclusión: *todavía no se alcanzó el número de datos suficiente*.
6. **Experimento PdI monodisperso vs polidisperso**: entrenan modelos de PdI solo con muestras PdI ≤ 0.25 o solo con PdI > 0.25 para probar que los datos polidispersos son "ruidosos".
7. **Modelo "agnóstico" (todo junto)**: un solo modelo para lípidos + PLGA → Figura S9 y Tabla S3. Funciona para tamaño y PdI, pero **falla totalmente para EE** (RMSE = 73.4 %), y usan SHAP para explicar por qué.
8. **Validación con datos de la literatura** (sección 2.7, Figura S11): prueban el modelo con formulaciones de otros artículos.
9. **Costo computacional** (Figuras S12–S13, Tablas S6–S7): <10 s por modelo en el screening y <5 min para el Random Forest optimizado.
10. La figura de la búsqueda de hiperparámetros pasa de ser Figura 5 (preprint) a Figura S3 (publicado).

**Detalles menores**: el preprint pone la sección de Métodos antes de Resultados (el publicado la pone al final como "Experimental Section"); el preprint tiene errores de tipeo (p. ej. "0.9226", "Restuls").

👉 **En resumen**: el preprint sirve como versión "resumida" y para ver cómo evolucionó el trabajo, pero **no aporta información que no esté en el publicado**.

### 0.3 SI final (`adfm71140-sup-0001-suppmat.pdf`): el que debes usar
Es el material suplementario **oficial** de la versión publicada (incluye a Yosi Shamay como autor). Contenido, sección por sección:

| Sección del SI final | Figura / Tabla | Qué contiene | ¿Estaba en el SI del preprint? |
|---|---|---|---|
| 1. Estadísticas resumen | **Fig. S1** | Distribución de dH, PdI y EE en train vs test (boxplots) → muestra que el split quedó balanceado | Sí (como Supp. Fig. 2) |
| 2. Parámetros de producción | **Fig. S2** | La "caja experimental": cada punto es una combinación TFR × FRR × concentración probada | Sí (como Supp. Fig. 1) |
| 3. Screening de modelos | **Tablas S1 y S2** | RMSE y r² (media ± DE en 10-fold CV) de **los 13 algoritmos** para lípidos y PLGA. **Son la referencia numérica para reproducir la comparación de algoritmos** | Sí (mismos números) |
| 4. Optimización del RF | **Fig. S3** | Grid search de 1000 combinaciones (mtry, min_n, trees) | No (estaba como Fig. 5 del preprint) |
| | **Fig. S4** | Efecto del % de entrenamiento (50–85 %) sobre PdI y EE | **Nuevo** |
| | **Fig. S5** | **Número de mediciones** que quedan en train y en test para cada modelo | **Nuevo** |
| | **Figs. S6–S8** | Efecto del tamaño total de la base (50–230 mediciones) en RMSE, r² y en la variabilidad del RMSE | **Nuevo** |
| 5. Modelo con todas las partículas juntas | **Fig. S9 + Tabla S3** | Modelo "agnóstico" (lípidos + PLGA) | **Nuevo** |
| 6. Importancia de variables | **Fig. S10** | Importancia media absoluta SHAP | Sí (como Supp. Fig. 3) |
| 7. Validación con literatura | **Fig. S11** | Predicción vs medición para formulaciones de otros artículos (colores por DOI de origen) | **Nuevo** |
| 8. Formulaciones finales | **Tablas S4 y S5** | Recetas propuestas por cada LLM y por MicrofluidicML | Sí (Supp. Tablas 3 y 4) |
| 9. Costo computacional | **Figs. S12–S13, Tablas S6–S7** | Tiempo y RAM de cada modelo | **Nuevo** |
| 10. Chats con IA generativa | — | Transcripciones de ChatGPT (3.5 y 4o), Bard/Gemini y DeepSeek + conversión de razones molares a masa (ecs. S1–S5) | Sí (mismo contenido; solo cambian algunos enlaces, ahora varios dicen "N/A") |

**Información nueva y relevante que aporta (y que ya incorporé en las secciones 5 y 7 de este documento):**
1. **Tabla S3, modelo agnóstico, con números completos:**

   | | dH train | dH test | PdI train | PdI test | EE train | EE test |
   |---|---|---|---|---|---|---|
   | RMSE | 7.0 nm | 11.1 nm | 0.037 | 0.051 | 86.0 % | 73.4 % |
   | r² | 0.975 | 0.923 | 0.880 | 0.822 | **0.002** | **0.070** |

   Un r² de 0.002–0.070 en EE significa que el modelo **no explica nada** de la encapsulación cuando se mezclan lípidos y PLGA. Además, un RMSE de 73–86 % en una variable que va de 0 a 100 % es más grande que si se predijera siempre el promedio. Eso sugiere un problema de escala o de codificación (por ejemplo, partículas vacías mal tratadas) que el paper no discute.
2. **Fig. S5 confirma que el split se cuenta en *mediciones*** (no en formulaciones). Esto refuerza el argumento de fuga de información por réplicas (sección 7.1, punto 1, y el gap de la sección 8).
3. **Fig. S2**: su pie de figura dice que cada combinación se probó "para ver su capacidad de formar partículas monodispersas". Es decir, el diseño es una **rejilla factorial completa** de 3 niveles.
4. **Tablas S6–S7 (costo real)**: el RF con grid search completo tarda **~130–250 s** por modelo (AMD Ryzen 9 6900HS o Intel i7-1260P, 13 de 16 núcleos) y usa **~57–107 MB de RAM**. Esto confirma que es reproducible en cualquier portátil.

**¿Y el `supporting_information.pdf` (SI del preprint)?** Es un **subconjunto** del SI final: tiene solo 3 figuras y 4 tablas, sin Yosi Shamay como autor, y **no aporta nada que no esté en `adfm71140-sup-0001-suppmat.pdf`**. Ojo con la numeración: su "Supporting Figure 1" es la Fig. S2 del final, su "Supporting Figure 2" es la Fig. S1, y así sucesivamente. Cita siempre la numeración del SI final.

### 0.4 ⚠️⚠️ Lo más importante para el parcial: LOS DATOS NO SON PÚBLICOS (confirmado también en el SI final)
Revisé los **cuatro** PDFs (texto, enlaces y archivos adjuntos):
- **Ninguno** trae la base de datos cruda (las ~567 mediciones con sus X y sus y). El SI final tampoco: solo trae **métricas agregadas** (Tablas S1–S3, S6–S7) y **figuras**.
- Ningún PDF tiene archivos adjuntos (*embedded files*), ni enlaces a GitHub, Zenodo, Figshare o similar. Los únicos enlaces del SI final son a los chats de ChatGPT/Gemini y a dos documentos externos citados por los LLMs.
- Las figuras del SI final están insertadas como **imágenes rasterizadas** (bitmaps de ~1890 px de ancho), no como gráficos vectoriales. Por eso **no se pueden extraer los puntos de datos** directamente del PDF.
- La declaración de disponibilidad dice: *"The data that support the findings of this study are available from the corresponding author upon reasonable request"* (los datos se entregan **solo si se los pides al autor**). Tampoco se publicó el código de MicrofluidicML.

**¿Indica el SI los datos utilizados?** Solo de forma **descriptiva**: qué niveles de cada variable se usaron (Tabla 1 del artículo + Fig. S2), cuántas mediciones hay en train/test (Fig. S5) y cómo se distribuyen los targets (Fig. S1). Con eso se puede reconstruir la **matriz de diseño (las X)**, pero **no los valores medidos (dH, PdI, EE)**, que son indispensables para entrenar y reproducir.

Las instrucciones del parcial (sección 3, punto 3) exigen **verificar que puedes descargar los datos antes de inscribirte**, y la Parte A pide "el enlace a los datos". Por eso:
1. **Escribe ya** al autor de correspondencia: **Thomas L. Moore – thomaslee.moore@unina.it**, pidiendo el dataset (y si es posible el código en R de MicrofluidicML).
2. **Avísale al docente** de esta situación desde ya. Las reglas permiten cambiar de artículo **una sola vez** si los datos resultan inaccesibles.
3. **Plan B (débil)**: digitalizar a mano las figuras con WebPlotDigitizer (los mismos autores lo hicieron con GIMP para los datos de la literatura). Las Figuras 6 y 7 (predicho vs medido) dan los valores *medidos* de dH/PdI/EE, pero **sin decir a qué receta corresponde cada punto**. Por eso no sirven para reentrenar el modelo y solo permitirían verificar parcialmente las métricas. Consúltalo con el docente antes de apostar por esta vía.

---

## 1. El tema en una frase

> Los autores fabricaron ~200 recetas distintas de **nanopartículas para medicamentos** variando cómo las mezclan en un chip microfluídico, midieron qué partícula salía, y entrenaron modelos de **Machine Learning** para que, dada una receta, **predigan** el tamaño, la uniformidad y cuánto fármaco queda atrapado; luego usaron esos modelos **al revés** para proponer la receta que da una partícula de 100 nm, y compararon eso contra lo que proponen ChatGPT, Gemini y DeepSeek.

---

## 2. Contexto: ¿qué problema hay en el mundo real?

### 2.1 ¿Qué es una nanomedicina?
Es un medicamento "empacado" dentro de una partícula diminuta (entre ~30 y ~300 nanómetros; un cabello mide ~80 000 nm). La partícula protege el fármaco y ayuda a llevarlo a donde se necesita. Ejemplo famoso: las vacunas de ARNm contra el COVID usan **nanopartículas lipídicas (LNP)**.

### 2.2 Las propiedades que importan (las "salidas")
Para que una nanomedicina funcione igual siempre, necesita propiedades consistentes:

| Propiedad | Símbolo | Qué significa en simple | Unidad / rango |
|---|---|---|---|
| **Diámetro hidrodinámico** | dH | El tamaño de la partícula (medido "nadando" en líquido) | nm |
| **Índice de polidispersidad** | PdI | Qué tan **parecidas en tamaño** son todas las partículas. Bajo = todas iguales (bueno). Alto = mezcla de tamaños (malo) | 0 a 1 |
| **Eficiencia de encapsulación** | EE | Qué porcentaje del fármaco que pusiste quedó **atrapado** dentro de la partícula | % |

Ambos dH y PdI se miden con **DLS** (Dynamic Light Scattering: se ilumina la muestra con un láser y se analiza cómo se mueven las partículas). La EE se mide con un espectrofotómetro UV-Vis.

### 2.3 El problema
Cuando un laboratorio quiere crear una formulación nueva, encontrar la "receta" que da el tamaño, PdI y EE deseados es básicamente **prueba y error** + experiencia + copiar de otros artículos. Eso cuesta tiempo, material y dinero.

### 2.4 ¿Por qué microfluídica?
La microfluídica es una forma de fabricar las partículas haciendo pasar dos líquidos por **canales más delgados que un milímetro**:
- Un **líquido orgánico** (etanol o acetonitrilo) con el material disuelto (lípidos o polímero, y el fármaco).
- Un **líquido acuoso** (agua con buffer).

Cuando se mezclan rápidamente en el canal, el material deja de estar disuelto y **se autoensambla** formando las nanopartículas. Es reproducible y escalable. El equipo usado es un **NanoAssemblr Benchtop** (Precision NanoSystems) con un chip en forma de "Y" con relieves en espina de pescado (*staggered herringbone*) que favorecen la mezcla.

Lo bonito para ML: el resultado depende de **pocas perillas controlables** (las "entradas"). Eso hace el problema ideal para modelar.

---

## 3. La pregunta de investigación

> **¿Es posible, con algoritmos de ML de código abierto y una base de datos propia y pequeña (~550 mediciones), predecir con precisión el tamaño (dH), la uniformidad (PdI) y la eficiencia de encapsulación (EE) de nanopartículas fabricadas por microfluídica a partir de los parámetros de fabricación, y usar esos modelos para diseñar recetas con propiedades objetivo, de forma competitiva frente a los LLMs generativos?**

Sub-preguntas que el paper responde:
1. ¿Qué algoritmo de ML clásico predice mejor dH, PdI y EE? → *Random Forest*.
2. ¿Qué variables de fabricación pesan más en cada propiedad? → *SHAP + correlación de Pearson*.
3. ¿El modelo generaliza a partículas de otros laboratorios? → *Solo parcialmente*.
4. ¿Sirve el modelo para diseñar una partícula de 100 nm? ¿Mejor o peor que un LLM? → *Comparable con los mejores LLMs, sin alucinaciones*.

### ¿Por qué es relevante? (versión de 3–5 líneas para la diapositiva)
> Diseñar nanomedicinas con un tamaño, uniformidad y carga de fármaco específicos sigue siendo un proceso de prueba y error. Las propiedades fisicoquímicas de las nanopartículas determinan cómo interactúan con el cuerpo, y los reguladores exigen que se fabriquen de forma consistente. Si un modelo de ML liviano, entrenado con datos propios, puede predecir esas propiedades y sugerir recetas, se reducen los experimentos, el costo y el tiempo de desarrollo, sin depender de LLMs que pueden inventar información.

---

## 4. Los datos (el "dataset")

### 4.1 Los tres tipos de nanopartícula fabricados

| Tipo | De qué está hecha (composición molar FIJA) | ¿Lleva fármaco? | Líquido orgánico | Líquido acuoso |
|---|---|---|---|---|
| **LNP** (nanopartícula lipídica) | DODAP : DSPC : Colesterol : DSPE-PEG2k = 50 : 10 : 38.5 : 1.5 | **No**, siempre vacías | Etanol | Buffer citrato pH ~3.5 |
| **Liposomas** | DPPC : Colesterol : DSPE-PEG2k-COOH = 60 : 30 : 10 | Vacíos **o** con curcumina | Etanol | PBS pH 7.4 |
| **PLGA** (nanopartícula de polímero biodegradable) | PLGA Resomer RG 504H (50:50, 38–54 kDa) | Vacías **o** con curcumina | Acetonitrilo | Buffer Tris pH 7.2 |

- **Curcumina (CURC)**: es el **fármaco modelo** (el pigmento de la cúrcuma). Es hidrofóbica (no le gusta el agua). Se usa porque es barata y fácil de medir por color (absorbe a 425 nm).
- Ojo: en LNP y liposomas, la **proporción** entre lípidos es fija; lo que cambia es la **cantidad total**.

### 4.2 Las variables de entrada (X, "features")
Las perillas que se movieron sistemáticamente, con **3 niveles cada una**:

| Variable | Significado en simple | LNP | Liposomas | PLGA |
|---|---|---|---|---|
| **TFR** (Total Flow Rate) | Qué tan rápido fluye todo el líquido por el chip (mL/min) | 2, 4, 8 | 1, 4, 8 | 3 (o 4)*, 6, 13 |
| **FRR** (Flow Rate Ratio, acuoso:orgánico) | Cuánta agua por cada parte de solvente orgánico | 1, 3, 5 | 3, 6, 9 | 3, 4, 5 |
| **Concentración total del material** (mM) | Cuánto lípido/polímero hay disuelto | 20, 40, 60 | 12, 24, 48 | 0.109, 0.217, 0.435 |
| **Razón material : fármaco** | Cuánto material hay por cada unidad de curcumina | — | variable | variable |

\* *El paper es inconsistente: la Tabla 1 dice TFR = 3, 6, 13 para PLGA, pero la sección experimental dice 4, 6, 13.*

**Cómo entran realmente al modelo** (detalle técnico importante para reproducir):
- Cada **reactivo tiene su propia columna** con su concentración en mM (p. ej. columna "colesterol", columna "DSPC", columna "DODAP", columna "PLGA"...). Si un reactivo no está en esa partícula, vale 0.
- Variables calculadas: razón reactivo:fármaco y **propiedades químicas del fármaco** (peso molecular, XlogP3 = qué tan hidrofóbico es, área polar superficial). Como solo hay un fármaco (curcumina), estas columnas son en la práctica un **interruptor 0/1** ("tiene curcumina / no tiene").
- Se eliminan columnas con varianza cero y todo se escala a [0, 1] (min-max).

### 4.3 Las variables de salida (y, "targets")
Tres modelos de **regresión** independientes por cada grupo de partículas: **dH** (nm), **PdI** (0–1) y **EE** (%). Con 2 grupos (lípidos y PLGA) → **6 modelos** en total.

### 4.4 Tamaño del dataset

| Tipo | Formulaciones únicas | Mediciones totales |
|---|---|---|
| LNP | 27 (= 3×3×3) | 81 |
| Liposomas | 54 | 162 |
| PLGA | 108 | 324 |
| **Total** | **189** ("casi 200") | **567** ("más de 550") |

Observación clave: **567 / 189 = 3** → cada formulación se midió **3 veces** (réplicas). Esto será importante para el *gap* (ver sección 8).

Deducción (no lo dice el paper explícitamente): 27 formulaciones LNP = un diseño factorial completo 3×3×3; 108 PLGA = 27 × 4 (vacía + 3 razones de curcumina, probablemente); 54 liposomas = 27 × 2.

### 4.5 Una regla de filtrado importante: el umbral de PdI = 0.25
- **PdI ≤ 0.25** → partícula "**monodispersa**" (uniforme, confiable).
- **PdI > 0.25** → "**polidispersa**" (mezcla de tamaños; la medición del tamaño por DLS no es confiable).

Por eso:
- Los modelos de **dH y EE** se entrenan **solo con muestras monodispersas**.
- El modelo de **PdI** se entrena con **todas** las muestras.

### 4.6 Agrupación de los datos
- **Grupo "lípidos"** = LNP + liposomas juntos (ambos son de lípidos; además así prueban si el modelo generaliza entre dos arquitecturas distintas).
- **Grupo "PLGA"** = solo PLGA (el polímero es un material muy distinto).

---

## 5. El procedimiento paso a paso (el workflow "MicrofluidicML")

Todo está hecho en **R** (versión 4.3.3) con el paquete **tidymodels** (el equivalente en R de scikit-learn).

### Paso 1 – Fabricar y medir
Fabrican las 189 formulaciones en el NanoAssemblr, las purifican (diálisis para lípidos, centrifugación para PLGA) y miden dH y PdI (DLS) y EE (UV-Vis).

La EE se calcula así:

$$\%EE = \frac{C_i - C_s}{C_i}\times 100$$

donde $C_i$ es la curcumina que pusiste al inicio y $C_s$ la que quedó suelta en el líquido (no encapsulada).

### Paso 2 – Análisis exploratorio: correlación de Pearson
Antes de usar ML calculan la **correlación de Pearson** entre cada entrada y cada salida, por tipo de partícula (Figura 2C). Pearson mide relaciones **lineales**: +1 = suben juntas, −1 = una sube y la otra baja, 0 = no hay relación lineal.

Hallazgos:
- **LNP**: subir el FRR (más agua) → partículas **más pequeñas**. Lo demás casi no influye linealmente.
- **Liposomas**: el **TFR domina**: más flujo → partículas más pequeñas pero **menos uniformes** (PdI sube) y un poco menos de EE. Más lípido por curcumina → PdI baja y **EE sube**.
- **PLGA**: más PLGA → partículas **más grandes**; más PLGA por curcumina → **más EE**.

Como Pearson solo ve relaciones lineales y uno a uno, pasan a ML para algo más cuantitativo.

### Paso 3 – Separar entrenamiento y prueba
- Separación aleatoria **85 % entrenamiento / 15 % prueba**.
- Hecha de forma que la **media y la desviación** del target sean parecidas en ambos (una especie de estratificación; Fig. S1).
- El 15 % de prueba **no se toca** hasta el final ("datos no vistos").

### Paso 4 – Comparar 13 algoritmos ("screening")
Prueban 13 algoritmos de regresión:

| # | Algoritmo | Idea en una línea |
|---|---|---|
| 1 | Regresión lineal | Una recta (plano) |
| 2 | LASSO | Lineal con penalización que anula variables inútiles |
| 3 | Ridge | Lineal con penalización que encoge coeficientes |
| 4 | Regresión de Poisson | Lineal generalizado (para conteos/positivos) |
| 5 | k-vecinos más cercanos (kNN) | Predice promediando a los vecinos parecidos |
| 6 | SVM lineal | Máquina de vectores soporte con kernel lineal |
| 7 | SVM polinomial | ... con kernel polinomial |
| 8 | SVM radial (RBF) | ... con kernel gaussiano |
| 9 | Bagged trees | Muchos árboles de decisión en muestras bootstrap, promediados |
| 10 | Bagged MARS | Splines adaptativos multivariados, con bagging |
| 11 | Bagged MLP | Red neuronal pequeña (perceptrón multicapa), con bagging |
| 12 | XGBoost | Árboles en secuencia, cada uno corrige los errores del anterior |
| 13 | **Random Forest** | Bagging de árboles + cada división elige entre un subconjunto aleatorio de variables |

Para cada algoritmo:
- Ajustan hiperparámetros con **búsqueda aleatoria de 10 puntos** (prueban 10 combinaciones al azar).
- Evalúan cada combinación con **validación cruzada de 10 folds (10-fold CV)**: parten el entrenamiento en 10 pedazos, entrenan con 9 y evalúan en el que sobra, y repiten 10 veces.
- Métricas: **RMSE** (error típico, en las unidades de la variable; menor es mejor) y **r²** (proporción de la variación explicada; 1 = perfecto).

$$RMSE=\sqrt{\frac{1}{n}\sum (y_i-\hat y_i)^2}\qquad r^2 = 1-\frac{\sum (y_i-\hat y_i)^2}{\sum (y_i-\bar y)^2}$$

- Para comparar entre propiedades con unidades distintas, **normalizan el RMSE** de 0 a 1 entre algoritmos (Figura 3).

**Resultado (CV en entrenamiento, Tablas S1 y S2)** – el ganador en promedio es **Random Forest**:

| Grupo | Target | RF: RMSE | RF: r² |
|---|---|---|---|
| Lípidos | dH | 16 ± 2 nm | 0.860 |
| Lípidos | PdI | 0.067 ± 0.005 | 0.749 |
| Lípidos | EE | 9.8 ± 1.2 % | 0.929 |
| PLGA | dH | 11 ± 1 nm | 0.935 |
| PLGA | PdI | 0.053 ± 0.002 | 0.629 |
| PLGA | EE | 3.9 ± 0.5 % | 0.987 |

(El tamaño promedio es ~98 nm en lípidos y ~104 nm en PLGA, así que un error de 11–16 nm es del orden de 10–15 %.)

Observaciones de los autores:
- **EE es lo más fácil** de predecir (r² > 0.75 con todos los algoritmos).
- **PdI es lo más difícil** (r² varía enormemente entre algoritmos).
- **Los modelos lineales (lineal, LASSO, Ridge, Poisson, SVM lineal) son los peores** para dH (r² ≈ 0.3 en lípidos) → las relaciones son **no lineales**.
- Ojo: RF, bagged trees, kNN y XGBoost están **prácticamente empatados** (p. ej., lípidos dH: 16 ± 2 vs 16 ± 2 vs 17 ± 2 vs 17 ± 2). El paper elige RF pero **no hace ninguna prueba estadística** para decir que es mejor.
- Figura 4: los algoritmos que se equivocan mucho en PdI también se equivocan en dH. Interpretación: cuando una población de partículas es poco uniforme, su tamaño tampoco es confiable → es un efecto **físico** de los datos, no del modelo.

### Paso 5 – Afinar el Random Forest (búsqueda en rejilla)
Ya elegido RF, hacen una **búsqueda en rejilla (grid search)** de 10 valores × 3 hiperparámetros = **1000 combinaciones**, cada una con 10-fold CV:
- **trees** (número de árboles): después de ~250 árboles ya no mejora.
- **min_n** (mínimo de muestras por hoja): el mejor es el **más bajo** (min_n = 2), o sea, árboles muy profundos.
- **mtry** (variables candidatas en cada división): el mejor es el **más alto** (todas las variables) → en la práctica el RF se comporta casi como *bagged trees*.

### Paso 6 – Evaluar el modelo final en los datos de prueba (Tabla 2) ← **el resultado central**

| Grupo | Target | RMSE train | RMSE **test** | r² train | r² **test** |
|---|---|---|---|---|---|
| Lípidos | dH (nm) | 9.8 | **9.5** | 0.950 | **0.922** |
| Lípidos | PdI | 0.046 | **0.053** | 0.903 | **0.787** |
| Lípidos | EE (%) | 12.9 | **10.6** | 0.668 | **0.472** |
| PLGA | dH (nm) | 5.4 | **7.5** | 0.985 | **0.964** |
| PLGA | PdI | 0.033 | **0.047** | 0.849 | **0.560** |
| PLGA | EE (%) | 3.1 | **2.2** | 0.970 | **0.984** |

Cómo leerlo:
- **Tamaño (dH)**: se predice **muy bien** en ambos grupos (r² test 0.92–0.96, error < 10 nm).
- **EE en PLGA**: excelente (r² 0.98). Tiene sentido físico: la curcumina es hidrofóbica y el PLGA también → la encapsulación es "limpia" y depende casi solo de cuánto PLGA hay por curcumina.
- **EE en lípidos**: **mala** (r² test 0.47). Razones según los autores: solo los liposomas llevan curcumina (las LNP están vacías, eso desbalancea los datos) y los liposomas no son el vehículo ideal para una molécula hidrofóbica.
- **PdI**: el punto débil (r² test 0.56–0.79). Hipótesis: las muestras polidispersas tienen PdI ruidoso porque la DLS se vuelve poco fiable. Lo comprueban: entrenando solo con monodispersas el RMSE de PdI baja a 0.019 (lípidos) y 0.040 (PLGA), versus 0.060 y 0.057 entrenando solo con polidispersas.

### Paso 7 – Experimentos de robustez (solo en el artículo publicado)
1. **% de entrenamiento** de 50 a 85 %, 10 particiones aleatorias: RMSE y r² se mantienen estables → según los autores, no hay sobreajuste.
2. **Tamaño de la base de datos** (submuestras de 50 a 230 mediciones, 20 semillas): con más datos baja la variabilidad, y **la curva no se aplana** → *todavía faltan datos*.
3. **Solo liposomas**: un modelo solo para liposomas es mejor que el combinado LNP+liposomas (dH r² 0.871, PdI 0.824, EE 0.920) → **se intercambia generalidad por precisión**.
4. **Modelo agnóstico** (lípidos + PLGA juntos; Tabla S3): dH y PdI aceptables (test: RMSE 11.1 nm, r² 0.923; RMSE 0.051, r² 0.822), pero **EE falla por completo** (test: RMSE 73.4 %, r² 0.070). Lípidos y PLGA encapsulan por mecanismos distintos.
5. **Costo computacional** (Tablas S6–S7): ~130–250 s y ~57–107 MB de RAM por modelo RF con grid search completo, en un portátil.

### Paso 8 – Interpretabilidad con SHAP
**SHAP** (SHapley Additive exPlanations) viene de la teoría de juegos: reparte la predicción de cada muestra entre las variables, diciendo cuánto "empujó" cada una hacia arriba o hacia abajo. Usan **KernelSHAP** (versión que funciona con cualquier modelo) sobre toda la base de datos.

Gráficos "beeswarm" (Figura 8): cada punto es una medición; la posición horizontal es cuánto aportó esa variable; el color es si el valor de la variable era alto o bajo.

| Grupo | Target | Variable más importante según SHAP |
|---|---|---|
| Lípidos | dH | **Concentración de colesterol**, luego FRR y TFR |
| Lípidos | PdI | **TFR y FRR** |
| Lípidos | EE | **Razón lípido total : curcumina** |
| PLGA | dH | **Concentración de PLGA** (6 veces más importante que la segunda, TFR) |
| PLGA | PdI | **Concentración de PLGA** |
| PLGA | EE | **Razón PLGA : curcumina** (los flujos casi no importan) |

En general coincide con Pearson. Los autores advierten que la importancia de las propiedades del fármaco (XlogP3, peso molecular, área polar) está **exagerada**, porque con un solo fármaco esas columnas son solo 0/1.

### Paso 9 – Validación con datos de la literatura (solo en el publicado)
Toman formulaciones de **otros artículos** que usaron el mismo equipo (NanoAssemblr) y sacan los valores de las figuras con GIMP (midiendo píxeles). Como los materiales no coinciden exactamente, agrupan por "clase" (todo PLGA es "PLGA", los lípidos se agrupan en helper / ionizable / PEG / esterol).
- **Lípidos**: el modelo **falla** (demasiada variedad de lípidos en la literatura).
- **PLGA**: acierta cuando el PLGA y los parámetros están **dentro del rango** de entrenamiento; falla con PLGA de otra proporción láctico:glicólico (75:25, 85:15).
- Conclusión: **el modelo interpola bien pero extrapola mal**.

### Paso 10 – Diseño inverso: usar el modelo para proponer una receta
Objetivo: partícula de **100 nm con PdI ≤ 0.25**.
1. Generan una **matriz de recetas candidatas**: para cada variable, **3 valores** equiespaciados entre su mínimo y su máximo; todas las combinaciones posibles.
2. Pasan todas por el **modelo de PdI** y se quedan solo con las de PdI predicho ≤ 0.25.
3. A esas les predicen **dH y EE**.
4. Ordenan por cercanía a 100 nm y escogen la mejor.

Recetas obtenidas (Tablas S3/S4 de tu SI):
- **Lípidos**: DSPC : DODAP : Colesterol : DSPE-PEG2k = 25.6 : 8.7 : 55.4 : 0.3, 9.56 mM, TFR 8, FRR 2:1 → una LNP "no convencional".
- **PLGA**: Resomer RG 504H 0.250 mM, TFR 13, FRR 5:1.

### Paso 11 – MicrofluidicML vs ChatGPT, Gemini y DeepSeek
Le pidieron a cada LLM la receta para una LNP y una PLGA de 100 nm, **fabricaron** lo que dijeron y midieron (Figura 9). Lo hicieron en dos rondas: 2023 (GPT-3.5, Bard) y 2025 (GPT-4o, Gemini Flash 2.0, DeepSeek-V3).

| Plataforma | LNP: dH (PdI) | PLGA: dH (PdI) |
|---|---|---|
| **MicrofluidicML** | **90 ± 5 nm (0.061)** | **97 ± 7 nm (0.218)** |
| Bard (2023) | 93 ± 7 nm (0.119) | 98 ± 1 nm (0.211) |
| GPT-3.5 (2023) | 160 ± 13 nm (0.150) | ❌ No formó partículas (PdI 0.920) – recomendó más solvente orgánico que agua |
| GPT-4o (2025) | 75 nm (0.121) | 146 nm (0.179) |
| Gemini Flash 2.0 (2025) | 85 nm (0.123) | 114 nm (0.105) |
| DeepSeek-V3 (2025) | 78 nm (0.139) | 90 nm (0.224) |

Lecciones:
- Bard **inventó referencias** (4 artículos que no existen) aunque sus recetas funcionaron.
- Los LLMs nuevos **convergen todos a la misma receta** (la LNP clásica de las vacunas: MC3:DSPC:Col:PEG = 50:10:38.5:1.5) porque repiten lo más frecuente en internet.
- MicrofluidicML: **sin alucinaciones**, datos propios (sin problemas éticos o de copyright), corre en un PC normal, y propone recetas originales, **pero** solo sabe lo que hay en sus datos y requiere que el usuario defina el espacio de búsqueda.

---

## 6. Conclusiones del paper

1. Un flujo de trabajo de ML **liviano y de código abierto** (R + tidymodels) predice bien las propiedades de nanopartículas hechas por microfluídica.
2. **Random Forest** fue el mejor en promedio entre 13 algoritmos.
3. Predice muy bien el **tamaño** (y la **EE en PLGA**), pero tiene dificultades con el **PdI** y con la **EE en liposomas**.
4. SHAP confirma lo que dice la química: la cantidad de material controla el tamaño en PLGA; la razón material:fármaco controla la EE.
5. El modelo **interpola, no extrapola**: falla con materiales o rangos que no vio.
6. Para diseño inverso compite con los mejores LLMs, sin inventar nada.
7. **Faltan datos**: el desempeño todavía mejora al agregar mediciones; el futuro es automatizar la producción y caracterización para hacer crecer la base.

---

## 7. Lectura crítica: limitaciones e inconsistencias que encontré

Estas observaciones sirven tanto para la sustentación ("leer críticamente") como para justificar el *gap*.

### 7.1 Limitaciones metodológicas (las importantes)
1. **Posible fuga de información (data leakage) por réplicas.** Hay 3 mediciones por formulación (567 = 189 × 3) y el split 85/15 se describe sobre **"todos los datos experimentales"** / mediciones (el SI final lo confirma: la Fig. S5 se titula "*Number of measurements in either the training data or testing data*"). Si las réplicas de **una misma receta** quedan unas en train y otras en test, el modelo "ve" la respuesta en el entrenamiento y el r² de prueba está **inflado**. Lo mismo pasa dentro de la 10-fold CV. El paper no dice que haya agrupado por formulación.
2. **Sin cuantificación de incertidumbre.** Las predicciones son un número puntual, sin intervalo. Para diseño inverso esto importa: "100 nm ± ¿cuánto?". Además, no comparan el error del modelo con el **ruido experimental** de las réplicas (p. ej., PdI de LNP = 0.201 ± 0.056: si la propia medición varía ±0.056, ningún modelo puede bajar mucho de ahí).
3. **Comparación de algoritmos sin pruebas estadísticas.** RF, bagged trees, kNN y XGBoost están dentro de la desviación estándar unos de otros. Elegir "el mejor" por promedio no es concluyente.
4. **PdI tratado como regresión**, aunque en la práctica se usa como un **filtro sí/no** (≤ 0.25). Un **clasificador** monodisperso/polidisperso es más natural (y su propio trabajo previo, Di Francesco 2023, lo hizo así).
5. **SHAP con variables muy correlacionadas.** Como en LNP y liposomas la proporción entre lípidos es fija, todas las concentraciones individuales suben y bajan juntas. Entonces "el colesterol es lo que más importa para el tamaño" puede ser un **artefacto**: el colesterol funciona como un *proxy* de la concentración total y/o del tipo de partícula (38.5 % en LNP vs 30 % en liposomas). KernelSHAP asume independencia entre variables, lo que agrava esto.
6. **Inflado posible del r² de EE.** Si las partículas vacías (EE = 0) entran al modelo de EE (sugiere que sí, porque XlogP3 aparece como importante en el SHAP de EE), separar "vacía vs cargada" es trivial con la columna 0/1 del fármaco, lo que infla el r².
7. **Espacio de diseño pequeño**: solo 3 niveles por variable (diseño factorial). El modelo nunca vio valores intermedios y el diseño inverso busca en una rejilla de **3 valores** por variable → casi solo explora puntos ya medidos o combinaciones de ellos.
8. **Inconsistencia rara en la EE de lípidos**: r² en CV = 0.929, pero r² en train = 0.668 y en test = 0.472. Que el r² en entrenamiento sea **más bajo** que en CV no es lo esperado y el paper no lo discute.
9. **Errores imposibles en el modelo agnóstico de EE** (Tabla S3): RMSE de 86 % (train) y 73 % (test) en una variable acotada entre 0 y 100 %, con r² ≈ 0. Predecir siempre el promedio daría un error menor. Esto apunta a un problema de preprocesamiento (escala, codificación de partículas vacías o *missing values*) más que a una limitación "física", como sugiere el paper.

### 7.2 Inconsistencias menores del texto
- TFR de PLGA: Tabla 1 dice 3, 6, 13; Métodos dice 4, 6, 13.
- pH del citrato: 3.5 (Tabla 1) vs 3.6 (Métodos).
- r² test dH lípidos: 0.922 (Tabla 2) vs 0.926 (texto).
- RMSE de EE en liposomas reportado como "11.1 ± 1 **nm**" (debería ser %).
- La fórmula del % de error usa $\hat y$ en el denominador en el preprint y $y$ en el publicado.
- El pie de la Figura 1 dice "grid search" + "stratified k-fold", mientras el texto dice "random search" en el screening.

### 7.3 Problema de reproducibilidad
- **Datos no públicos** y **código no publicado**. Esto en sí mismo es una limitación que vale la pena mencionar en la presentación.

---

## 8. El GAP: qué se puede resolver con ML clásico

Recuerda que la Parte D exige: **mismos datos**, **solo ML clásico**, **hipótesis explícita**, comparación contra la reproducción y discusión **física/química**.

### ⭐ Gap principal recomendado: Generalización real (partición por formulación) + incertidumbre

**Qué no respondió el paper:**
El paper reporta r² de prueba de hasta 0.98, pero los datos de entrenamiento y prueba parecen compartir **réplicas de las mismas recetas**. Entonces no se sabe **qué tan bien predice el modelo una receta que nunca ha visto** (que es justo lo que se necesita para diseñar formulaciones nuevas). Además, sus predicciones no traen ninguna medida de confianza.

**Qué propongo hacer:**
1. **Repetir el entrenamiento con partición por grupo** (*GroupKFold* / *leave-one-formulation-out*), donde todas las réplicas de una misma formulación quedan juntas en train o en test. Comparar el RMSE/r² con el split aleatorio del paper.
2. **Extrapolación controlada**: dejar fuera un nivel completo de una variable (p. ej., entrenar con TFR bajo y medio y probar con TFR alto; o *leave-one-particle-type-out* entre LNP y liposomas).
3. **Cuantificar la incertidumbre** con **regresión cuantílica (Quantile Random Forest)**, **procesos gaussianos** o **bootstrap**, y comparar el ancho de los intervalos con el **ruido experimental de las réplicas** (el "piso" de error irreducible).
4. **Aplicación**: hacer el diseño inverso de 100 nm, pero ahora reportando la probabilidad de que la receta realmente quede entre, por ejemplo, 90 y 110 nm.

**Hipótesis explícita:**
> *H1: Al particionar por formulación (y no por medición), el desempeño del Random Forest en prueba bajará de forma significativa, sobre todo en PdI y en la EE de lípidos, lo que indica que parte del desempeño reportado se debe a fuga de información entre réplicas.*
> *H2: El error del modelo para dH en PLGA quedará cerca del ruido experimental entre réplicas, mientras que para PdI estará muy por encima.*

**Por qué es relevante física/químicamente:** en el laboratorio, el modelo se usaría para recetas **nuevas**, no para repetir las mismas. Saber el error real y la incertidumbre dice si el modelo realmente puede reemplazar experimentos. Comparar con la variabilidad entre réplicas separa lo que es "error del modelo" de lo que es "ruido de la DLS".

**Por qué es viable con el dataset:** solo requiere la columna que identifica la formulación (que se obtiene agrupando filas con las mismas TFR, FRR, concentraciones y razón fármaco) y algoritmos clásicos (RF, GP, QRF, bootstrap). No necesita datos externos.

Tipos de gap de las instrucciones que cubre: **Generalización** + **Incertidumbre** (+ opcionalmente **Diseño inverso**).

### Gaps alternativos (por si prefieres otro enfoque o para complementar)

| Gap | Idea | Tipo (según instrucciones) |
|---|---|---|
| **B. PdI como clasificación** | Convertir PdI en mono/polidisperso (umbral 0.25) y comparar clasificadores (RF, regresión logística, SVM, XGBoost) con AUC/accuracy; manejar el desbalance de clases. Es como se usa en el diseño inverso. | Reformulación + Desbalance |
| **C. Comparación estadística de algoritmos** | Validación cruzada **repetida** (p. ej. 10×10) y pruebas de significancia (Friedman + Nemenyi, o t-test corregido de Nadeau-Bengio) para ver si RF es realmente mejor que bagged trees/XGBoost/kNN. | Comparación de algoritmos |
| **D. Variables con significado físico** | Reemplazar las concentraciones individuales (muy correlacionadas) por variables físicas: concentración final tras la mezcla = C·1/(1+FRR), fracción de solvente orgánico = 1/(1+FRR), tipo de partícula, caudales de cada fase. Ver si mejora el modelo y si cambia el SHAP (¿el "colesterol" deja de ser el más importante?). | Ingeniería de variables + Interpretabilidad |
| **E. Interpretabilidad robusta** | Comparar KernelSHAP con TreeSHAP, importancia por permutación y dependencia parcial (PDP/ALE), y contrastar con la física de la nanoprecipitación. | Interpretabilidad |
| **F. Eficiencia de datos** | Curvas de aprendizaje y simular **aprendizaje activo** (¿cuántos experimentos se necesitan si se eligen los más informativos en vez de una rejilla completa?). Muy relacionado con la conclusión del paper de que "faltan datos". | Eficiencia de datos |

Mi recomendación: **gap principal (Generalización + Incertidumbre)**, y si hay tiempo complementarlo con **D (variables físicas)** porque da mucha discusión química para la sustentación.

---

## 9. Qué reproducir (Parte B) – sugerencia de alcance

Propuesta de **reproducción parcial bien delimitada**:
- **Resultado a reproducir**: la **Tabla 2** (RMSE y r² del Random Forest en train y test) para **las nanopartículas de PLGA** (dH, PdI y EE), y si da el tiempo también para lípidos.
- **Resultado secundario**: la comparación de algoritmos de la **Tabla S2 del SI final** (13 modelos, PLGA; números en media ± DE de 10-fold CV), al menos para RF, XGBoost, bagged trees, kNN, SVM radial y lineal.
- **Por qué PLGA**: es el subconjunto más grande (324 mediciones), un solo material, sin mezclar arquitecturas, y con los resultados más limpios. Es el punto de partida más reproducible.
- **Herramientas**: Python + scikit-learn (o R + tidymodels, como el paper). Supuestos que hay que documentar porque el paper no los da: semillas, rangos exactos de hiperparámetros, cómo se hizo la "estratificación" del split, y si las partículas vacías entran al modelo de EE.

---

## 10. Borrador para la diapositiva (Parte A)

> **Referencia:** Moore, T. L.; Pesce, C.; Greco, A.; Pisante, C.; Avancini, G.; Di Francesco, V.; Shamay, Y.; Decuzzi, P. *Unleashing the Power of Machine Learning in Nanomedicine Formulation Development.* **Adv. Funct. Mater.** 2026, 36, e14387. DOI: 10.1002/adfm.202514387 (preprint: ChemRxiv, DOI 10.26434/chemrxiv-2025-2lb14-v2).
> **Datos:** no públicos, "disponibles bajo petición razonable" al autor (thomaslee.moore@unina.it). *[Estado de la solicitud: pendiente]*
>
> **Pregunta:** ¿Se pueden predecir el tamaño (dH), la polidispersidad (PdI) y la eficiencia de encapsulación (EE) de nanopartículas hechas por microfluídica a partir de los parámetros de fabricación, usando ML clásico y una base de datos propia, y usar esos modelos para diseñar recetas? **Relevancia:** hoy esto se hace por prueba y error, y las propiedades de las nanopartículas determinan su efecto biológico.
>
> **Datos:** 189 formulaciones × 3 réplicas = 567 mediciones (LNP, liposomas, PLGA; vacías o con curcumina). **X:** TFR, FRR, concentración de cada reactivo, razón material:fármaco, propiedades del fármaco. **y:** dH (nm), PdI, EE (%). Regresión.
>
> **Reproducir:** Tabla 2 (RF optimizado, RMSE y r² en train/test) para PLGA, + Tabla S2 (13 algoritmos).
>
> **Gap inicial:** el split aleatorio por medición puede mezclar réplicas de la misma receta en train y test → r² optimista. Propuesta: partición por formulación + extrapolación + cuantificación de incertidumbre (Quantile RF / GP / bootstrap), comparando con el ruido experimental entre réplicas.

---

## 11. Mini-glosario

| Término | Explicación corta |
|---|---|
| **Nanomedicina** | Medicamento transportado dentro de una partícula de tamaño nanométrico |
| **LNP** | Nanopartícula lipídica; tipo usado en vacunas de ARNm; aquí vacías |
| **Liposoma** | Esfera hueca con una pared de lípidos (como una célula diminuta) |
| **PLGA** | Polímero biodegradable aprobado para uso médico |
| **Curcumina** | Fármaco modelo, hidrofóbico, fácil de medir por color |
| **Microfluídica** | Fabricar mezclando líquidos en canales sub-milimétricos |
| **TFR** | Caudal total que pasa por el chip (mL/min) |
| **FRR** | Proporción de flujo acuoso : orgánico |
| **DLS** | Técnica con láser para medir tamaño y PdI |
| **dH** | Diámetro hidrodinámico (tamaño) |
| **PdI** | Qué tan variados son los tamaños (0 = todos iguales) |
| **EE** | % de fármaco que quedó encapsulado |
| **Monodisperso / polidisperso** | PdI ≤ 0.25 / PdI > 0.25 |
| **Random Forest** | Promedio de muchos árboles de decisión entrenados con variaciones aleatorias |
| **k-fold CV** | Dividir los datos en k partes, entrenar con k−1 y evaluar con la restante, k veces |
| **Grid / random search** | Probar todas las combinaciones / combinaciones al azar de hiperparámetros |
| **RMSE** | Error típico de la predicción, en unidades de la variable |
| **r²** | Fracción de la variabilidad explicada por el modelo (1 = perfecto) |
| **SHAP** | Método que reparte cada predicción entre las variables para explicar el modelo |
| **Pearson** | Correlación lineal entre dos variables (−1 a 1) |
| **Data leakage** | Cuando información de la prueba se "cuela" en el entrenamiento e infla las métricas |
| **LLM** | Modelo de lenguaje grande (ChatGPT, Gemini, DeepSeek) |
