# Perfil de 64K

[Volver a la guía](../README.md)

El [lanzador](../scripts/iniciar-inkling.bat) reproduce los ajustes del perfil **64K OPT** con rutas relativas y un servidor para un solo modelo. Los argumentos corresponden a **llama.cpp b12676** con CUDA 13.5.

| Argumentos del lanzador | Qué hacen |
|---|---|
| `--ctx-size 65536 --parallel 1` | Reservan la ventana de 65.536 tokens para una sola sesión simultánea. El historial, el documento, el prompt y la respuesta comparten ese espacio. |
| `--device CUDA0 --main-gpu 0 --split-mode none` | Seleccionan una sola GPU de cálculo. La instalación explica cómo localizarla con `--list-devices`. |
| `--n-gpu-layers 99 --fit off` | Piden colocar en GPU todas las capas que admita el modelo, salvo los tensores que se envían a la CPU con la regla siguiente. Desactivan el ajuste automático del perfil para que se respete la configuración elegida. |
| `--override-tensor "blk\.([0-5]\|19\|2[0-3])\.ffn_.*_exps\.weight=CPU"` | Coloca los pesos de los expertos de los bloques **0 a 5 y 19 a 23** en RAM. La regla se aplica a los tensores con nombres de expertos en esos bloques. La CPU realiza esa parte del trabajo. |
| `--no-op-offload` | Desactiva la descarga a GPU de operaciones de tensores alojados en la CPU. |
| `--flash-attn on` | Activa Flash Attention, una forma de calcular la atención con menos memoria temporal. |
| `--cache-type-k q4_0 --cache-type-v q4_0` | Guarda las claves y los valores de la caché KV en formato cuantizado de 4 bits. La caché permite reutilizar cálculos del contexto y ocupa menos memoria que con valores de 16 bits. La cuantización también puede afectar a la precisión. |
| `--batch-size 256 --ubatch-size 64` | El servidor puede agrupar hasta 256 tokens y enviarlos al motor en tandas de hasta 64. El tamaño de la tanda afecta a la velocidad de lectura del prompt y a la memoria de trabajo. |
| `--spec-type none` | Desactiva la aceleración especulativa. El perfil genera con Inkling sin métodos de borrador como MTP o DSpark. |
| `--jinja --no-mmproj --no-agent` | Usa la plantilla de chat incluida en el GGUF, omite el proyector para entradas multimedia y desactiva el modo agente. |
| `--host 127.0.0.1 --port 8080 --cors-origins localhost` | Abre la interfaz integrada únicamente en este ordenador, en el puerto indicado, y conserva la restricción del perfil para peticiones de otros orígenes web. |

## Generación y razonamiento

El perfil de la grabación deja que llama.cpp aplique los valores del GGUF y de su plantilla de chat. Se usó Llama UI con el mensaje de sistema vacío y los ajustes de muestreo sin personalizar.

| Ajuste | Valor del perfil |
|---|---|
| Temperatura | **1,0**. Controla la variación de las respuestas. |
| Top-k | **50**. Limita la selección a los 50 candidatos con más probabilidad. |
| Top-p | **1,0**. Deja sin recorte el filtro por probabilidad acumulada. |
| Min-p | **0,0**. Deja desactivado el filtro de probabilidad relativa mínima. |
| Penalización por repetición y semilla | **1,0** y **aleatoria**. El perfil conserva la penalización neutra y la semilla por defecto de llama.cpp. |
| Razonamiento | Activación y formato **automáticos**. La plantilla del GGUF usa un esfuerzo de **0,9** por defecto. El servidor conserva el presupuesto de razonamiento **sin límite específico**. Llama UI muestra el bloque de razonamiento aparte cuando lo recibe. |
| Límite de generación | El perfil conserva `--n-predict -1`. La generación puede terminar al detectar el final de la respuesta, al agotar la ventana o al detenerla manualmente. |

La semilla aleatoria y los cambios de equipo pueden dar respuestas diferentes. La plantilla puede producir texto de razonamiento antes de la respuesta visible. Ambos cuentan como tokens generados.

[Documentación del servidor y los argumentos de b12676](https://github.com/ggml-org/llama.cpp/blob/b12676/tools/server/README.md) · [Código de lectura de los metadatos de muestreo](https://github.com/ggml-org/llama.cpp/blob/b12676/common/common.cpp)
