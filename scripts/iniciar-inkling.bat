@echo off
setlocal
set "GPU=CUDA0"
set "PORT=8080"

pushd "%~dp0.." || exit /b 1
if not exist "llama.cpp\llama-server.exe" (
    echo Falta llama.cpp\llama-server.exe. Sigue instalacion\windows.md.
    goto error
)
if not exist "modelos\Inkling-2-Mini-IQ4_NL.gguf" (
    echo Falta modelos\Inkling-2-Mini-IQ4_NL.gguf. Sigue instalacion\windows.md.
    goto error
)

echo Cuando termine la carga, abre http://127.0.0.1:%PORT%/ en el navegador.
"llama.cpp\llama-server.exe" ^
    --model "modelos\Inkling-2-Mini-IQ4_NL.gguf" ^
    --alias "Inkling 2 Mini IQ4_NL" ^
    --host 127.0.0.1 --port %PORT% --cors-origins localhost ^
    --device %GPU% --main-gpu 0 --split-mode none ^
    --ctx-size 65536 --parallel 1 ^
    --n-gpu-layers 99 --fit off ^
    --override-tensor "blk\.([0-5]|19|2[0-3])\.ffn_.*_exps\.weight=CPU" ^
    --no-op-offload --flash-attn on ^
    --cache-type-k q4_0 --cache-type-v q4_0 ^
    --batch-size 256 --ubatch-size 64 ^
    --spec-type none --no-mmproj --no-agent --jinja
set "RESULT=%ERRORLEVEL%"
if "%RESULT%"=="0" (
    popd
    exit /b 0
)
echo.
echo El servidor se ha cerrado con el codigo %RESULT%. Revisa los mensajes anteriores.
pause
popd
exit /b %RESULT%

:error
pause
popd
exit /b 1
