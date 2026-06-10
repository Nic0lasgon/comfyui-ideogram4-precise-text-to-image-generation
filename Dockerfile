# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.8.4-base

# build-time tokens for gated downloads \xe2\x80\x94 never baked into final image.
# pass via: docker build --build-arg HF_TOKEN=$HF_TOKEN ...
ARG HF_TOKEN=""

# replace ComfyUI with latest from git \xe2\x80\x94 base image is too old for Ideogram 4 nodes
# (DualModelGuider, CFGOverride, Ideogram4Scheduler, etc. need v0.24.0+)
RUN rm -rf /comfyui/.git /comfyui/comfy /comfyui/comfy_extras /comfyui/nodes.py /comfyui/requirements.txt;     git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git /tmp/comfyui-latest;     cp -rf /tmp/comfyui-latest/.git /comfyui/;     cd /comfyui && git checkout HEAD -- .;     pip install --no-cache-dir -r requirements.txt;     rm -rf /tmp/comfyui-latest

# install custom nodes into comfyui
RUN comfy node install --exit-on-fail comfyui-custom-scripts --mode remote
RUN comfy node install --exit-on-fail comfyui-kjnodes
RUN comfy node install --exit-on-fail comfyui-cvt

# download models into comfyui
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors' --relative-path models/vae --filename 'flux2-vae.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/Ideogram-4/resolve/main/diffusion_models/ideogram4_fp8_scaled.safetensors' --relative-path models/diffusion_models --filename 'ideogram4_fp8_scaled.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/Qwen3-VL/resolve/main/text_encoders/qwen3vl_8b_fp8_scaled.safetensors' --relative-path models/text_encoders --filename 'qwen3vl_8b_fp8_scaled.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/Ideogram-4/resolve/main/diffusion_models/ideogram4_unconditional_fp8_scaled.safetensors' --relative-path models/diffusion_models --filename 'ideogram4_unconditional_fp8_scaled.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
