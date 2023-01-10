# How to deploy huggingface model to a Vertex endpoint

This project contains the necessary files and instructions to deploy a stable version of a machine learning model using torchserve, create a Docker image for the model, and deploy the model to Vertex and attach it to a Vertex endpoint.

Simply follow the instructions in the README.md file to get started.

## Download model weights

Before you start, you need to download the model weights locally. You can download the weights with the `stable_diffusion/download_model.py` script. The model weights will be stored under `stable_diffusion/external_files/model_weights`.

The weights are restricted to users who accepted the terms and conditions of the license, so you need 2 steps before runnning the script:
- Log-in to your huggingface account and accept the condition of the mdoel, [here for stable diffusion 1.4](https://huggingface.co/CompVis/stable-diffusion-v1-4)
- Generate an API token and add it inside a .env file at the root of the project, see [.dotenv file](#dotenv-file)


## Torch serve

[Torchserve](https://github.com/pytorch/serve) is a flexible and easy-to-use tool for serving PyTorch models. It allows you to serve models locally or in a production environment, and provides features such as multi-model serving, GPU support, and automatic batching. There are 3 main steps to deploy a model on torchsrve:

**Writing the custom handler**: 
- The first step to serving a PyTorch model with torchserve is to write a custom handler class that implements model-specific logic for preprocessing input, running inference, and postprocessing output.

**Packaging the files inside a mar file**: 
- After the custom handler has been implemented, the necessary files (e.g. the handler class, the model weights, utils, etc.) can be packaged into a .mar file using the torch-model-archiver tool. This .mar file can then be served by torchserve.

**Model serving with torchserve --start**: 
- To start serving the model, the torchserve --start command is used to load the .mar file into torchserve and start a local server. The server can then be accessed via HTTP POST requests to run inference on the model.

## Docker image

The deployment of the model is dockerized inside a dockerfile.

The 2 following PORT are used:
- `7080`: Inference
- `7081`: Health check

## Scripts

In order to ease the deployment to GCP, you can use the prepared bash scripts to deploy and undeploy the model to endpoints:
- `deploy.sh`: This script is used new version of the model needs to be deployed. This script will build the new image, upload the model to vertex model registry, create / find the specified endpoint and attach the newly deployed model to the endpoint.
- `serve_locally.sh`: This script will deploy the model locally, it can be useful to debug the handler without using docker containers (that can be long to build because of the size of the model).
- `scripts/attach_to_endpoint.sh`: When the model is already inside model registry, you can use this script to directly attach the model to the endpoint.
- `scripts/detach_from_endpoint.sh`: When the model is attached to the endpoint, you can use this script to detach the model from the endpoint.


## .dotenv file

This project uses the `dotenv` library to manage environment variables. In order to use this project, you will need to create a file named `.env` in the root directory of the project. This file should contain the following variables:

- `HF_API_TOKEN`: The API token link to your huggingface account. This token will be used to query the public huggingface endpoint of stable diffusion. Currently the app is using the private endpoint on vertex, if you with to use the public endpoint you can add the token here and use the `query_api()` function inside `generate_image/inference`.