#!/usr/bin/env bash
# Runs inside nvidia/cuda 13.0.3 devel (Ubuntu 24.04). No GPU is needed: TORCH_CUDA_ARCH_LIST picks the targets.
set -euo pipefail
apt-get update && apt-get install -y --no-install-recommends python3.12 python3.12-venv python3.12-dev git ninja-build binutils
python3.12 -m venv /venv && export PATH=/venv/bin:$PATH
pip install --no-cache-dir --extra-index-url https://download.pytorch.org/whl/cu130 "torch==$TORCH_VERSION" setuptools wheel ninja numpy
fetch() { git clone -q "https://github.com/$1.git" "/src/$2" && git -C "/src/$2" checkout -q "$3" && git -C "/src/$2" submodule update -q --init --recursive; }
fetch JeffreyXiang/FlexGEMM flexgemm "$FLEXGEMM_SHA"
fetch JeffreyXiang/CuMesh cumesh "$CUMESH_SHA"
fetch microsoft/TRELLIS.2 trellis2 "$TRELLIS2_SHA"
fetch NVlabs/nvdiffrast nvdiffrast "$NVDIFFRAST_SHA"
fetch JeffreyXiang/nvdiffrec nvdiffrec "$NVDIFFREC_SHA"
mkdir -p dist
for src in /src/flexgemm /src/cumesh /src/trellis2/o-voxel /src/nvdiffrast /src/nvdiffrec; do
  pip wheel --no-build-isolation --no-deps -w dist "$src"
done
bash check.sh dist
chmod a+rw dist/*
