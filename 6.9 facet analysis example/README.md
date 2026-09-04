# 6.9 — Facet Analysis Example

Codes to assign low-index lattice facets ({100}, {110}, {111}) to the surface of a
3D reconstruction and track their surface-area fractions over a reconstruction
series. Corresponds to **Supplementary Note §6.9** of the manuscript
*"Autonomous Liquid-Cell Electron Tomography for 4D Nanoparticle Reaction Kinetics."*

The script `facetAnalysis.m` reads each surface mesh, orients it to the crystal
reference frame, computes per-face surface normals, maps each normal to an RGB color
encoding its proximity to the {100}/{110}/{111} families, renders the facet-colored
surface, and computes the fraction of surface assigned to each facet family for each
stage.

---

## 1. System requirements

### Software dependencies (tested versions)
- MATLAB **R2024a** <confirm — please state the version you tested on>
- Helper function required on the MATLAB path / in this folder:
  - `readObj.m` — read Wavefront `.obj` mesh files
- The following functions are defined inside `facetAnalysis.m` and need no separate
  installation: `snapShot`, `COM`, `particleRot`, `computeMeshNormals`,
  `mapNormalsToRGB`, `applySV_to_cm`.

> Uses only core MATLAB (no additional toolboxes required for the main analysis).

### Operating systems tested
- Windows 11

### Hardware
- No non-standard hardware required. Runs on a normal desktop CPU.

---

## 2. Installation guide

1. Install MATLAB <R2024a>.
2. Download this folder, including the demo data folder `surfaceData/`.
3. Ensure `readObj.m` is present in this folder or on your MATLAB path.

**Typical install time:** No additional setup beyond MATLAB (< 1 minute to place
files). MATLAB itself typically installs in ~20–40 minutes.

---

## 3. Demo

### Data
Example input data are included in this folder:
```
6.9 facet analysis example/
├── facetAnalysis.m
├── readObj.m                # helper (must be present)
├── surfaceData/             # input surface meshes (*.obj)
└── facetVisualize/          # output folder (facet-colored renderings)
```

**Input data format:**
- `surfaceData/*.obj` — Wavefront OBJ surface meshes, one per stage.
- Note: the script chooses the orientation via `~strcmp(fileList(i).name(8),'1')`,
  i.e., it inspects the **8th character of each filename** to decide which rotation
  preset to apply. Keep your filenames consistent with this convention (see
  Instructions for use).

### Running the demo
1. Open MATLAB and set the current folder to this directory.
2. Run:
   ```matlab
   facetAnalysis
   ```

### Expected output
- `facetVisualize/<filename>.obj.png` — the facet-colored 3D surface rendering for
  each input mesh (red ≈ {100}, green ≈ {110}, blue ≈ {111}).
- A live line plot (Figure 2) of the surface-area **fraction** of each facet family
  ({100}, {110}, {111}) as a function of stage. <If you want this saved, add a
  `saveas(figure(2), 'facetVisualize/fractions.png')` after the loop.>

### Expected run time (on a normal desktop)
- The full demo completes in ~5 minutes.

---

## 4. Instructions for use (your own data)

1. Place your per-stage surface meshes (`.obj`) in `surfaceData/`.
2. **Orientation alignment (important):** the facet assignment assumes the mesh is
   aligned to the crystallographic axes. Adjust the `particleRot(...)` calls inside
   the `snapShot` function so your particle's crystal axes align with x/y/z. The
   script currently applies one of two rotation presets depending on the 8th
   character of the filename (`'1'` vs. otherwise) — edit this logic / the angles to
   match your dataset and naming.
3. The facet-fraction threshold is `cm > 0.95` (a face is counted toward a family if
   its color component exceeds 0.95). Adjust this threshold if needed.
4. The color rescaling `(cm-0.82)/(1-0.82)` only affects the visualization contrast,
   not the quantified fractions.
5. Run `facetAnalysis` and collect renderings from `facetVisualize/` and the
   facet-fraction plot (Figure 2).
