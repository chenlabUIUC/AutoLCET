# 8.6 — 3D Moment Invariant Example

Codes to quantify the symmetry and asymmetry of nanoparticles during etching using
three-dimensional moment invariants. This example corresponds to **Supplementary
Note §8.6** of the manuscript *"Autonomous Liquid-Cell Electron Tomography for 4D
Nanoparticle Reaction Kinetics."*

The main script, `Moments_Invariant_Calculation.m`, analyzes time-resolved binary
3D nanoparticle volumes. It calculates moment invariants for:

1. the complete nanoparticle at each time point; and
2. the cumulatively etched region, defined as the voxel-wise difference between the
   initial particle and the particle at each subsequent time point.

The included `moments_3d.m` function calculates three second-order invariants
(`J1`, `J2`, and `J3`) and two third-order invariants (`I1` and `I2`). In the
associated study, `I2` is used to measure central-symmetry breaking in the etched
region.

---

## 1. System requirements

### Software dependencies

- MATLAB **R2025b**
- Image Processing Toolbox
  - Required for `tiffreadVolume`
- No third-party MATLAB packages are required

The code uses `tiffreadVolume`, which was introduced in MATLAB R2020b. MATLAB
R2025b is the latest MATLAB release available at the end of 2025.

### Operating systems

- Windows 10 or Windows 11
- The current scripts use Windows-style path separators (`\`)

The calculation itself is platform-independent, but the file paths should be
changed to use `fullfile` throughout before running the scripts on macOS or Linux.

### Hardware

No specialized hardware or GPU is required. A normal desktop CPU is sufficient.

The complete contents of each TIFF volume are loaded into memory as double-precision
arrays. Available RAM should therefore be several times larger than the combined
size of the volumes being processed.

---

## 2. Installation guide

1. Install MATLAB R2025b with the Image Processing Toolbox.
2. Download this directory while preserving its internal folder structure.
3. Open MATLAB and set the current folder to `8.6 moment invariant example`.

No additional packages need to be installed.

**Typical setup time:** less than 1 minute after MATLAB and the Image Processing
Toolbox are installed.

---

## 3. Demo

### Data

Two example nanoparticle trajectories are included:

```text
8.6 moment invariant example/
├── Moments_Invariant_Calculation.m
├── moments_3d.m
└── Example/
    ├── Chiral Au NP/
    │   ├── 000.labels.tif
    │   ├── 001.labels.tif
    │   ├── ...
    │   └── 006.labels.tif
    └── Cu3As/
        ├── 000.labels.tif
        ├── 001.labels.tif
        ├── ...
        └── 006.labels.tif
```

Each subdirectory under `Example/` represents one nanoparticle trajectory. The
included chiral Au and Cu₃As trajectories each contain seven sequential 3D TIFF
volumes.

The volumes are expected to be:

- multi-page 3D TIFF stacks;
- spatially registered across time;
- ordered using filenames that begin with a zero-padded integer; and
- binarized so particle voxels are 1 and background voxels are 0.

The script converts each TIFF stack to double precision and assigns voxels with the
maximum image value to 1.

### Running the demo

1. Open MATLAB.
2. Set the current folder to this directory.
3. Run:

   ```matlab
   Moments_Invariant_Calculation
   ```

The script automatically:

1. finds each trajectory under `Example/`;
2. sorts its TIFF files by the integer at the beginning of each filename;
3. loads the volumes in chronological order;
4. calculates the invariants of every complete particle;
5. calculates the center of mass of each initial particle;
6. constructs each etched region as `V_initial - V_current`;
7. calculates the etched-region invariants using the initial particle's fixed
   center of mass; and
8. plots each invariant as a function of the time-point index.

### Expected output

The calculated results are stored in the MATLAB workspace in the `sortedFiles`
structure. For each trajectory, the structure contains:

- `directory` — trajectory name;
- `fileNames` — chronologically sorted TIFF filenames;
- `trajectory` — loaded 3D volumes;
- `CoM` — center of mass of the initial particle;
- `moments` — complete-particle invariants; and
- `moments_etched` — etched-region invariants calculated using the fixed initial
  center of mass.

The columns of `moments` and `moments_etched` are ordered as:

```text
J1, J2, J3, I1, I2
```

The script opens ten MATLAB figures:

- five plots for the complete-particle invariants; and
- five plots for the etched-region invariants.

Each plot compares all trajectories found under `Example/`. Figures and numerical
results are not automatically saved to disk.

### Interpretation of `I2`

Normalized central moments make the calculated quantities invariant to translation
and uniform scaling. Their combinations are also invariant to rotation.

Second-order invariants primarily describe global shape anisotropy. The third-order
invariant `I2` is sensitive to central symmetry:

- `I2 = 0` for an ideally centrally symmetric shape; and
- larger magnitudes indicate greater central-symmetry breaking.

For the etched-region calculation, the center of mass is fixed to that of the
original, unetched nanoparticle. This makes `I2` sensitive to spatially asymmetric
material removal relative to the original particle.

### Expected run time

Runtime depends primarily on the dimensions and number of TIFF volumes. The included
14-volume example should normally complete within a few minutes on a modern desktop
CPU. Larger volumes require proportionally more memory and processing time.

---

## 4. Instructions for use with your own data

1. Create a parent directory containing one subdirectory for each nanoparticle
   trajectory:

   ```text
   MyData/
   ├── Particle_1/
   │   ├── 000.tif
   │   ├── 001.tif
   │   └── ...
   └── Particle_2/
       ├── 000.tif
       ├── 001.tif
       └── ...
   ```

2. Ensure that all volumes within a trajectory:

   - are spatially registered;
   - have identical dimensions;
   - use the same voxel size;
   - are binary;
   - use 1 for the nanoparticle and 0 for the background; and
   - are ordered chronologically by a numeric filename prefix.

3. Change the parent directory near the beginning of
   `Moments_Invariant_Calculation.m`:

   ```matlab
   master_dir = 'MyData';
   ```

4. Run:

   ```matlab
   Moments_Invariant_Calculation
   ```

5. Read the results from `sortedFiles(i).moments` and
   `sortedFiles(i).moments_etched`.

> The etched-region calculation assumes that the nanoparticle only loses material:
> `V_initial - V_current` should produce a non-negative binary volume. Segmentation
> noise, particle growth, or inconsistent registration can produce negative values
> and invalidate this interpretation.

> All volumes in a trajectory must share a common coordinate system. Register and
> align the reconstructions before calculating the moment invariants.

> If the TIFF volumes contain multiple labels rather than a binary mask, convert the
> desired particle label to a logical mask before running the calculation.
