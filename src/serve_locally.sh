#!/bin/sh

echo " ---- creating .mar file ---- "

torch-model-archiver \
--model-name stable-diffusion \
--version 1.0 \
--handler stable_diffusion/stable_diffusion_handler.py \
--export-path stable_diffusion/model-store \
--extra-files stable_diffusion/external_files \

echo " ---- starting torchserve ---- "

torchserve \
--start \
--ts-config=config.properties \
--models=stable-diffusion.mar \
--model-store=stable_diffusion/model-store