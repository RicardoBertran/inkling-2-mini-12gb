# Instalación en Windows

[Volver a la guía](../README.md)

## 1. Comprueba el controlador

Abre el menú **Inicio**, escribe **PowerShell** y abre la aplicación. Puedes utilizarla con tu cuenta habitual. Pega el siguiente comando y pulsa **Intro**.

```powershell
nvidia-smi
```

Debes ver el nombre de tu gráfica y la versión del controlador. **CUDA** es la tecnología de NVIDIA que permite a llama.cpp usar la gráfica para calcular. El campo `CUDA Version` indica la versión que admite el controlador. Si el comando falla o muestra una versión anterior a 13.5, actualiza el controlador, reinicia Windows y vuelve a comprobarlo. Para esta guía se utiliza el paquete CUDA 13.5 para Windows **x64**. Los dos ZIP incluyen el motor y las bibliotecas necesarias para ejecutarlo. [Controladores de NVIDIA](https://www.nvidia.com/drivers/) · [Notas de CUDA](https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html)

## 2. Descarga y abre la carpeta de la guía

1. En GitHub, pulsa el botón verde **Code** y elige **Download ZIP**.
2. En el Explorador de archivos, haz clic derecho en el ZIP, elige **Extraer todo** y abre la carpeta que contiene `README.md` y `scripts`. Elige una unidad con al menos **25 GB libres**.
3. En la barra de dirección del Explorador, escribe `powershell` y pulsa **Intro**. Los comandos de los siguientes pasos se ejecutan en esa ventana.

```powershell
Get-Location
Get-ChildItem
```

Comprueba que la lista contiene la carpeta `scripts`. Los comandos guardan todo dentro de la carpeta de la guía.

## 3. Descarga llama.cpp y sus bibliotecas

El primer ZIP contiene `llama-server.exe`, que carga el modelo y sirve el chat local. El segundo contiene las bibliotecas de ejecución CUDA. Usa ambos paquetes de **b12676, CUDA 13.5, Windows x64**. Puedes consultar los activos y sus sumas SHA-256 en la [página oficial de la versión](https://github.com/ggml-org/llama.cpp/releases/tag/b12676).

- [Motor llama.cpp b12676 para Windows CUDA 13.5 x64](https://github.com/ggml-org/llama.cpp/releases/download/b12676/llama-b12676-bin-win-cuda-13.5-x64.zip)
- [Bibliotecas CUDA 13.5 x64](https://github.com/ggml-org/llama.cpp/releases/download/b12676/cudart-llama-bin-win-cuda-13.5-x64.zip)

Pega el bloque entero. Descarga los dos ZIP, verifica el SHA-256 de cada uno y los descomprime juntos en `llama.cpp`. SHA-256 es una huella digital del archivo que permite detectar una descarga incompleta o alterada.

```powershell
New-Item -ItemType Directory -Force -Path "descargas", "llama.cpp", "modelos" | Out-Null
$base = "https://github.com/ggml-org/llama.cpp/releases/download/b12676"
$archivos = [ordered]@{
    "llama-b12676-bin-win-cuda-13.5-x64.zip" = "39f2cdae1833fc58b4ab6c7ae29b0100f6ee656008ee7ae62285bc6d812d0258"
    "cudart-llama-bin-win-cuda-13.5-x64.zip" = "c2bf4cc202bfbaaa7a0b75f5082457c3811326947bb216059b72839d844e9cba"
}
foreach ($nombre in $archivos.Keys) {
    $zip = Join-Path "descargas" $nombre
    curl.exe --fail --location --retry 3 --output "$zip" "$base/$nombre"
    if ($LASTEXITCODE -ne 0) { throw "Error de descarga: $nombre" }
    if ((Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash -ne $archivos[$nombre]) {
        throw "SHA-256 incorrecto: $nombre"
    }
}
foreach ($nombre in $archivos.Keys) {
    Expand-Archive -LiteralPath (Join-Path "descargas" $nombre) -DestinationPath "llama.cpp" -Force -ErrorAction Stop
}
& ".\llama.cpp\llama-server.exe" --version
& ".\llama.cpp\llama-server.exe" --list-devices
```

La primera comprobación debe indicar **build 12676**, commit **`d35dc4d9e`**. La segunda debe mostrar tu gráfica NVIDIA como `CUDA0` si tienes una sola. Si tienes varias, localiza el identificador de la que quieres usar. La **numeración que importa es la de llama.cpp**.

## 4. Descarga Inkling 2 Mini IQ4_NL

El [GGUF oficial de ggml-org](https://huggingface.co/ggml-org/Inkling-2-Mini-GGUF/blob/e8a2cecf0e78914f07cc27b9be711a9b2c7561d9/Inkling-2-Mini-IQ4_NL.gguf) ocupa **17,63 GB** (unos **16,42 GiB**). El comando usa una revisión fija de ese repositorio y guarda el archivo en `modelos`. La comprobación de la huella puede tardar.

```powershell
$modelo = "modelos\Inkling-2-Mini-IQ4_NL.gguf"
$url = "https://huggingface.co/ggml-org/Inkling-2-Mini-GGUF/resolve/e8a2cecf0e78914f07cc27b9be711a9b2c7561d9/Inkling-2-Mini-IQ4_NL.gguf"
curl.exe --fail --location --retry 3 --output "$modelo" "$url"
if ($LASTEXITCODE -ne 0) { throw "Error al descargar el modelo." }
if ((Get-FileHash -LiteralPath $modelo -Algorithm SHA256).Hash -ne "cbdf3fa9dc50a4124977980f37da4f1fa764b0cfe800d275cd43d26ce2a81af4") {
    throw "SHA-256 incorrecto. Descarga de nuevo el GGUF antes de abrirlo."
}
```

Al terminar, la estructura será esta.

```text
inkling-2-mini-12gb/
├── llama.cpp/
│   ├── llama-server.exe
│   ├── cudart64_13.dll
│   └── …
├── modelos/
│   └── Inkling-2-Mini-IQ4_NL.gguf
└── scripts/
    └── iniciar-inkling.bat
```

## 5. Arranca Llama UI

Con una sola gráfica NVIDIA, deja `CUDA0` en el BAT. Si `--list-devices` muestra que la gráfica elegida tiene otro identificador, abre el BAT con el Bloc de notas y cambia el valor en `set "GPU=CUDA0"`. Guarda el archivo con la extensión `.bat`. `--main-gpu 0` selecciona la primera gráfica de la lista ya reducida por `--device`. [Documentación del servidor en b12676](https://github.com/ggml-org/llama.cpp/blob/b12676/tools/server/README.md)

Haz doble clic en `scripts\iniciar-inkling.bat`. También puedes lanzarlo desde la misma ventana de PowerShell que usaste para instalar.

```powershell
& ".\scripts\iniciar-inkling.bat"
```

Deja esa ventana abierta. Cuando la consola indique que el modelo ha terminado de cargar, abre [http://127.0.0.1:8080/](http://127.0.0.1:8080/). Esa dirección apunta a tu propio ordenador. Escribe un mensaje corto y envíalo. Para parar el servidor, vuelve a la consola y pulsa **Ctrl+C**. Si Windows pregunta si quieres terminar el proceso por lotes, confirma.

## Solución de problemas

| Si ves esto | Qué puedes hacer |
|---|---|
| Falta `cudart64_13.dll`, `cublas64_13.dll` o `cublasLt64_13.dll` | Repite el paso 3. Las DLL de CUDA deben estar en la misma carpeta que `llama-server.exe`. |
| Falta `VCRUNTIME140.dll` o `MSVCP140.dll` | Instala el [redistribuible de Visual C++ x64 de Microsoft](https://learn.microsoft.com/es-es/cpp/windows/latest-supported-vc-redist) y vuelve a abrir el servidor. |
| `--list-devices` no muestra CUDA | Comprueba `nvidia-smi` y que has extraído los dos ZIP correctos, con el mismo destino. |
| Error al abrir el GGUF o al leer el modelo | Comprueba el nombre, la ruta y el SHA-256 del paso 4. |
| Error de memoria CUDA al cargar | Cierra juegos, editores y otras aplicaciones que usen la GPU. Si sigue fallando, prueba a cambiar `--ctx-size 65536` a `--ctx-size 32768` en una copia del BAT y deja espacio para la respuesta. Los resultados del vídeo son del perfil de 64K. |
| Windows usa mucha RAM y el equipo se ralentiza | Cierra aplicaciones y comprueba la memoria disponible en **Administrador de tareas → Rendimiento → Memoria**. Usar el disco como memoria de apoyo puede ralentizar el modelo. |
| El navegador indica que no se puede conectar | Espera a que termine la carga. Si se ha cerrado el servidor, revisa el último mensaje de la consola y comprueba que la dirección y el puerto son correctos. |
| El puerto `8080` ya está ocupado | Cierra el servidor que usa ese puerto o cambia `set "PORT=8080"` a `set "PORT=8081"` en el BAT. Abre en el navegador la dirección que indique el BAT. |
| El modelo se queda razonando o da una respuesta incorrecta | Detén la generación desde el chat y abre una conversación nueva. Si limitas los tokens de salida, deja margen para que quepan el razonamiento y la respuesta final. |
