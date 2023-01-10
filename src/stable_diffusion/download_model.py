import torch
from diffusers import DiffusionPipeline
from dotenv import load_dotenv
import os

load_dotenv()
HF_TOKEN = os.getenv("HF_API_TOKEN")


pipeline = DiffusionPipeline.from_pretrained(
    "runwayml/stable-diffusion-v1-5",
    revision="fp16",
    torch_dtype=torch.float16,
    use_auth_token=HF_TOKEN,
)
pipeline.save_pretrained("external_files/model_weights")