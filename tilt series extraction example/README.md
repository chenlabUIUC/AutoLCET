# Tilt Series Extraction Example

Codes to extract the useful frames (projections) from a raw acquisition movie and
assemble them into a tilt series ready for 3D reconstruction. Part of the fast
electron tomography pipeline of the manuscript *"Autonomous Liquid-Cell Electron
Tomography for 4D Nanoparticle Reaction Kinetics."*

This folder contains **two independent workflows**, depending on the acquisition
format. Use the one that matches your data:

| Script | Input format | Detector / software |
|---|---|---|
| `tomoExtract_exp.m` (MATLAB) | `.mrc` movie + `.xml` timestamps + tilt-angle `.csv` | TEM movies acquired with TIA |
| `tomoExtract_STEM.ipynb` (Python) | Velox `.emd` (HDF5) | HAADF-STEM series acquired with Velox |

Both produce (i) per-tilt projection stacks (TIFF) and (ii) a CSV listing the tilt
angle of each extracted projection — exactly the inputs required by the
**alignment and reconstruction example** step.

---

## 1. System requirements

### Workflow A — `tomoExtract_exp.m` (MATLAB / TIA MRC)
- MATLAB **R2024a** 
- **Image Processing Toolbox** (`imgaussfilt`, `imtranslate`, `imrotate`,
  `regionprops`, `bwlabel`, `imclearborder`, `imfill`, `findpeaks`, etc.)
- Bundled third-party helpers on the path:
  - `utils/EMIODist2/` — provides `ReadMRC` (MRC file reader)
- Helper functions defined inside the script (no separate install):
  `timeTable_extract`, `ptc_norm_crop`, `write_tiff32`.

### Workflow B — `tomoExtract_STEM.ipynb` (Python / Velox EMD)
- Python 3.10
- hyperspy <1.7 / 2.x — confirm>
- h5py <3.10>
- numpy <1.26>
- scikit-image <0.22>
- scipy <1.11> (optional; accelerates largest-connected-component COM)
- matplotlib <3.8>
- tifffile <2024.2.12>

### Operating systems tested
- Workflow A (MATLAB): Windows 11
- Workflow B (Python): Windows 11

### Hardware
- No non-standard hardware required. A normal desktop is sufficient, though the raw
  movies are large (multi-GB), so ≥ <16> GB RAM is recommended.

---

## 2. Installation guide

### Workflow A (MATLAB)
1. Install MATLAB <R2024a> with the Image Processing Toolbox.
2. Download this folder, keeping `utils/EMIODist2/` intact (added to the path via
   `addpath` at the top of the script).

**Typical install time:** < 1 minute beyond the MATLAB installation.

### Workflow B (Python)
```bash
conda create -n tomoextract python=3.10
conda activate tomoextract
pip install hyperspy h5py numpy scikit-image scipy matplotlib tifffile
```
**Typical install time:** ~5–10 minutes on a normal desktop with broadband.

---

## 3. Demo

### Workflow A — `tomoExtract_exp.m`

**Data.** This workflow needs three inputs:
```
tilt series extraction example/
├── tomoExtract_exp.m
├── utils/EMIODist2/                       # ReadMRC and dependencies
├── input/
│   ├── _20240612_124708.mrc               # raw TIA movie (download, see below)
│   ├── _20240612_124708.xml               # TIA timestamps (provided)
│   ├── 2024_06_12_17_43_37.csv            # tilt-angle log from the AutoLCET script (provided)
│   └── mask.tif                           # mask excluding the NP for background fitting (provided)
└── output/
    ├── backgroundTest/<mrc name>/         # sanity-check images (created)
    ├── frames/<mrc name>/                 # extracted ln-projections (created)
    └── tiltAnglesSeries_<mrc name>.csv    # per-projection tilt angles (created)
```
- The `.xml`, tilt-angle `.csv`, and `mask.tif` are provided here. The large raw
  movie `_20240612_124708.mrc` must be downloaded from 
  https://databank.illinois.edu/datasets/IDB-6461881 and placed in
  `input/`. (The files already present in `output/` are placeholders that preserve
  the folder structure.)

**Instructions.**
1. Open the `.mrc` in ImageJ and note the frame numbers of the first ~10 frames that
   occur **just before each tilt event**. Enter them into the `qp` variable
   (line ~8). The values in the script are for the demo data.
2. Set `angle_cor` (tilt-axis rotation correction; 0 if the tilt axis is the image
   Y-axis).
3. Run `tomoExtract_exp.m` in MATLAB. The blocks: (a) build the frame time-table from
   the XML; (b) find the time offset between the movie timestamps and the tilt-angle
   log by minimizing the summed time difference; (c) fit the background intensity vs.
   1/cos(tilt); (d) subtract the background and save the negative natural-log
   projection at each unique tilt angle.

**Expected output.**
- `output/backgroundTest/<mrc>/NNNNN.tif` — per-angle segmentation sanity images.
- `output/frames/<mrc>/NNNNN.tif` — background-subtracted, −ln projections (one per
  unique tilt angle). Drag this folder into ImageJ and save as a TIFF stack.
- `output/tiltAnglesSeries_<mrc>.csv` — two columns (time, tilt angle) matching the
  extracted series length.
- Diagnostic figures: time-offset curve, tilt-angle vs. time with sampled points, and
  the ln(background) vs. 1/cos(angle) linear fit.

**Expected run time.** ~5 minutes for the demo movie (dominated by reading each
selected frame from the large MRC and the per-frame segmentation). 

### Workflow B — `tomoExtract_STEM.ipynb`

**Data.**
- One Velox `.emd` (HDF5) STEM series. Set `emd_path` to your file. The demo file
  must be downloaded from `<link>` (our data repository).

**Instructions.**
1. Open `tomoExtract_STEM.ipynb` in Jupyter/Colab.
2. Run the first cells to inspect the HDF5 structure and copy the image UUID into
   `img_uuid`.
3. Run through: metadata decoding (per-frame stage position + `AlphaTilt`), plateau
   detection on the known 2.5°-step tilt grid (`plateaus_from_known_grid`), one frame
   selected per plateau and registered to the previous frame by center-of-mass shift
   (`register_align`), splitting into monotonic tilt sweeps, and saving.

**Expected output.**
- `output/NNN.tif` (or a date-named `.tif`) — a registered projection stack, one file
  per monotonic sweep, ready for reconstruction.
- `timeAngleSeries.csv` — two columns (frame time, tilt angle in degrees) for the
  chosen frames; this is the CSV required by the alignment/reconstruction step.

**Expected run time.** ~5 minutes for the demo `.emd` (metadata decode across all
frames + COM registration). 

---

## 4. Instructions for use (your own data)

### Workflow A
1. Place your `.mrc` movie, its `.xml`, the tilt-angle `.csv` (from the AutoLCET data
   collection app), and a `mask.tif` (excluding the particle) in `input/`.
2. Update `FileName`, the calibration CSV name, and the `qp` frame numbers for your
   movie (identify these in ImageJ).
3. Set `angle_cor` for your tilt-axis orientation; adjust the offset `searchRange` if
   your acquisition timing differs.
4. Run the script; collect results from `output/frames/` and the generated
   `tiltAnglesSeries_*.csv`.

### Workflow B
1. Set `emd_path` and `img_uuid` for your Velox file.
2. Adjust `plateaus_from_known_grid` parameters (`step_deg`, `tol_deg`, `min_len`) to
   match your tilt scheme, and `register_align`'s `thresh`/`invert`/`frame_offset` to
   your contrast (HAADF features are usually bright → `invert=True`).
3. Run all cells; collect the output `.tif` stacks and `timeAngleSeries.csv`.

> Both workflows feed directly into the **alignment and reconstruction example**:
> the projection stack(s) and the tilt-angle CSV are its required inputs.
