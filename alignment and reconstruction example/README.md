# Alignment and Reconstruction Example

Codes to align the projections in a tilt series and perform 3D reconstruction via
model-based iterative reconstruction (MBIR). Part of the fast electron tomography
pipeline of the manuscript *"Autonomous Liquid-Cell Electron Tomography for 4D
Nanoparticle Reaction Kinetics."*

This module contains two notebooks, run in order:
1. `alignment_example.ipynb` — iterative projection alignment (joint reprojection +
   sub-pixel phase cross-correlation, based on a patched TomoPy `align_joint`).
2. `recon_SVMBIR_example.ipynb` — 3D reconstruction of the aligned tilt series using
   SVMBIR.

A single acquisition file contains many concatenated tilt series (41 tilts each);
both notebooks split the stack into individual tilt series using the recorded tilt
angles before processing.

---

## 1. System requirements

### Software dependencies (tested versions)
- Python 3.10
- **tomopy** <1.14.4> (the alignment patch `align_joint_modify` is based on TomoPy 1.14.4)
- **svmbir** <0.3.x> (reconstruction)
- numpy <1.26>
- scikit-image <0.22>
- opencv-python (cv2) <4.9>
- tifffile <2024.2.12>
- matplotlib <3.8>
- pandas <2.2>

### Operating systems tested
- **Ubuntu 22.04** (required for the reconstruction step)
- **Windows is not supported** for `recon_SVMBIR_example.ipynb` — to the best of our
  knowledge SVMBIR does not run reliably on Windows. The alignment notebook can run
  on other OSes, but for consistency we recommend running the whole pipeline on
  Ubuntu 22.04.

### Hardware
- No non-standard hardware required, but the iterative alignment and MBIR
  reconstruction are **CPU- and memory-intensive**. A multi-core CPU and
  ≥ <16> GB RAM are recommended. 

---

## 2. Installation guide

We recommend a dedicated conda environment on Ubuntu 22.04:
```bash
conda create -n tomo python=3.10
conda activate tomo
# TomoPy is most reliably installed via conda-forge
conda install -c conda-forge tomopy=1.14.4
# SVMBIR and the remaining Python dependencies
pip install svmbir numpy scikit-image opencv-python tifffile matplotlib pandas
```

**Typical install time:** ~10–20 minutes on a normal desktop with broadband
(TomoPy/SVMBIR compilation and their scientific dependencies dominate the time).

> See the official SVMBIR installation guide if you encounter build issues:
> https://svmbir.readthedocs.io/

---

## 3. Demo

### Data
The demo processes one acquisition (`_20240612_124708`).
```
alignment and reconstruction example/
├── alignment_example.ipynb
├── recon_SVMBIR_example.ipynb
├── input/
│   ├── _20240612_124708_log_norm.tif          # coarse-aligned tilt series (download, see below)
│   └── tiltAnglesSeries__20240612_124708.csv  # recorded tilt angles
└── output/
    ├── align/_20240612_124708/                # created by notebook 1
    └── reconstruction/_20240612_124708/       # created by notebook 2
```

- The coarse-aligned tilt series `_20240612_124708_log_norm.tif`
  (shape `(1002, 512, 512)`, float32) and the tilt-angle CSV are the outputs of the
  previous pipeline step (**tilt series extraction example**). For completeness they
  are provided here:
  - CSV: included in `input/`.
  - TIFF: download `_20240612_124708_log_norm.tif` from `<link>` and place it in
    `input/`.

**Input data format:**
- `input/*_log_norm.tif` — a stack of `N` projections (512×512), float32, containing
  multiple concatenated tilt series.
- `input/tiltAnglesSeries_*.csv` — headerless CSV; column 2 holds the tilt angle
  (degrees) of each projection.

### Instructions
1. Create the output folders referenced by the notebooks:
   ```bash
   mkdir -p output/align/_20240612_124708 output/reconstruction/_20240612_124708
   ```
2. **Alignment** — open `alignment_example.ipynb` and run all cells. Confirm
   `tilt_range = 41` matches the number of tilts per series in your file. Aligned
   series are written to `output/align/_20240612_124708/NNN.tif`.
3. **Reconstruction** — open `recon_SVMBIR_example.ipynb` and run all cells. It reads
   the aligned series and writes reconstructions to
   `output/reconstruction/_20240612_124708/NNN.tif`.

### Expected output
- `output/align/_20240612_124708/NNN.tif` — one aligned tilt series per index
  (25 series for this demo file), each a 41×512×512 stack.
- `output/reconstruction/_20240612_124708/NNN.tif` — one 3D reconstruction per tilt
  series (512×512×512 volume).
- The alignment notebook also prints the per-iteration convergence error
  (`iter=…, err=…`).

### Expected run time (on a normal desktop)
- **Alignment:** ~10 minutes per tilt series (20 iterations of SIRT reprojection +
  registration).
- **Reconstruction:** SVMBIR runs up to 2000 iterations (stop threshold 0.002) per
  series and is the most time-consuming step — ~45 minutes per series on CPU.

> To test quickly, process a **single** tilt series by limiting the loops to
> `for i in range(1):` in both notebooks.

---

## 4. Instructions for use (your own data)

1. Place your coarse-aligned projection stack and its tilt-angle CSV in `input/`.
2. Set `tilt_range` to the number of tilts per individual tilt series in your data.
   The look-up table (`lut`) that splits the concatenated stack is derived from this.
3. In `alignment_example.ipynb`, adjust as needed:
   - `sigma` (Gaussian blur used to stabilize cross-correlation),
   - `center` (rotation-axis center; 256 for 512-wide projections),
   - `algorithm` (`'sirt'` by default) and `iters` (alignment iterations).
   Update the output path (`output/align/<acquisition>/`) and create the folder.
4. In `recon_SVMBIR_example.ipynb`, adjust `stop_threshold` and `max_iterations`,
   and update the input/output folder names to match your acquisition.
5. Run alignment first, then reconstruction.

> Notes:
> - The alignment routine `align_joint_modify` is a patched version of TomoPy's
>   `align_joint` (v1.14.4) that adds Gaussian filtering to the phase
>   cross-correlation. It is defined inside the notebook — no separate install.
> - Angles are converted from degrees to radians (`/180*np.pi`) before alignment and
>   reconstruction.
