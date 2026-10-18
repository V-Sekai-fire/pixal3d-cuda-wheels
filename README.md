# pixal3d-cuda-wheels

GitHub Actions builds the five CUDA extensions the Pixal3D Space uses (FlexGEMM, CuMesh, o-voxel, nvdiffrast, nvdiffrec renderutils)
for the RTX 3090 (sm_86), RTX 4090 (sm_89) and Blackwell (sm_120). The Space's own wheels carry
sm_120 kernels only, so they fail with "no kernel image is available" on 30- and 40-series cards.

- Pins (base image digest, torch, source commits, target architectures): `pins.env`.
- Build: `build.sh`, run in the pinned CUDA devel image. No GPU is needed.
- Gate: `check.sh` reads the SASS list with `cuobjdump --list-elf` and fails the run if any extension cannot run on a required architecture (strings in a binary are not evidence: nvdiffrast names sm_20..sm_120 and ships sm_120 SASS only).
- Output: a release `wheels-<commit>` with the wheels and `SHA256SUMS`.

Rebuild: edit `pins.env` and push, or run the workflow by hand.

FlexGEMM, CuMesh and TRELLIS.2 are MIT. nvdiffrast and nvdiffrec are under the NVIDIA Source Code License (non-commercial use); their wheels carry that licence. This repository's scripts are MIT.
