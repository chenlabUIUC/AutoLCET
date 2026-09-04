# 8.4 — Local Etching Rate Example

Codes to measure the local etching rate on the surface of a nanoparticle from a
3D reconstruction series. Corresponds to **Supplementary Note §8.4** of the
manuscript *"Autonomous Liquid-Cell Electron Tomography for 4D Nanoparticle
Reaction Kinetics."*

The script `etchingRate.m` compares consecutive 3D reconstructions (surface meshes)
in a time series, computes the per-vertex surface displacement (local etching rate),
assigns each surface point to one of two elemental species (Pd / Au), and correlates
the local etching rate with the local surface curvature.

---

## 1. System requirements

### Software dependencies (tested versions)
- MATLAB **R2024a**
- **Image Processing Toolbox** (required: `imrotate3`, `edge3`, multi-page `imread`)
- Third-party helper functions (MATLAB File Exchange), included in this folder / must
  be on the MATLAB path:
  - `readObj.m` — read Wavefront `.obj` mesh files
  - `inpolyhedron.m` — test whether points lie inside a closed mesh

> The following helper functions are defined inside `etchingRate.m` and need no
> separate installation: `snapShot`, `COM`, `particleRot`, `importAmCurvature`,
> `stack_reader_RGB`.

### Operating systems tested
- Windows 11

### Hardware
- No non-standard hardware required. Runs on a normal desktop CPU.

---

## 2. Installation guide

1. Install MATLAB R2024a with the Image Processing Toolbox.
2. Download this folder (including the demo data folders below).
3. Ensure `readObj.m` and `inpolyhedron.m` are present in the folder or on your
   MATLAB path. (If not bundled, download from the MATLAB File Exchange.)

**Typical install time:** MATLAB installation aside, no additional setup is needed
(< 1 minute to place files on the path). MATLAB itself typically installs in
~20–40 minutes.

---

## 3. Demo

### Data
Example input data are included in this folder:
```
8.4 local etching rate example/
├── etchingRate.m
├── readObj.m                       # third-party helper (must be present)
├── inpolyhedron.m                  # third-party helper (must be present)
├── Pd@Au NP1 ML surface/           # surface meshes: 000.obj, 001.obj, ...
├── Pd@Au NP1 ML prediction/        # segmentation stacks: 121723-1-00.tif, ...
├── Pd@Au NP1 ML curvature/         # curvature files: 000 MeanCurvature.am, ...
└── localEtchingRate/               # output folder (created/populated by the script)
```

**Input data format:**
- `Pd@Au NP1 ML surface/NNN.obj` — Wavefront OBJ surface mesh for each time point.
- `Pd@Au NP1 ML prediction/121723-1-NN.tif` — 128×128×128 multi-page RGB TIFF
  segmentation (channel 1 = Pd, channel 2 = Au), values 0–255.
- `Pd@Au NP1 ML curvature/NNN MeanCurvature.am` — Amira `.am` file containing the
  per-vertex mean curvature.

### Running the demo
1. Open MATLAB and set the current folder to this directory.
2. Run:
   ```matlab
   etchingRate
   ```
3. Results are written to the `localEtchingRate/` folder.

### Expected output
For each processed time point `NNN` (the loop runs over indices 1→13 in steps of
`skipping = 1`, comparing frames `stepSize = 5` apart), the script writes to
`localEtchingRate/`:
- `NNN.png` — 3D surface colored by local etching rate.
- `NNN.csv` — table with columns `Rate (nm/s)`, `Curvature (/nm)`, `Species`
  (0 = Pd, 1 = Au) for every surface vertex.
- `corelation_NNN.png` — scatter plot of etching rate vs. curvature (Au green, Pd red).
- `colorbar.png` — the shared color bar for the local-etching-rate maps.

### Expected run time (on a normal desktop)
- the full 13-frame demo completes in  ~10 minutes. 

---

## 4. Instructions for use (your own data)

1. Organize your reconstruction series into three folders mirroring the demo:
   surface meshes (`.obj`), segmentation stacks (`.tif`), and curvature files (`.am`),
   using the same zero-padded numbering.
2. Edit the parameters at the top of `etchingRate.m`:
   - `skipping` — stride between analyzed frames.
   - `stepSize` — frame separation used to compute displacement.
   - loop bound (`13`) — set to the number of time points in your series.
   - Update the file-name templates (e.g., `'Pd@Au NP1 ML prediction/121723-1-...'`)
     to match your naming.
3. Adjust the physical scaling factor **`75.8`** (average time interval in seconds
   between adjacent stages) to your acquisition, and the color-axis limits
   (`caxis`) / axis limits (`xlim/ylim/zlim`) as appropriate for your particle size.
4. Run `etchingRate` and collect results from `localEtchingRate/`.

> Note: the rate is computed as `displacement / stepSize / 75.8`, i.e., nm per second.
> Change `75.8` to your mean inter-frame time interval to keep the units correct.
