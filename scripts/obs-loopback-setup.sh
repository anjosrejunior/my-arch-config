#!/bin/bash

sudo modprobe -r v4l2loopback 2>/dev/null

sudo modprobe v4l2loopback \
    video_nr=10 \
    card_label="OBS Virtual Camera" \
    exclusive_caps=1

pactl unload-module module-remap-source 2>/dev/null
pactl unload-module module-null-sink 2>/dev/null

pactl load-module module-null-sink \
    sink_name=OBS_Output \
    sink_properties=device.description=Virtual_Cable_OBS

pactl load-module module-remap-source \
    master=OBS_Output.monitor \
    source_name=Virtual_Input_OBS \
    source_properties=device.description=Virtual_Mic_OBS