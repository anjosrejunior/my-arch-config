#!/bin/bash

sudo modprobe -r v4l2loopback 2>/dev/null

sudo modprobe v4l2loopback \
    video_nr=10 \
    card_label="OBS Virtual Camera" \
    exclusive_caps=1

pactl unload-module module-remap-source 2>/dev/null
pactl unload-module module-null-sink 2>/dev/null

pactl load-module module-null-sink \
    sink_name=Saida_OBS \
    sink_properties=device.description=Cabo_Virtual_OBS

pactl load-module module-remap-source \
    master=Saida_OBS.monitor \
    source_name=Entrada_Virtual_OBS \
    source_properties=device.description=Microfone_Virtual_OBS