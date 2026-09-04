# 6.5 — Shape Signature Example

Codes to measure the shape signature *d(θ, φ)* and the resulting directional etching
rates from a 3D reconstruction series. Corresponds to **Supplementary Note §6.5** of
the manuscript *"Autonomous Liquid-Cell Electron Tomography for 4D Nanoparticle
Reaction Kinetics."*

The script `shapeSignatureAnalysis.m`:
1. reads the Wavefront surface meshes for each time point and extracts the shape
   signature *d(θ, φ)* (radial distance from the centroid as a function of
   polar/azimuthal angle);
2. visualizes each signature as a stereographic projection;
3. computes directional etching rates from the change in signature between frames; and
4. computes the time-averaged directional etching rate.

---

## 1. System requirements

### Software dependencies (tested versions)
- MATLAB **R2024a** 
- Helper functions bundled in the `utils/` folder (added to the path at the top of
  the script):
  - `readObj.m` — read Wavefront `.obj` mesh files
  - `signature_extractor.m` — extract the shape signature *d(θ, φ)*
  - `particleRot` — orientation alignment (defined inside the script)
- **M_Map** mapping toolbox, bundled in `utils/m_map/` (provides `m_proj`,
  `m_pcolor` for the stereographic projections).

### Operating systems tested
- Windows 11

### Hardware
- No non-standard hardware required. Runs on a normal desktop CPU.

---

## 2. Installation guide

1. Install MATLAB <R2024a>.
2. Download this folder, keeping the `utils/` and `utils/m_map/` subfolders intact
   (the script adds them to the path automatically via `addpath`).

**Typical install time:** No additional setup beyond MATLAB (< 1 minute to place
files). MATLAB itself typically installs in ~20–40 minutes.

---

## 3. Demo

### Data
Example input data are included in this folder:
```
6.5 shape signature example/
├── shapeSignatureAnalysis.m
├── utils/                          # helper functions
│   ├── readObj.m
│   ├── signature_extractor.m
│   └── m_map/                      # M_Map mapping toolbox
└── signature/
    ├── surfaceData/                # input meshes: 000.tif.obj ... 017.tif.obj
    ├── sigData/                    # output: extracted signatures (.mat)
    ├── sigVisualize/               # output: signature projection images (.png)
    └── rateVisualize/              # output: etching-rate projection images (.png)
```

**Input data format:**
- `signature/surfaceData/NNN.tif.obj` — Wavefront OBJ surface mesh for each of the
  18 time points (stages 000–017).

### Running the demo
1. Open MATLAB and set the current folder to this directory.
2. Run:
   ```matlab
   shapeSignatureAnalysis
   ```

### Expected output
- `signature/sigData/NNN.mat` — extracted shape signature *d(θ, φ)* for each stage,
  each a 91×181 array (θ ∈ [−90°, 90°] in 2° steps, φ ∈ [−180°, 180°] in 2° steps).
- `signature/sigVisualize/NNN.png` — stereographic projection of each signature,
  plus `colorbar.png`.
- `signature/rateVisualize/NNN.png` — directional etching-rate projections computed
  between frames `stepSize` (=5) apart, plus `colorbar.png`.
- `signature/rateVisualize/all.png` — time-averaged directional etching rate.

### Expected run time (on a normal desktop)
- **~10 hours** for the full 18-stage demo. The signature-extraction step
  (`signature_extractor`) is the dominant cost.

---

## 4. Instructions for use (your own data)

1. Place your per-stage surface meshes in `signature/surfaceData/` using the same
   zero-padded `NNN.tif.obj` naming.
2. Edit the parameters at the top of `shapeSignatureAnalysis.m`:
   - loop bounds (`0:1:17`) — set to the number of stages in your series.
   - `particleRot(obj.v, -12.5, 10, 0)` — adjust the alignment angles so your
     particle is oriented consistently across frames.
   - `stepSize` — frame separation used to compute directional rates.
   - the physical time scaling factor **`75.8`** (mean seconds between adjacent
     stages) — set to your acquisition's mean inter-frame interval.
   - color-axis limits (`clim`) for the signature and rate maps.
3. Run `shapeSignatureAnalysis` and collect results from the `signature/*` output
   folders.

> The rate is computed as `(sig(t) − sig(t+stepSize)) / stepSize / 75.8`, i.e., nm
> per second. Update `75.8` to keep the units correct for your data.
