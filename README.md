# pixal3d-cuda-wheels

GitHub Actions builds the three CUDA extensions the Pixal3D Space uses (FlexGEMM, CuMesh, o-voxel)
for the RTX 3090 (sm_86), RTX 4090 (sm_89) and Blackwell (sm_120). The Space's own wheels carry
sm_120 kernels only, so they fail with "no kernel image is available" on 30- and 40-series cards.

- Pins (base image digest, torch, source commits, target architectures): `pins.env`.
- Build: `build.sh`, run in the pinned CUDA devel image. No GPU is needed.
- Gate: `check.sh` fails the run if any extension misses a required architecture.
- Output: a release `wheels-<commit>` with the wheels and `SHA256SUMS`.

Rebuild: edit `pins.env` and push, or run the workflow by hand.

The sources are MIT (FlexGEMM, CuMesh, TRELLIS.2). This repository's scripts are MIT.
