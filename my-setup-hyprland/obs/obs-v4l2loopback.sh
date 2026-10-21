#!/bin/bash

# Esse script é diferente por que ele cria a câmera virtual no boot com o kernel então não precisa da primeira parte

# Limpa instâncias anteriores dos módulos de áudio (se existirem)
pactl unload-module module-remap-source 2>/dev/null
pactl unload-module module-null-sink 2>/dev/null

# Cria a saída virtual de áudio do OBS
pactl load-module module-null-sink \
    sink_name=OBS_Output \
    sink_properties=device.description=Virtual_Cable_OBS

# Cria a entrada virtual (Microfone) para outros apps capturarem a saída do OBS
pactl load-module module-remap-source \
    master=OBS_Output.monitor \
    source_name=Virtual_Input_OBS \
    source_properties=device.description=Virtual_Mic_OBS