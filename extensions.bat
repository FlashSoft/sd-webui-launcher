@echo off
title SD-WebUI Launcher
set PATH=%PATH%;%~dp0%git\cmd
cd stable-diffusion-webui\extensions
git clone https://github.com/hanamizuki-ai/stable-diffusion-webui-localization-zh_Hans.git
git clone https://github.com/pkuliyi2015/multidiffusion-upscaler-for-automatic1111.git
git clone https://github.com/butaixianran/Stable-Diffusion-Webui-Civitai-Helper.git
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-rembg.git
git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser