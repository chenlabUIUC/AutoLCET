# Reconstruction Error Estimation Example

Codes to evaluate how nanoparticle reaction time and tilt-series collection time
affect the accuracy of 3D electron-tomography reconstructions. This workflow
corresponds to **Supplementary Note §3.1** of the manuscript *"Autonomous
Liquid-Cell Electron Tomography for 4D Nanoparticle Reaction Kinetics."*

The workflow creates shrinking spherical nanoparticle models, simulates tilt-series
acquisition while the particles are etching, reconstructs the simulated projections
with SVMBIR, and compares the reconstructions with the known ground-truth volumes.

Two error metrics are calculated:

- **Volumetric error** — the normalized difference between the reconstructed and
  ground-truth particle volumes.
- **Voxel-wise error** — the normalized number of differing voxels between the
  binarized reconstruction and ground truth.

---

## 1. Workflow overview

The analysis consists of four sequential steps:

1. `Step0 V_t_fitting.ipynb`
   - Reads experimentally measured nanoparticle volumes.
   - Calculates volumetric etching rates.
   - Optionally fits piecewise-linear volume-versus-time models.
2. `Step1 simulated_etching.ipynb`
   - Generates spherical binary particle models.
   - Shrinks their volumes using experimentally measured etching rates.
   - Saves a time-resolved ground-truth trajectory as 3D TIFF volumes.
3. `Step2 reproject_series.m`
   - Samples the changing particle models at the experimental tilt angles.
   - Uses the ASTRA Toolbox to calculate GPU-accelerated 3D forward projections.
   - Assembles the projections into simulated tilt-series TIFF stacks.
4. `Step3 recon_error_estimation.ipynb`
   - Reconstructs the simulated tilt series with SVMBIR.
   - Segments the reconstructed particles using ISODATA thresholding and Gaussian
     smoothing.
   - Calculates volumetric and voxel-wise errors.
   - Plots reconstruction error as a function of acquisition time.

Run these steps in numerical order.

---

## 2. System requirements

### Python dependencies

The following versions correspond to stable releases available at the end of 2025:

- Python **3.14.2**
- NumPy **2.3.5**
- pandas **2.3.3**
- Matplotlib **3.10.8**
- tifffile **2025.12.20**
- scikit-image **0.26.0**
- tqdm **4.67.1**
- SVMBIR **0.4.0**
- JupyterLab or Jupyter Notebook

`Step0 V_t_fitting.ipynb` also imports a module named `pwlr` for automatic
piecewise-linear regression. That module is not included in this repository and is
not required by the later simulation steps because the fitted etching-rate values
are already entered explicitly in `Step1 simulated_etching.ipynb`.

If `pwlr` is unavailable, skip the piecewise-fitting cells or supply the original
module that defines:

```python
piecewise_linear_regression
plot_piecewise_fit
```

### MATLAB dependencies

- MATLAB **R2025b**
- Image Processing Toolbox
- ASTRA Toolbox **1.9.0.dev11 for 64-bit Windows**
- A compatible NVIDIA CUDA installation

The code expects ASTRA to be located at:

```text
astra-1.9.0.dev11-matlab-win-x64/
└── astra-1.9.0.dev11/
    ├── tools/
    └── mex/
```

The scripts use functions including `tiffreadVolume`, `imwrite`, and `imshow`.

The included `utils/` directory also contains Windows MEX binaries and their C++
source files:

```text
ray_tracing_mex.mexw64
rasterization_mex.mexw64
```

These helper binaries are compiled for 64-bit Windows. Recompile the corresponding
`.cpp` files before using them on another operating system or with an incompatible
MATLAB installation.

### Operating systems

- Windows 10 or Windows 11 is required for the supplied ASTRA build and MEX
  binaries.
- The SVMBIR reconstruction step is most reliably run on Ubuntu 22.04 or a newer
  compatible Linux distribution.

The Python notebooks can be run on Windows or Linux, subject to SVMBIR installation
support.

### Hardware

- A CUDA-capable NVIDIA GPU is required for the ASTRA forward-projection step
  (`astra_create_sino3d_cuda`).
- A multicore CPU is recommended for SVMBIR reconstruction.
- At least 16 GB of RAM is recommended.
- Several gigabytes of free storage may be required for a complete simulation over
  all particles and acquisition times.

---

## 3. Installation guide

### Python environment

Create a dedicated environment:

```bash
conda create -n error-estimation python=3.14.2
conda activate error-estimation
pip install numpy==2.3.5 pandas==2.3.3 matplotlib==3.10.8 \
            tifffile==2025.12.20 scikit-image==0.26.0 \
            tqdm==4.67.1 svmbir==0.4.0 jupyterlab
```

If SVMBIR cannot be installed with Python 3.14, create a separate Python 3.10
environment for `Step3 recon_error_estimation.ipynb`, following the environment
instructions in `alignment and reconstruction example/README.md`.

### MATLAB and ASTRA

1. Install MATLAB R2025b with the Image Processing Toolbox.
2. Download `astra-1.9.0.dev11-matlab-win-x64`.
3. Extract the ASTRA directory into `error estimation example/`.
4. Preserve the expected directory structure:

   ```text
   error estimation example/
   ├── astra-1.9.0.dev11-matlab-win-x64/
   │   └── astra-1.9.0.dev11/
   │       ├── tools/
   │       └── mex/
   ├── read_and_simulate_series.m
   └── Step2 reproject_series.m
   ```

5. Confirm that MATLAB can access the NVIDIA GPU and load the ASTRA MEX files.

The paths in `read_and_simulate_series.m` already match this directory structure,
so no path modification is needed when ASTRA is installed in the specified location.

**Typical installation time:** approximately 15–30 minutes after MATLAB and a
compatible CUDA installation are available.

---

## 4. Included files

```text
error estimation example/
├── Volume data for all NPs.csv
├── Step0 V_t_fitting.ipynb
├── Step1 simulated_etching.ipynb
├── Step2 reproject_series.m
├── read_and_simulate_series.m
├── Step3 recon_error_estimation.ipynb
└── utils/
    ├── image_generator.m
    ├── imshow3D.m
    ├── inpolyhedron.m
    ├── myImtranslate.m
    ├── rasterization_mex.cpp
    ├── rasterization_mex.mexw64
    ├── ray_tracing_mex.cpp
    ├── ray_tracing_mex.mexw64
    ├── readObj.m
    └── rotational_avg.m
```

Only the experimental volume table and source code are included initially. The
simulated volumes, projection stacks, reconstructions, and error results are
generated by running the workflow.

---

## 5. Step 0 — Fit experimental etching rates

Open `Step0 V_t_fitting.ipynb`. The notebook reads:

```text
Volume data for all NPs.csv
```

Every three adjacent columns in the CSV represent one nanoparticle:

```text
time, volume, normalized volume
```

The notebook parses the experimental volume trajectories, plots particle volume
and normalized volume versus time, calculates interval-by-interval volumetric
etching rates and percentage volume loss, and optionally fits as many as three
piecewise-linear regimes using Bayesian information criterion model selection.

The fitted slopes provide volumetric etching rates in cubic nanometers per second.

### Expected output

- Volume-versus-time and normalized-volume plots
- Etching-rate and percentage-volume-loss plots
- Piecewise-linear fits and fitted slope values

These results are displayed in the notebook and are not automatically saved.

> The notebook attempts to load `Arial.ttf` from its working directory. Update
> `arial_ttf_path` to an installed Arial font file, or skip the font-configuration
> cell.

---

## 6. Step 1 — Generate simulated etching trajectories

Open `Step1 simulated_etching.ipynb`.

The `simulated_etching` class creates a binary spherical model with a specified
voxel size, initial physical volume, piecewise volumetric etching rate, total
reaction time, and simulation-array size. The sphere shrinks according to:

```text
V(t + dt) = V(t) - etching_rate(t) × dt
```

The default array size is `121 × 151 × 151` voxels. The simulated voxel sizes are
twice those of the corresponding experimental reconstructions to reduce
computational cost.

### Included particle models

The notebook defines parameters for `PdAu1`, `PdAu3`, `PdPt1`, `PdRu`, `Cu3As`,
and `ChiralAu`. The main acquisition-time comparison generates trajectories for
Pd@Au-1, Pd@Pt-1, and chiral Au.

### Collection times

The complete collection-time series is:

```text
30, 60, 90, 120, 180, 240, 300, and 360 seconds
```

The notebook currently sets:

```python
stage_t = [300, 360]
```

Change this to the complete list to generate every condition:

```python
stage_t = [30, 60, 90, 120, 180, 240, 300, 360]
```

### Expected output

Ground-truth volumes are written to directories such as:

```text
simulated_outputs/
├── PdAu1_30s/
├── PdPt1_30s/
├── ChiralAu_30s/
├── ...
├── PdAu1_360s/
├── PdPt1_360s/
└── ChiralAu_360s/
```

Each directory contains a chronological series of binary TIFF volumes with names
such as `0000 s.tif`, `0001 s.tif`, and so on.

---

## 7. Step 2 — Simulate tilt-series acquisition

Open MATLAB, set the current folder to this directory, and run:

```matlab
Step2 reproject_series
```

For every particle and selected collection time, the script loads the changing
spherical models, groups them into overlapping tilt-series acquisition windows,
chooses one ground-truth volume for each tilt angle, generates a parallel-beam 3D
projection using ASTRA and the GPU, normalizes the projection, and writes the
projections as a multi-page TIFF stack.

### Tilt-angle schemes

- **Pd@Au-1:** −55° to 60° in 5° increments
- **Pd@Pt-1:** −60° to 50° in 2.5° increments
- **Chiral Au:** −60° to 55° in 2.5° increments

These ranges match the corresponding experimental acquisition conditions.

### Expected output

Each simulated trajectory receives a `sims/` directory:

```text
simulated_outputs/PdAu1_30s/sims/
├── stage_1.tif
├── stage_2.tif
└── ...
```

Each `stage_N.tif` is a simulated tilt-series projection stack.

The script also writes an index matrix for every condition:

```text
reprojections/
├── Idx_PdAu1_30s.csv
├── Idx_PdPt1_30s.csv
├── Idx_ChiralAu_30s.csv
└── ...
```

Each row records the ground-truth trajectory indices sampled while generating one
tilt series. The last index identifies the ground-truth particle at the end of that
tilt-series acquisition.

> Create the `reprojections/` directory before running this step.

---

## 8. Step 3 — Reconstruct and calculate errors

Open `Step3 recon_error_estimation.ipynb`.

The notebook discovers the simulated-output directories, determines their
tilt-angle ranges from the particle names, and reconstructs every `stage_N.tif`
stack using:

```python
svmbir.recon(
    data,
    angles,
    stop_threshold=0.002,
    max_iterations=2000
)
```

Reconstructions are written to:

```text
recon/<particle_condition>/stage_N_recon.tif
```

### Index-file location

The error-analysis cells currently look for index files under `recon/`:

```text
recon/Idx_<particle_condition>.csv
```

However, the MATLAB script writes them under `reprojections/`. Before calculating
errors, either copy the CSV files into `recon/` or update the path in the notebook:

```python
gt_idx = np.loadtxt(
    "reprojections/Idx_" + sample + ".csv",
    delimiter=","
)[:, -1]
```

### Segmentation

Each reconstruction is segmented using ISODATA thresholding, Gaussian smoothing
with `sigma=3`, truncation at one standard deviation, and binary thresholding at
0.5. The reconstructed volume is center-cropped to the dimensions of the
ground-truth model before voxel-wise comparison.

### Error definitions

The volumetric error is:

```text
|V_reconstruction - V_ground_truth| / V_ground_truth
```

The voxel-wise error is:

```text
number of voxels that differ / number of ground-truth particle voxels
```

The ground truth is the simulated particle volume at the end of the corresponding
tilt-series acquisition.

### Expected output

- Reconstructed 3D TIFF volumes
- Volumetric-error and voxel-wise-error arrays
- Reconstructed and ground-truth volume arrays
- Mean error values printed for each particle and collection time
- Plots of both error metrics versus reaction time

The plots include a dashed 10% reference line. Figures and numerical error tables
are not automatically saved.

> In the current notebook, the cell containing `keys = sorted(keys, key=sort_key)`
> appears before `keys` is initialized. Run the later cell that assigns
> `keys = list(errors.keys())`, or move that assignment before the sorting cell.

---

## 9. Expected run time

Runtime depends strongly on the number of collection times, simulated stages,
projection angles, and SVMBIR iterations.

- Experimental-rate fitting: typically less than 1 minute.
- Spherical trajectory generation: typically several minutes.
- ASTRA reprojection: typically several minutes per condition on a CUDA GPU.
- SVMBIR reconstruction: potentially tens of minutes per tilt series on a CPU.

A complete sweep over three particles and eight collection times can require many
hours and should be run with sufficient storage. To test the workflow quickly,
generate one collection time and reconstruct one `stage_N.tif` stack first.

---

## 10. Instructions for use with your own data

1. Add the measured nanoparticle time and volume data to
   `Volume data for all NPs.csv`.
2. Use `Step0 V_t_fitting.ipynb` to determine the relevant piecewise volumetric
   etching rates.
3. Define a new `simulated_etching` object with the particle's initial volume,
   voxel size, etching-rate intervals, and reaction duration.
4. Set the simulated tilt-angle range and increment to match the experiment.
5. Add the new particle to `Step2 reproject_series.m`.
6. Add its four-character name prefix and angle range to the `angle_ranges`
   dictionary in `Step3 recon_error_estimation.ipynb`.
7. Generate the models, reproject them, reconstruct them, and calculate errors in
   numerical order.

> Particle-directory names are used programmatically. The first four characters
> must match a key in the `angle_ranges` dictionary.

> Use identical spatial calibration for the reconstructed and ground-truth
> volumes. The voxel-wise calculation assumes that both particles are centered and
> differ only in array size.

> ASTRA projection geometry is marked as carefully calibrated in
> `read_and_simulate_series.m`. Validate the axis ordering and added `pi/2` angular
> offset before adapting the code to a different volume convention.

> The spherical model represents uniform, isotropic etching. It isolates temporal
> reconstruction error but does not reproduce localized etching, faceting, or other
> shape-dependent reaction mechanisms.
