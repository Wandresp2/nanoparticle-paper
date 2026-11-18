# Parte D · Diseño experimental (registrado antes de ejecutar)

> **Para qué sirve:** fija las hipótesis, el diseño y los **criterios de aceptación o rechazo** de la Parte D **antes** de correr los experimentos, como exigen las instrucciones (*"hipótesis explícita, formulada antes de los experimentos"*).
>
> - Escrito el **17-nov-2026**, antes de ejecutar `notebooks/Parte_D_nuevo_trabajo.ipynb`.
> - Si algo de este documento cambia después de ver resultados, el cambio se anota en §9 con su motivo. Los criterios de §5 **no se ajustan** a los resultados.

---

## 1. Pregunta

**¿Qué tan bien predice el Random Forest del paper el tamaño (dH), la polidispersidad (PdI) y la encapsulación (EE) de una receta que nunca vio?** ¿Y cuánta confianza se puede poner en cada predicción?

Viene del gap de la Parte C: el paper separa entrenamiento y prueba **por medición**. Entre el 83 y el 100 % de las filas de prueba tienen una réplica de su misma receta en entrenamiento, y un "memorizador" que no aprende nada alcanza casi el mismo r² que el RF.

## 2. Decisiones de diseño (tomadas por el estudiante el 17-nov-2026)

| # | Decisión | Elegido |
|---|---|---|
| 1 | Alcance | H1 + H2 + H3. Quedan fuera, como extras opcionales, la extrapolación por nivel de TFR/FRR o por tipo de partícula y las variables con significado físico |
| 2 | Qué se predice | **Cada medición** (las 3 réplicas por separado), igual que el paper. Así, frente a la Parte B, solo cambia la forma de separar los datos |
| 3 | Repetición de la partición | **100 separaciones entrenamiento/prueba** por esquema, con la misma proporción del autor (85/15) |
| 4 | Hiperparámetros | **Fijos**: los que eligió la Parte B para cada modelo. Control con ajuste anidado en un objetivo (§6.1) |
| 5 | Criterios de las hipótesis | Fijados en §5 |
| 6 | Incertidumbre | **Intervalos conformales calibrados por receta** (implementación propia), con Quantile Random Forest como comparación |
| 7 | Modelos de referencia | RF + **memorizador** + **regresión lineal** |
| 8 | Datos problemáticos | Experimento principal con **los mismos datos de la Parte B**. Las pruebas sobre EE van aparte, como sensibilidad (§6.2) |

## 3. Datos

- Tablas `datos_procesados/ml_lipidos.csv` (243 filas, 81 recetas) y `ml_plga.csv` (324 filas, 108 recetas), las mismas de la Parte B.
- Los mismos 6 modelos: {lípidos, PLGA} × {dH, PdI, EE}.
  - En dH se filtra PdI ≤ 0.25, como el autor. Por eso quedan 150 filas (58 recetas) en lípidos y 227 (87) en PLGA.
- Los predictores son los mismos de la Parte B. `meta_formulation_id` **no es predictor**: solo se usa para agrupar las réplicas.

## 4. Experimentos

### 4.1 Los dos esquemas de partición (H1)

Se repiten **100 veces** (semillas 0 a 99) para cada uno de los 6 modelos.

| Esquema | Cómo se separa | Relación con trabajos anteriores |
|---|---|---|
| **Por medición** (el del paper) | 85 % de las **filas** a entrenamiento, estratificado por cuartiles del objetivo. Es la emulación de `initial_split` de la Parte B | Con las semillas 0–99 se obtienen exactamente las mismas particiones que las 100 primeras simulaciones de la Parte C |
| **Por receta** (propuesto) | 85 % de las **recetas** a entrenamiento, estratificado por cuartiles del **promedio de la receta**. Las réplicas de una receta van siempre juntas | La misma regla del autor, aplicada a recetas en lugar de filas |

En cada repetición y esquema se ajustan:
- **RF:** `RandomForestRegressor`, 500 árboles, con el `mtry` y el `min_n` que eligió la Parte B para ese modelo (`resultados/parte_B/tabla2_rf_python.csv`). La tubería es la misma (`VarianceThreshold` → `StandardScaler` → modelo);
- **regresión lineal:** la misma tubería;
- **memorizador:** el promedio de las réplicas de la receta que están en entrenamiento; si no hay ninguna, la media global de entrenamiento. Con partición por receta se reduce siempre a la media global.

**Subproducto:** las 100 repeticiones por medición dan la **"Tabla 2 con muchas semillas"**, que quedó como opcional en la Parte B. Confirman con el RF real lo que en `docs/reproduccion_paper.md` §5.3 se aproximó con el memorizador.

### 4.2 Experimento controlado de fuga (H1, prueba pareada exacta)

La comparación de §4.1 usa filas de prueba distintas en cada esquema. Para aislar **solo** el efecto de la fuga se hace además un experimento pareado:

1. se toman las recetas de prueba de la partición por receta;
2. de cada una se elige **una réplica al azar** como fila de prueba;
3. se entrenan dos RF con el mismo entrenamiento base (todas las filas de las demás recetas). La única diferencia es que el modelo **"con fuga"** recibe además las otras réplicas de las recetas de prueba.

Las filas de prueba son **idénticas** en los dos modelos, así que la diferencia de error se debe solo a haber visto las réplicas.

### 4.3 Error frente al ruido experimental (H2)

**SD entre réplicas (agrupada)** de cada modelo, calculada como en la Parte C (`resultados/parte_C/evidencia3_ruido_replicas.csv`):

√( Σ (medición − promedio de su receta)² / (n − n.º de recetas) )

Se calcula el cociente **RMSE de prueba / SD agrupada** en cada repetición. Un cociente de 1 significa que el modelo se equivoca tanto como difieren entre sí dos mediciones de la misma receta.

### 4.4 Incertidumbre (H3)

Se evalúa solo con la **partición por receta**, que es la situación de uso real. En cada repetición se construyen tres intervalos al **90 %** para cada fila de prueba:

| Método | Cómo se construye | Papel |
|---|---|---|
| **Conformal calibrado por receta** (principal) | 1. Dentro del entrenamiento, validación cruzada por grupos (`GroupKFold`, 5 folds) con el mismo RF. 2. Se calculan los residuos absolutos fuera de fold. 3. Se toma q̂ = su cuantil ⌈(n+1)·0.9⌉/n. 4. El intervalo es la predicción del RF entrenado con todo ± q̂ | Respeta la estructura de recetas |
| **Conformal calibrado por medición** | Igual, pero con `KFold` sobre **filas** (la validación del paper) | Muestra si calibrar con fuga da intervalos demasiado estrechos |
| **Quantile Random Forest** (Meinshausen, 2006) | Implementación propia sobre el mismo RF. Cada fila de entrenamiento recibe un peso según con qué frecuencia cae en la misma hoja que la fila de prueba; el intervalo son los cuantiles ponderados 5 % y 95 % | Comparación con el método sugerido en la Parte C |

**Métricas:**
- **Cobertura:** % de mediciones de prueba que caen dentro del intervalo;
- **ancho medio**;
- **ancho relativo al ruido** = ancho medio / (2 · 1.645 · SD agrupada). Es el ancho del intervalo dividido por el de un intervalo al 90 % que solo tuviera en cuenta el ruido entre réplicas.

### 4.5 Métricas generales

Las métricas generales son:
- **r² = correlación²**, la definición del autor (`rsq`): es la principal, para comparar con la Tabla 2;
- **r² = 1 − SSE/SST:** penaliza el sesgo y puede ser negativo;
- **RMSE.**

Se resumen con la **mediana** y el rango del 90 % central (percentiles 5–95) de las 100 repeticiones.

## 5. Hipótesis y criterios de decisión (fijados antes de ejecutar)

Los enunciados de H1–H3 son los de la Parte C (`notebooks/Parte_C_gap.ipynb`, §5). Aquí se vuelven **operativos**.

### H1. Generalización a recetas nuevas

> Con partición por receta, el r² de prueba del RF **baja** frente a la partición por medición, sobre todo en **PdI** y en **dH de lípidos**. El RMSE de prueba sube, como mínimo, hasta superar el ruido entre réplicas.

| Parte | Criterio | Se acepta si… |
|---|---|---|
| H1a: el r² baja | Diferencias por repetición d = r²(medición) − r²(receta). Prueba *t* corregida de Nadeau y Bengio (2003)¹ y prueba de Wilcoxon de rangos con signo, con corrección de Holm para los 6 modelos | mediana de d > 0 **y** p de Holm < 0.05 (*t* corregida) |
| H1b: sobre todo PdI y lípidos · dH | Orden de las 6 caídas medianas de r² | lípidos · PdI, PLGA · PdI y lípidos · dH son las **3 caídas más grandes** |
| H1c: el RMSE supera el ruido | RMSE de prueba mediano con partición por receta | RMSE > SD agrupada |
| H1-control: fuga aislada (§4.2) | Diferencia pareada de RMSE (sin fuga − con fuga), con las mismas filas de prueba. Wilcoxon con corrección de Holm | mediana > 0 **y** p de Holm < 0.05 |

¹ Corrige la varianza por el solapamiento entre entrenamientos de distintas repeticiones: t = media(d) / √((1/J + n_prueba/n_entren.) · var(d)), con J = 100 y J − 1 grados de libertad. Es conservadora. **Supuesto:** en §4.1 se emparejan las repeticiones por su número de semilla, aunque las filas de prueba no coincidan entre esquemas. El experimento pareado exacto es el de §4.2.

### H2. Error frente al ruido experimental

> Con la partición por receta, el error del RF en **dH y EE de PLGA** se mantiene en el orden del ruido entre réplicas; en **PdI** queda claramente por encima.

| Modelo | Se acepta si la mediana del cociente RMSE / SD agrupada (partición por receta)… |
|---|---|
| PLGA · dH y PLGA · EE | es **≤ 1.5** en los dos |
| Lípidos · PdI y PLGA · PdI | es **> 2** en los dos |

H2 se acepta si se cumplen las dos filas. Si solo se cumple una, se acepta parcialmente.

### H3. Incertidumbre

> Los intervalos de incertidumbre, evaluados con partición por receta, tienen **cobertura cercana a la nominal** en dH de PLGA y son **más anchos** (en relación con el ruido) en PdI y en lípidos.

| Parte | Criterio (intervalo conformal calibrado por receta, 90 %) | Se acepta si… |
|---|---|---|
| H3a: cobertura en PLGA · dH | Cobertura media en las 100 repeticiones | está entre **85 % y 95 %** |
| H3b: más anchos en PdI y lípidos | Ancho relativo al ruido (mediana) | los 2 modelos de PdI y los 3 de lípidos tienen un ancho relativo **mayor** que PLGA · dH |
| H3c (expectativa secundaria, derivada del gap) | Cobertura del conformal **calibrado por medición** | queda **por debajo de 85 %** en al menos 3 de los 6 modelos (la fuga hace que los intervalos sean demasiado optimistas) |

El QRF se reporta como comparación, sin un criterio propio.

## 6. Controles y sensibilidad

### 6.1 Control de hiperparámetros (decisión 4)

**Duda:** ¿la caída de H1 se debe a que los hiperparámetros se eligieron con validación por medición, y por eso favorecen la memorización (`min_n = 2`)?

**Control:** en **PLGA · PdI** (el modelo con más recetas y el más difícil) se repiten **20** de las particiones por receta. En cada una se ajustan los hiperparámetros por validación cruzada anidada por grupos:
- `GroupKFold` de 5 folds dentro del entrenamiento;
- `mtry` de 1 a p;
- `min_n` ∈ {2, 5, 10, 20, 40};
- 300 árboles durante la búsqueda y 500 en el modelo final.

**Conclusión:** si la mejora mediana de r² del RF ajustado frente al RF fijo es **< 0.05**, se concluye que los hiperparámetros fijos no explican el resultado de H1.

### 6.2 Sensibilidad de EE (decisión 8)

Hay que tener en cuenta dos hechos sobre la EE:
- en lípidos, **162 de las 243 filas tienen EE = 0** porque no llevan fármaco: todas las LNP y la mitad de los liposomas. En PLGA son 81 de 324;
- en todos los casos, "sin fármaco" equivale exactamente a EE = 0.

Un modelo puede obtener un r² alto solo aprendiendo esa regla. Por eso se repiten los dos esquemas de §4.1 (100 repeticiones, RF) en dos variantes:

| Variante | Qué cambia |
|---|---|
| **Solo recetas con fármaco** | Lípidos: 81 filas, 27 recetas (liposomas con curcumina). PLGA: 243 filas, 81 recetas |
| **EE recortada a 100 %** | Lípidos: 9 mediciones de liposomas con EE > 100 % se fijan en 100. En PLGA no hay casos |

Estas variantes son **exploratorias**: no tienen un criterio de aceptación.

## 7. Qué no se hace (fuera de alcance, posibles extras)

- Extrapolación por nivel completo de TFR, FRR o concentración, y *leave-one-particle-type-out*.
- Variables con significado físico (fracción de solvente, concentración final…).
- Comparar los 13 algoritmos con partición por receta.

## 8. Reproducibilidad

- Semillas de partición 0–99. `random_state = 1987` en los modelos y en los folds internos.
- `N_JOBS = 6` (límite de memoria del equipo de 16 GB).
- Salidas en `resultados/parte_D/`.
- El veredicto de cada hipótesis se calcula **en el notebook** a partir de los criterios de §5, no a mano.

## 9. Cambios respecto a este diseño

| Fecha | Cambio | Motivo |
|---|---|---|
| 17-nov-2026 | **Ningún cambio de diseño ni de criterios.** Solo el tiempo real fue distinto: 57 min frente a los ~25 estimados | La estimación salió de una prueba de 3 repeticiones |

## Referencias

- Nadeau, C.; Bengio, Y. *Inference for the Generalization Error.* Machine Learning 2003, 52, 239–281.
- Meinshausen, N. *Quantile Regression Forests.* Journal of Machine Learning Research 2006, 7, 983–999.
- Vovk, V.; Gammerman, A.; Shafer, G. *Algorithmic Learning in a Random World.* Springer, 2005 (predicción conformal).
- Barber, R. F.; Candès, E. J.; Ramdas, A.; Tibshirani, R. J. *Predictive inference with the jackknife+.* Annals of Statistics 2021, 49, 486–507 (variantes por validación cruzada).
