# Cómo reproducir las tres pruebas

[Volver a la guía](../README.md) · [Ver la tabla de resultados](../README.md#resultados)

Arranca el [perfil de 64K](../configuracion/perfil-64k.md) y abre Llama UI. Usa un **chat nuevo** para cada prueba. Deja vacío el mensaje de sistema y conserva los valores de muestreo y razonamiento del perfil. En los ajustes de la interfaz, comprueba que **Always show message statistics** está activado para ver los tokens y la velocidad.

## 1. Explicar la IA generativa

Abre [el enunciado original](01-ia-generativa.txt) en el Bloc de notas. Pulsa **Ctrl+A** y **Ctrl+C** para copiarlo. Pégalo en el cuadro de mensaje de Llama UI y envíalo. La tarea pide una explicación de unas 1.000 palabras con ejemplos cotidianos.

## 2. Elegir servicios con 300 euros

Abre otro chat. Copia [el enunciado original](02-presupuesto.txt), pégalo y envíalo. Comprueba la combinación, el coste y la demostración de que ninguna alternativa válida obtiene una puntuación mayor.

## 3. Analizar la Constitución Española

1. Abre otro chat. Abre en el Bloc de notas [el documento exacto utilizado en el vídeo](constitucion-boe-2026-05-20.txt), incluido en la descarga del repositorio.
2. Copia todo el documento. En Llama UI, pega el texto en el cuadro de mensaje **sin enviarlo todavía**. La interfaz convierte el texto largo en una tarjeta de adjunto llamada **Pasted** con el valor de fábrica. Si se pega en el cuadro como un mensaje enorme, pon **2.500 caracteres** en el ajuste **Paste long text to file length**.
3. Con la tarjeta aún en el cuadro, copia y pega [el enunciado de las cuatro preguntas](03-constitucion.txt). Envía un solo mensaje con **el documento adjunto y las preguntas escritas**.
4. Espera a que termine el procesamiento del documento y después la generación. En el vídeo fueron unos tres minutos de lectura y casi dos minutos de generación.

El adjunto conserva el texto tal como se pegó, incluido el encabezado y los rótulos del BOE. Cambiar la edición, usar un PDF o pegar el contenido con otro formato puede cambiar el número de tokens.

**Fuente de los datos:** [Agencia Estatal Boletín Oficial del Estado](https://www.boe.es/). Constitución Española, referencia BOE-A-1978-31229, última actualización publicada el **20 de mayo de 2026**. Es un texto consolidado de carácter meramente informativo. [Documento en el BOE](https://www.boe.es/buscar/act.php?id=BOE-A-1978-31229) · [Condiciones de reutilización](https://www.boe.es/informacion/aviso_legal/)

## Cómo medir

- **Entrada.** Mira las estadísticas bajo el mensaje enviado. Los tokens por segundo describen el trabajo sobre la parte de la entrada que procesó el servidor. Llama UI puede mostrar solo los tokens nuevos. Los [registros de tiempos por petición](../resultados/tiempos.json) incluyen también `cache_n`, el número reutilizado.
- **Salida.** Mira las estadísticas bajo la respuesta. Los tokens generados incluyen el razonamiento producido por el modelo y el texto final. Abrir o cerrar el desplegable **Reasoning** cambia lo que se ve en pantalla. El contador de generación sigue incluyendo ambos.
- **VRAM.** En otra ventana de PowerShell, ejecuta el comando de abajo. Localiza tu gráfica por nombre y anota `memory.used` al finalizar la respuesta. Los valores están en MiB. Puedes dividir por 1.024 para compararlos con los GiB de la tabla. Para detener el muestreo pulsa **Ctrl+C**.
- **RAM del sistema.** Abre **Administrador de tareas → Rendimiento → Memoria** y anota la memoria en uso al finalizar. Es una lectura de todo el equipo.

```powershell
nvidia-smi --query-gpu=name,memory.used,memory.total --format=csv -l 1
```

Puedes anotar también la VRAM y la RAM antes de arrancar para conocer el punto de partida. La diferencia es orientativa porque Windows y otras aplicaciones pueden cambiar su consumo durante la prueba.

## Qué comprobar en las respuestas

- **IA generativa.** La respuesta debe ser comprensible para una persona sin conocimientos técnicos y distinguir los modelos de texto, imagen y vídeo. Revisa si cubre los ejemplos, los usos, las ventajas, los límites y el futuro que pide el enunciado.
- **Presupuesto.** El máximo es **16 puntos** con **B + D + E**, que cuestan **300 €**. Con B es obligatorio contratar E y quedan 90 €, justo lo que cuesta D. Sin B, la mejor opción es A + C con 14 puntos. Con ello se puede comprobar la respuesta y su justificación.
- **Constitución.** La respuesta del vídeo localizó el máximo de 72 horas del art. 17.2, las condiciones del art. 18.2, la función del Defensor del Pueblo del art. 54 y la distinción de los arts. 55.1 y 116 sobre la suspensión de derechos. Citó el **162.2** para el recurso de amparo del Defensor del Pueblo, cuando figura en el **162.1.b**. En el estado de sitio atribuyó en la misma frase al Gobierno y al Congreso la determinación del ámbito, la duración y las condiciones. El **116.4** asigna esa decisión al **Congreso**. [Artículos 17, 18, 54, 55, 116 y 162 en el BOE](https://www.boe.es/buscar/act.php?id=BOE-A-1978-31229)
