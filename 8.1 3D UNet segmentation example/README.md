# 8.1 — 3D U-Net Segmentation Example

Codes to perform 3D U-Net segmentation of two elements in a 3D reconstruction.
Corresponds to **Supplementary Note §8.1** of the manuscript
*"Autonomous Liquid-Cell Electron Tomography for 4D Nanoparticle Reaction Kinetics."*

The notebook `3D_UNet.ipynb` trains a 3D U-Net on augmented volumetric TIFF data
and produces per-voxel, 3-class segmentation masks (two elemental phases + background)
for the test volumes.

---

## 1. System requirements

### Software dependencies (tested versions)
- Python 3.10
- TensorFlow / Keras 2.15 (Conv3D + `.keras` model format)
- numpy 1.26
- tifffile 2024.2.12
- opencv-python (cv2) 4.9
- scikit-image 0.22

> These are the versions the code was tested on in **Google Colab (2025)**.
> Other recent versions of TensorFlow ≥ 2.13 are expected to work but were not tested.

### Operating systems tested
- Google Colab (Ubuntu 22.04 backend)
- <optionally: local Ubuntu 22.04 / Windows 11, if you tested locally>

### Hardware
- **GPU required for training.** Tested on the NVIDIA GPU provided by Google Colab
  (<e.g., Tesla T4, 16 GB>). At least ~<12–16> GB of GPU memory is recommended
  because the model processes full 128×128×128 volumes with ~30.9 M parameters.
- Inference (prediction only) can run on GPU or CPU; CPU inference is slower but
  feasible for small test sets.

---

## 2. Installation guide

No installation is required if running on **Google Colab** — all dependencies are
pre-installed. Simply open the notebook in Colab.

To run **locally**:
```bash
# create environment
conda create -n unet3d python=3.10
conda activate unet3d
pip install tensorflow==2.15 numpy==1.26 tifffile==2024.2.12 \
            opencv-python==4.9.0.80 scikit-image==0.22
```
**Typical install time:** ~5–10 minutes on a normal desktop with broadband
(longer if downloading GPU/CUDA-enabled TensorFlow). On Colab: no install needed.

---

## 3. Demo

### Data
Download the demo training/testing datasets and (optionally) the pre-trained model:
- Training + testing data: `<link>`
- Pre-trained model (`model.keras`): `<link>`

Place them in the same folder as `3D_UNet.ipynb`. The expected folder layout is:
```
ML3D/2025/
├── 3D_UNet.ipynb
├── augmentation.zip      # training volumes (unzipped by the notebook)
├── test/                 # test volumes (.tif)
├── prediction/           # output folder (created/used for predictions)
└── model.keras           # optional pre-trained model
```

**Input data format:** multi-page TIFF volumes of size 128×128×128.
- Training volumes: 4-channel — channels 0 and 1 are the ground-truth masks of the
  two elemental phases; channel 2 is the input intensity (normalized by 255).
- Test volumes: single-channel intensity (any cubic size; automatically resized to
  128³ for inference and resized back to the original size on output).

### Running the demo
Open `3D_UNet.ipynb` in Colab or Jupyter and run the cells in order.
- If mounting Google Drive (Colab), update the path in the `os.chdir(...)` cell to
  your data location.
- **To use the pre-trained model instead of training:** skip the training cell
  (`model.fit(...)`) and run the "Load the trained model" cell onward.

### Expected output
- A trained model file `model.keras` (if training).
- Predicted segmentation masks written to `prediction/`, one TIFF per test volume,
  as 3-channel uint8 volumes (per-class probability × 255) resized to each input's
  original dimensions.

### Expected run time (on the tested Colab GPU)
- **Training:** ~112 s per epoch × 50 epochs ≈ **90–95 minutes** for 420 volumes.
- **Inference:** ~1 s for the first volume (graph build) then ~20–25 ms per volume;
  the full demo test set completes in **under 1 minute**.

---

## 4. Instructions for use (your own data)

1. Prepare your data as 128×128×128 multi-page TIFFs following the channel
   convention above (2 label channels + 1 intensity channel for training).
2. Place training volumes in `augmentation/` (or zip as `augmentation.zip`) and test
   volumes in `test/`.
3. Adjust hyperparameters in the notebook as needed:
   - `epochs` (default 25), `batch_size` (default 1 for
     memory reasons), `validation_split` (default 0.1), learning rate (1e-4).
4. Run the notebook to train, then run the prediction cell to segment your test data.
5. Predictions are saved to `prediction/`.

> If your volumes are not 128³, the inference cell automatically resizes them to 128³
> and back; for best results, however, train on volumes matching your target size.
