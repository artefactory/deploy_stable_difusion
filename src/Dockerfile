# TO DO: fix to a static version
FROM pytorch/torchserve:latest-gpu

# set user root
USER root

RUN pip install --upgrade pip

# Install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copying model files
COPY ./stable_diffusion/external_files /home/model-server/external_files
COPY ./stable_diffusion/stable_diffusion_handler.py /home/model-server/
COPY ./config.properties /home/model-server/config.properties

USER model-server

# Expose health and prediction listener ports from the image
EXPOSE 7080
EXPOSE 7081


# # Generate MAR file
RUN torch-model-archiver \
--model-name stable-diffusion \
--version 1.0 \
--handler /home/model-server/stable_diffusion_handler.py \
--export-path /home/model-server/model-store \
--extra-files /home/model-server/external_files

CMD ["torchserve", \
     "--start", \
     "--ts-config=/home/model-server/config.properties", \
     "--models", \
     "stable-diffusion.mar", \
     "--model-store", \
     "/home/model-server/model-store"]