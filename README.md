# Inkling 2 Mini en una gráfica de 12 GB

Guía de **Inkling 2 Mini IQ4_NL en Windows**, con **llama.cpp**, **Llama UI** y **65.536 tokens de contexto**. Incluye la instalación desde cero, un lanzador de doble clic y las tres pruebas del vídeo con sus prompts originales.

En la RTX 5070 del vídeo, el modelo generó entre **28,7 y 31,2 tokens por segundo**. Para abrir el GGUF en una gráfica de 12 GB, el perfil guarda parte de los expertos en la RAM del ordenador.

## Índice

- [Antes de empezar](#antes-de-empezar)
- [Qué es Inkling 2 Mini](#qué-es-inkling-2-mini)
- [Instalación y arranque](#instalación-y-arranque)
- [Configuración de 64K](#configuración-de-64k)
- [Pruebas del vídeo](#pruebas-del-vídeo)
- [Resultados](#resultados)
- [Solución de problemas](instalacion/windows.md#solución-de-problemas)
- [Licencias](#licencias)

## Antes de empezar

Para seguir esta guía, prepara **Windows de 64 bits para PC (x64)**, una **GPU NVIDIA compatible con el paquete CUDA 13.5**, su controlador actualizado y, como referencia, **25 GB libres en disco y 64 GB de RAM**. Puedes comprobar la arquitectura y la RAM en **Configuración → Sistema → Información**. La instalación usa PowerShell, la aplicación de Windows en la que pegarás los comandos. El [paso a paso](instalacion/windows.md) indica dónde abrirla.

La **VRAM** es la memoria de la gráfica. La **RAM** la comparten el sistema, las aplicaciones y los componentes del modelo que ejecuta la CPU. El archivo **GGUF** contiene los pesos del modelo en el formato que lee llama.cpp. **IQ4_NL** es la variante cuantizada de esta guía, que reduce el espacio que ocupan los pesos.

| Equipo del vídeo | Configuración |
|---|---|
| Sistema | Windows 11 Pro x64 |
| Procesador y memoria | AMD Ryzen 9 5900X y 64 GB de RAM DDR4 a 3600 MT/s |
| Gráfica de inferencia | NVIDIA GeForce RTX 5070 de 12 GB |
| Gráfica del escritorio y otras aplicaciones | NVIDIA GeForce RTX 5060 Ti. Queda fuera de la inferencia |
| Motor y controlador | llama.cpp **b12676**, paquete **CUDA 13.5 x64**, controlador NVIDIA **621.40** |

Con unos **9,9 GiB ocupados de 11,9 GiB** en la RTX 5070, el monitor mostraba aproximadamente **2 GiB de margen**. En un equipo con una sola tarjeta para el escritorio y el modelo, ese margen puede ser menor. El controlador y las aplicaciones también ocupan memoria. Los 64 GB de RAM son la configuración probada. El mínimo para este perfil depende de la memoria disponible en cada equipo.

## Qué es Inkling 2 Mini

Inkling 2 Mini es un modelo de Thinking Machines Lab con arquitectura **MoE**, siglas en inglés de *mezcla de expertos*. Cuando procesa un token, que puede ser una palabra, parte de ella o un signo, un mecanismo selecciona qué grupos de pesos de cada capa intervienen. Ese grupo puede cambiar con el siguiente token, de modo que el equipo necesita poder acceder a todos los expertos a lo largo de la conversación.

El modelo tiene **26.400 millones de parámetros**, con **3.400 millones activos** según su ficha. Repite el paso por algunas capas intermedias tres veces por token, lo que eleva las activaciones efectivas al equivalente de unos **5.400 millones de pesos por token**. El perfil de esta guía está dedicado al texto. [Ficha del modelo](https://huggingface.co/thinkingmachines/Inkling-2-Mini) · [Descripción de la arquitectura](https://thinkingmachines.ai/news/inkling-2-mini/)

## Instalación y arranque

1. Sigue la [instalación para Windows](instalacion/windows.md). Descargarás dos ZIP de llama.cpp y el GGUF de ggml-org. Los comandos comprueban la integridad de cada archivo.
2. Haz doble clic en `scripts\iniciar-inkling.bat`. Cuando termine la carga, abre [Llama UI en el navegador](http://127.0.0.1:8080/).
3. Envía un primer mensaje corto para comprobar que responde. Abre un chat nuevo para cada prueba. Para cerrar el servidor, vuelve a su ventana y pulsa **Ctrl+C**.

llama.cpp es el programa que carga el modelo y genera las respuestas. **Llama UI** es el chat integrado en ese mismo programa. Tras descargar los archivos, la conversación se ejecuta en tu ordenador.

## Configuración de 64K

El lanzador reserva **65.536 tokens para un solo chat**, selecciona una GPU, activa **Flash Attention**, usa **Q4_0** para ambas partes de la caché KV y deja los expertos de **11 bloques** en RAM. Consulta [los argumentos, sus valores y su efecto](configuracion/perfil-64k.md).

## Pruebas del vídeo

En el [procedimiento de reproducción](pruebas/README.md) encontrarás cómo pegar los prompts, cómo cargar el documento exacto de la tercera prueba y dónde leer las métricas.

1. [Explicación de la IA generativa](pruebas/01-ia-generativa.txt).
2. [Optimización de servicios con 300 euros](pruebas/02-presupuesto.txt).
3. [Análisis de la Constitución Española](pruebas/03-constitucion.txt).

## Resultados

| Prueba | Tokens de entrada | Entrada (tokens/s) | Generación (tokens/s) | Tokens generados | VRAM RTX 5070 | RAM del sistema |
|---|---:|---:|---:|---:|---:|---:|
| IA generativa | 91 | 48,1 | 31,2 | 2.363 | 9,9 GiB | 30,0 GiB |
| Presupuesto | 180 | 74,8 | 31,1 | 3.542 | 9,9 GiB | 30,7–30,8 GiB |
| Constitución Española | 29.599 | 162,0 | 28,7 | 3.251 | 9,9 GiB¹ | 31,6 GiB¹ |

La velocidad de **entrada** mide la lectura del prompt y sus adjuntos. La de **generación** mide la producción de tokens, incluidos el razonamiento mostrado por separado y la respuesta final. Las cifras de memoria son lecturas del equipo al final de las pruebas e incluyen otros procesos.

¹ Lectura del monitor al cierre del clip. La memoria se toma del monitor y las velocidades y los recuentos se toman de Llama UI por petición. En la tercera prueba se procesaron **29.587 tokens nuevos** y se reutilizaron **12** de la caché. Sumados a los **3.251** generados, dan **32.850 de 65.536 tokens**, aproximadamente el 50 % de la ventana.

- **IA generativa.** Elaboró una explicación extensa con ejemplos cotidianos y repasó las aplicaciones y limitaciones.
- **Presupuesto.** Encontró la solución óptima, **B + D + E**, por **300 €** y **16 puntos**.
- **Constitución.** Acertó en lo esencial y cometió errores al citar un apartado y al atribuir una competencia. La [revisión de las respuestas](pruebas/README.md#qué-comprobar-en-las-respuestas) detalla ambos casos.

Son tres pruebas de una grabación. Sirven para ver cómo se comporta este perfil en ese equipo. La velocidad depende del texto, la GPU, el procesador, la RAM y las aplicaciones abiertas. Para comparar con Qwen3.8 hacen falta condiciones y pruebas equivalentes.

## Licencias

La guía, los prompts y el lanzador se publican bajo [MIT](LICENSE). El texto del BOE se distribuye con sus [condiciones de reutilización](https://www.boe.es/informacion/aviso_legal/). El modelo Inkling 2 Mini está bajo Apache 2.0 y llama.cpp bajo su propia licencia MIT. [Licencia en la ficha del modelo](https://huggingface.co/thinkingmachines/Inkling-2-Mini) · [Licencia de llama.cpp](https://github.com/ggml-org/llama.cpp/blob/b12676/LICENSE)
