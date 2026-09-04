# 8.2 — U-Net for Contrast Correction Example

Codes to use a 2D U-Net to correct contrast inversion in STEM projections of thick
nanoparticle samples. Corresponds to **Supplementary Note §8.2** of the manuscript
*"Autonomous Liquid-Cell Electron Tomography for 4D Nanoparticle Reaction Kinetics."*

The notebook `contrast_correction_UNet.ipynb` trains a 2D U-Net (grayscale
image-to-image regression) that maps raw projections (with contrast inversion) to
contrast-corrected projections, then applies the trained model to projection stacks.

---

## 1. System requirements

### Software dependencies (tested versions)
- Python 3.10
- TensorFlow / Keras 2.15 (Conv2D / Conv2DTranspose + `.keras` model format)
- numpy 1.26
- tifffile 2024.2.12
- matplotlib 3.8

> These are the versions the code was tested on in **Google Colab (2025)**.
> Other recent versions of TensorFlow ≥ 2.13 are expected to work but were not tested.

### Operating systems tested
- Google Colab (Ubuntu 22.04 backend)
- <optionally: local Ubuntu 22.04 / Windows 11, if you tested locally>

### Hardware
- **GPU recommended for training.** Tested on the NVIDIA GPU provided by Google Colab
  (<e.g., Tesla T4, 16 GB>). The model operates on 256×256 grayscale images.
- Inference (prediction only) can run on GPU or CPU; CPU inference is slower but
  feasible for the demo stacks.

---

## 2. Installation guide

No installation is required if running on **Google Colab** — all dependencies are
pre-installed. Simply open the notebook in Colab.

To run **locally**:
```bash
# create environment
conda create -n unet2d python=3.10
conda activate unet2d
pip install tensorflow==2.15 numpy==1.26 tifffile==2024.2.12 matplotlib==3.8
```
**Typical install time:** ~5–10 minutes on a normal desktop with broadband
(longer if downloading GPU/CUDA-enabled TensorFlow). On Colab: no install needed.

---

## 3. Demo

### Data
Download the demo training/testing datasets and (optionally) the pre-trained model:
- Training data (`IMG.npy`, `GT.npy`): `<link>`
- Testing projection stacks (`*.tif`): `<link>`
- Pre-trained model (`unet_256x256_gray.keras`): `<link>`

Place them in the same folder as `contrast_correction_UNet.ipynb`. The expected
folder layout is:
```
tilt_recover/
├── contrast_correction_UNet.ipynb
├── IMG.npy                       # training inputs  (2500, 256, 256)
├── GT.npy                        # training targets (2500, 256, 256)
├── <test_stack>.tif              # test projection stacks (N, 256, 256)
└── unet_256x256_gray.keras       # optional pre-trained model
```

**Input data format:**
- Training data: two NumPy arrays of shape `(2500, 256, 256)` — `IMG.npy`
  (raw/contrast-inverted projections) and `GT.npy` (contrast-corrected targets),
  both float32.
- Test data: multi-page TIFF stacks of shape `(N, 256, 256)`, float32.

### Running the demo
Open `contrast_correction_UNet.ipynb` in Colab or Jupyter and run the cells in order.
- If mounting Google Drive (Colab), update the path in the `os.chdir(...)` cell to
  your data location.
- **To use the pre-trained model instead of training:** skip the training cell
  (`model.fit(...)` / `model.save(...)`) and run the "load your trained model" cell
  onward.
- Update the input filename in each prediction cell to point to your test stack.

### Expected output
- A trained model file `unet_256x256_gray.keras` (if training).
- For each input stack `<name>.tif`, a contrast-corrected output stack
  `<name>_pred.tif` written as a 32-bit float TIFF with the same shape `(N, 256, 256)`.
- A sanity-check figure showing one corrected slice.

### Expected run time (on the tested Colab GPU)
- **Training:** ~57 s for the first epoch (graph build) then ~15 s per epoch × 20
  epochs ≈ **5–6 minutes** for 2500 image pairs.
- **Inference:** roughly 0.25 s per slice (batched); a ~300-slice stack completes in
  **under ~15 seconds** on GPU.

---

## 4. Instructions for use (your own data)

1. Prepare paired training data as two float32 arrays of shape `(N, 256, 256)`:
   `IMG.npy` (raw projections) and `GT.npy` (contrast-corrected targets). Save them
   in the working folder.
2. Prepare test projection stacks as multi-page TIFFs of shape `(N, 256, 256)`,
   float32. (The prediction cell asserts this shape.)
3. Adjust hyperparameters in the notebook as needed:
   - `batch_size` (default 8 for training / 16 for inference),
   - `epochs` (default 20), learning rate (1e-4), loss (`mse`).
4. Run the notebook to train, then run a prediction cell (edit the filename) to
   correct each test stack.
5. Corrected stacks are saved as `<name>_pred.tif` in the working folder.

> The model expects 256×256 input tiles. If your projections have a different size,
> tile/resize them to 256×256 before inference (and train on matching tiles).
