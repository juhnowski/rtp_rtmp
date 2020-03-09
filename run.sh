#!/bin/bash

# tested on Ubuntu 16.04
apt-get install -y \
  gstreamer1.0-libav \
  gstreamer1.0-plugins-bad \
  gstreamer1.0-plugins-base \
  gstreamer1.0-plugins-good \
  gstreamer1.0-tools

# start gstreamer... assumes you have mediasoup configured to use Opus/H264
gst-launch-1.0 -em \
  rtpbin name=rtpbin latency=5 \
  udpsrc port=10000 caps="application/x-rtp,media=(string)audio,clock-rate=(int)48000,encoding-name=(string)OPUS" ! rtpbin.recv_rtp_sink_0 \
    rtpbin. ! queue ! rtpopusdepay ! opusdec ! audioconvert ! audioresample ! voaacenc ! mux. \
  udpsrc port=10002 caps="application/x-rtp,media=(string)video,clock-rate=(int)90000,encoding-name=(string)H264" ! rtpbin.recv_rtp_sink_1 \
    rtpbin. ! queue ! rtph264depay ! h264parse ! mux. \
  flvmux name=mux streamable=true ! rtmpsink sync=false location=rtmp://127.0.0.1:1935/stream
