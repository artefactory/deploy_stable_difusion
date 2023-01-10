import logging
from abc import ABC

import diffusers
import torch
from diffusers import StableDiffusionPipeline

from ts.torch_handler.base_handler import BaseHandler
import numpy as np


logger = logging.getLogger(__name__)
logger.info("Diffusers version %s", diffusers.__version__)

class DiffusersHandler(BaseHandler, ABC):
    """
    Diffusers handler class for text to image generation.
    """

    def __init__(self):
        self.initialized = False

    def initialize(self, ctx):
        """In this initialize function, the Stable Diffusion model is loaded and
        initialized here.
        Args:
            ctx (context): It is a JSON Object containing information
            pertaining to the model artefacts parameters.
        """
        self.manifest = ctx.manifest
        properties = ctx.system_properties
        model_dir = properties.get("model_dir")

        self.device = torch.device(
            "cuda:" + str(properties.get("gpu_id"))
            if torch.cuda.is_available() and properties.get("gpu_id") is not None
            else "cpu"
        )
    
        
        self.pipe = StableDiffusionPipeline.from_pretrained("model_weights")
        self.pipe.to(self.device)
        logger.info("Diffusion model from path %s loaded successfully", model_dir)

        self.initialized = True

    def preprocess(self, requests):
        """Basic text preprocessing, of the user's prompt.
        Args:
            requests (str): The Input data in the form of text is passed on to the preprocess
            function.
        Returns:
            list : The preprocess function returns a list of prompts.
        """
        logger.info("Received requests: '%s'", requests)

        requests_body = requests[0].get("body")
        if requests_body is None:
            requests_body = requests[0].get("instances")

        if isinstance(requests_body, (bytearray, bytes)):
            text = requests_body.decode("utf-8")
            return [text]

        text = requests_body.get("instances")[0].get('data')
        
        logger.info("pre-processed text: '%s'", text)

        return [text]


    

    def inference(self, inputs):
        """Generates the image relevant to the received text.
        Args:
            inputs (list): List of Text from the pre-process function is passed here
        Returns:
            list : It returns a list of the generate images for the input text
        """

        # Handling inference for sequence_classification.
        inferences = self.pipe(
            inputs, guidance_scale=7.5, num_inference_steps=50
        ).images
        
        logger.info("Generated image: '%s'", inferences)
        return inferences

    def postprocess(self, inference_output):
        """Post Process Function converts the generated image into Torchserve readable format.
        Args:
            inference_output (list): It contains the generated image of the input text.
        Returns:
            (list): Returns a list of the images.
        """
        images = []
        for image in inference_output:
            images.append(np.array(image).tolist())
        return images