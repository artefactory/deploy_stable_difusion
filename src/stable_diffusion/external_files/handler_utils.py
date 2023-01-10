import base64
from io import BytesIO
from PIL import Image
import numpy as np
import uuid
from tempfile import TemporaryFile
from google.cloud import storage

def encode_np_img_to_b64(np_img: np.ndarray) -> str:
    """ Encode an image in base 64.
    Args:
        np_img (np.ndarray): Image to be encoded.
    Returns:
        str: Encoded image.
    """
    img = Image.fromarray(np_img)
    img_bytes = BytesIO()
    img.save(img_bytes, format="JPEG")
    img_bytes = img_bytes.getvalue()  # returns type <class 'bytes'>
    base64_data = base64.b64encode(img_bytes).decode('utf-8')
    return base64_data

def generate_random_name() -> str:
    """ Generate a random name.
    Args:
        suffix (str): Suffix of the name.
    Returns:
        str: Random name.
    """
    return str(uuid.uuid4())

def save_image_to_gcs(bucket_name, folder_name, image, prompt):
    """ Save an image to Google Cloud Storage.
    Args:
        bucket_name (str): Name of the bucket.
        folder_name (str): Name of the folder.
        image (np.ndarray): Image to be saved.
        image_name (str): Name of the image.
    """
    client = storage.Client()
    bucket = client.get_bucket(bucket_name)

    image_name = generate_random_name()

    blob = bucket.blob(folder_name + '/' + image_name + '.png')
    
    with TemporaryFile() as tmp:
        image.save(tmp, format="png")
        tmp.seek(0)
        blob.upload_from_file(tmp, content_type='image/png')

    # generate txt file with the image name and the prompt inside
    blob = bucket.blob(folder_name + '/' + image_name + '.txt')
    blob.upload_from_string(prompt)
    
    # return the gcs path to the image
    return 'gs://' + bucket_name + '/' + folder_name + '/' + image_name + '.png'
