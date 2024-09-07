# HairX - RunPod Worker for Automatic1111 Stable Diffusion

This part of the HairX image generation software is used to set up and run a StableDiffusion installation on a RunPod serverless environment. When properly set up, it exposes a public Stable Diffusion API we can call to generate images with our self-hosted Stable Diffusion environment, based on the Auto1111 SD WebUI.

## System Architecture

This setup requires two main components:

1. A RunPod serverless endpoint: Runs the Docker image and exposes the API.
2. A Network Volume: Stores models and other necessary files.

This repository provides:
- All data needed to build the Docker image for the serverless worker
- Instructions for installing data on the Network Volume

Key points:

- The Network Volume is set up once, with models and data installed. It remains persistent on the internet, incurring ongoing storage costs.
- The RunPod serverless endpoint is configured once but spawns workers on demand:
  - When needed, a worker pulls the Docker image and starts a container
  - When idle, the worker terminates and the container stops

To optimize performance:
- The Docker image is kept relatively small
- Stable Diffusion Web UI and models are stored on the Network Volume
- This approach balances startup times with the slight delay of accessing files over the internet connection between the RunPod worker and Network Volume
- Overall, this method is faster than using a very large Docker image

## Installation & Setup

### Step 1/3 - Set up the Network Volume

1. Log into https://www.runpod.io/

2. Ensure you have at least 20-30$ topped on your account

3. Create new empty network volume (50+ GB)

4. Deploy a temporary pod to install data on the network volume
	> select lightweight template like „RunPod Pytorch 2.1“
	> choose your network volume

5. For the pod, select „Connect to JupyterLab [8888]“

6. Open Terminal

7. In current folder, install data onto the volume by running an install script:

    ```
    wget https://raw.githubusercontent.com/dubtor/hairx-runpod-worker-a1111/main/scripts/install.sh
    chmod +x install.sh
    ./install.sh
    ```

    NOTE: this script is actually part of the current repository.

    Installation takes around 30mins. New models need to be added to the script.

1.8 Wait until the terminal concludes with „Model loaded in XXXXs“

1.9 Ctrl+C, close the terminal

1.10 Terminate the pod, network volume is ready

### Step 2/3 - Deploy Docker Image and Create Endpoint Template

1. Build Docker image based on the current repository (if anything has changed)
```
    docker build -t dubtor/hairx-runpod-worker-a1111:3.x.x .
```
2. Push image to dockerhub (if anything has changed)
```    
    docker push dubtor/hairx-runpod-worker-a1111:3.x.x
```
3. In Runpod, create new Template using the image
  > Select „serverless“
  > 5GB storage is enough
  > Docker Container image (public on dockerhub): 
        1. dubtor/hairx-runpod-worker-a1111:3.x.x

### Step 3/3 - Create Serverless Endpoint

1. Select your created template

2. Select Docker image you previously created

3. Write down the serverless endpoint ID and URL, example: „p1on5b85l3dlqu“

4. You can now send requests to the endpoint

Open the postman collection in the repo, enter your servless endpoint ID, and test the endpoints.

# A1111 Stable Diffusion | RunPod Serverless Worker

This is the source code for a [RunPod](https://runpod.io?ref=2xxro4sy)
Serverless worker that uses the [Automatic1111 Stable Diffusion API](
https://github.com/AUTOMATIC1111/stable-diffusion-webui) for inference.


> [!IMPORTANT]
> A1111 1.9.0 API format has changed dramatically and is not
> backwards compatible. You will need to ensure that you check
> out the `2.5.0` release of this worker if you require backwards
> compatibility, and also ensure that you are using A1111 1.8.0
> and not version 1.9.0.

## Model

The model(s) for inference will be loaded from a RunPod
Network Volume.

## Extensions

This worker includes the following A1111 extensions:

1. [ControlNet](https://github.com/Mikubill/sd-webui-controlnet)
2. [ReActor](https://github.com/Gourieff/sd-webui-reactor)
3. [ADetailer](https://github.com/Bing-su/adetailer)

## Testing

1. [Local Testing](docs/testing/local.md)
2. [RunPod Testing](docs/testing/runpod.md)

## Installing, Building and Deploying the Serverless Worker

1. [Install Automatic1111 Web UI on your Network Volume](
docs/installing.md)
2. [Building the Docker image](docs/building.md)
3. [Deploying on RunPod Serveless](docs/deploying.md)
4. [Frequently Asked Questions](docs/faq.md)

## RunPod API Endpoint

You can send requests to your RunPod API Endpoint using the `/run`
or `/runsync` endpoints.

Requests sent to the `/run` endpoint will be handled asynchronously,
and are non-blocking operations.  Your first response status will always
be `IN_QUEUE`.  You need to send subsequent requests to the `/status`
endpoint to get further status updates, and eventually the `COMPLETED`
status will be returned if your request is successful.

Requests sent to the `/runsync` endpoint will be handled synchronously
and are blocking operations.  If they are processed by a worker within
90 seconds, the result will be returned in the response, but if
the processing time exceeds 90 seconds, you will need to handle the
response and request status updates from the `/status` endpoint until
you receive the `COMPLETED` status which indicates that your request
was successful.

### RunPod API Examples

#### A1111 APIs

* [Get ControlNet Models](docs/api/a1111/get-controlnet-models.md)
* [Get Embeddings](docs/api/a1111/get-embeddings.md)
* [Get Extensions](docs/api/a1111/get-extensions.md)
* [Get Face Restorers](docs/api/a1111/get-face-restorers.md)
* [Get Hypernetworks](docs/api/a1111/get-hypernetworks.md)
* [Get Loras](docs/api/a1111/get-loras.md)
* [Get Latent Upscale Modes](docs/api/a1111/get-latent-upscale-modes.md)
* [Get Memory](docs/api/a1111/get-memory.md)
* [Get Models](docs/api/a1111/get-models.md)
* [Get Options](docs/api/a1111/get-options.md)
* [Get Prompt Styles](docs/api/a1111/get-prompt-styles.md)
* [Get Real-ESRGAN Models](docs/api/a1111/get-realesrgan-models.md)
* [Get Samplers](docs/api/a1111/get-samplers.md)
* [Get Schedulers](docs/api/a1111/get-schedulers.md)
* [Get Script Info](docs/api/a1111/get-script-info.md)
* [Get Scripts](docs/api/a1111/get-scripts.md)
* [Get Upscalers](docs/api/a1111/get-upscalers.md)
* [Get VAE](docs/api/a1111/get-vae.md)
* [Image to Image](docs/api/a1111/img2img.md)
* [Image to Image with ControlNet](docs/api/a1111/img2img-controlnet.md)
* [Interrogate](docs/api/a1111/interrogate.md)
* [Refresh Checkpoints](docs/api/a1111/refresh-checkpoints.md)
* [Refresh Embeddings](docs/api/a1111/refresh-embeddings.md)
* [Refresh Loras](docs/api/a1111/refresh-loras.md)
* [Refresh VAE](docs/api/a1111/refresh-vae.md)
* [Set Model](docs/api/a1111/set-model.md)
* [Set VAE](docs/api/a1111/set-vae.md)
* [Text to Image](docs/api/a1111/txt2img.md)
* [Text to Image with ReActor](docs/api/a1111/txt2img-reactor.md)
* [Text to Image with ADetailer](docs/api/a1111/txt2img-adetailer.md)
* [Text to Image with InstantID](docs/api/a1111/txt2img-instantid.md)

#### Helper APIs

* [File Download](docs/api/helper/download.md)
* [Huggingface Sync](docs/api/helper/sync.md)

### Optional Webhook Callbacks

You can optionally [Enable a Webhook](docs/api/helper/webhook.md).

### Endpoint Status Codes

| Status      | Description                                                                                                                     |
|-------------|---------------------------------------------------------------------------------------------------------------------------------|
| IN_QUEUE    | Request is in the queue waiting to be picked up by a worker.  You can call the `/status` endpoint to check for status updates.  |
| IN_PROGRESS | Request is currently being processed by a worker.  You can call the `/status` endpoint to check for status updates.             |
| FAILED      | The request failed, most likely due to encountering an error.                                                                   |
| CANCELLED   | The request was cancelled.  This usually happens when you call the `/cancel` endpoint to cancel the request.                    |
| TIMED_OUT   | The request timed out.  This usually happens when your handler throws some kind of exception that does return a valid response. |
| COMPLETED   | The request completed successfully and the output is available in the `output` field of the response.                           |

## Serverless Handler

The serverless handler (`rp_handler.py`) is a Python script that handles
the API requests to your Endpoint using the [runpod](https://github.com/runpod/runpod-python)
Python library.  It defines a function `handler(event)` that takes an
API request (event), runs the inference using the model(s) from your
Network Volume with the `input`, and returns the `output`
in the JSON response.

## Acknowledgements

- [Automatic1111](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
- [Generative Labs YouTube Tutorials](https://www.youtube.com/@generativelabs)

## Additional Resources

- [Postman Collection for this Worker](RunPod_A1111_Worker.postman_collection.json)
- [Generative Labs YouTube Tutorials](https://www.youtube.com/@generativelabs)
- [Getting Started With RunPod Serverless](https://trapdoor.cloud/getting-started-with-runpod-serverless/)
- [Serverless | Create a Custom Basic API](https://blog.runpod.io/serverless-create-a-basic-api/)

## Community and Contributing

Pull requests and issues on [GitHub](https://github.com/ashleykleynhans/runpod-worker-a1111)
are welcome. Bug fixes and new features are encouraged.

## Appreciate my work?

<a href="https://www.buymeacoffee.com/ashleyk" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
