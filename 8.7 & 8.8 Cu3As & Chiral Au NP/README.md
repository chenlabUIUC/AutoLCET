# 8.7 and 8.8 — Cu₃As Etching-Site and Chiral Au Nanoparticle Analysis

Codes to analyze local etching behavior in Cu₃As nanoparticles and quantify the
shape chirality of gold helicoid nanoparticles. These analyses correspond to
**Supplementary Note §§8.7–8.8** of the manuscript *"Autonomous Liquid-Cell
Electron Tomography for 4D Nanoparticle Reaction Kinetics."*

The notebook `surface_analysis.ipynb` contains two workflows:

1. **Cu₃As etching-site analysis** — relates local surface curvature to local
   etching rate within selected regions of a triangular surface mesh.
2. **Chiral Au nanoparticle analysis** — calculates surface imprints from binarized
   3D tomograms and measures their asymmetry under different mirror operations.

---

## 1. System requirements

### Software dependencies

The notebook metadata records Python 3.13.5. The following environment uses the
latest stable compatible releases available at the end of 2025:

- Python **3.14.2**
- NumPy **2.3.5**
- SciPy **1.16.3**
- Matplotlib **3.10.8**
- PyVista **0.46.4**
- tifffile **2025.12.20**
- JupyterLab or Jupyter Notebook

### Operating systems

- Windows 10 or Windows 11
- Linux and macOS should also work if the required Python packages and a compatible
  PyVista/VTK graphics backend are available

### Hardware

No GPU or specialized hardware is required. A normal desktop CPU and at least 8 GB
of RAM are sufficient for the included demonstration data.

Interactive PyVista mesh visualization requires a graphical desktop environment.
The numerical analysis can be run without displaying the optional 3D plots.

---

## 2. Installation guide

Create a dedicated Python environment:

```bash
conda create -n surface-analysis python=3.14.2
conda activate surface-analysis
pip install numpy==2.3.5 scipy==1.16.3 matplotlib==3.10.8 \
            pyvista==0.46.4 tifffile==2025.12.20 jupyterlab
```

Then launch Jupyter:

```bash
jupyter lab surface_analysis.ipynb
```

**Typical installation time:** approximately 5–10 minutes on a normal desktop with
a broadband connection. PyVista and its VTK dependency account for most of the
download and installation time.

---

## 3. Demo

### Data

The repository includes the data needed to run both analyses:

```text
8.7 & 8.8 Cu3As & Chiral Au NP/
├── surface_analysis.ipynb
├── surface Cu3As/
│   ├── 000.obj ... 006.obj
│   └── 000.am  ... 006.am
├── localEtchingRate_t_t+2/
│   ├── 000.csv ... 004.csv
│   ├── 000.png ... 004.png
│   └── colorbar.png
└── Chiral Au NP/
    ├── 000.labels.tif ... 006.labels.tif
    └── 000.labels_top17proj.png
        ...
```

The notebook must be run with this directory as its working directory so its
relative paths resolve correctly.

---

## 4. Cu₃As etching-site analysis

### Input data

The Cu₃As workflow uses three files for each analyzed stage:

- `surface Cu3As/NNN.obj` — triangular surface mesh generated in Amira.
- `surface Cu3As/NNN.am` — per-vertex surface-curvature values exported from Amira.
- `localEtchingRate_t_t+2/NNN.csv` — per-vertex local etching rates calculated using
  the procedure in Supplementary Note §8.4.

The curvature and etching-rate arrays must contain one value for every vertex in
the corresponding OBJ mesh, in the same vertex order.

The included notebook processes stages `000` through `004`, because local etching
rate files are included for those five stages.

### Analysis method

For the first stage, the notebook defines an initial etching center as the mesh
vertex with the highest local etching rate. For each later stage, it finds the
vertex with the shortest Euclidean distance to the preceding center position.

The notebook constructs a weighted graph from the triangular mesh:

- each mesh vertex becomes a graph node;
- each triangle edge becomes a graph edge; and
- the Euclidean edge length becomes the graph-edge weight.

SciPy's Dijkstra algorithm then calculates the geodesic distance from the selected
origin to every vertex on the surface.

The notebook visualizes local curvature against local etching rate, with points
colored according to their geodesic distance from the selected origin. It also
compares two surface regions based on their relative geodesic distances and
calculates binned summary statistics.

### Running the analysis

1. Open `surface_analysis.ipynb`.
2. Run the cells under **“8.7 Analysis of etching sites in Cu3As NPs”** in order.
3. In the optional PyVista window, click a mesh vertex if a manually selected
   origin is desired.
4. By default, the notebook uses the vertex with the highest local etching rate as
   the origin.
5. Review the curvature-versus-etching-rate plots and the geodesic-distance
   visualization for each stage.

### Expected output

The workflow produces:

- scatter plots of curvature versus local etching rate for stages `000–004`;
- interactive surface meshes colored by geodesic distance;
- arrays named `hotspot1` and `hotspot2` containing curvature and etching-rate
  values for two surface regions; and
- comparison plots containing raw data and binned summary statistics for the two
  regions.

These figures and arrays are displayed or retained in the notebook session. They
are not automatically saved to disk.

### Scientific definition of the etching sites

In the associated analysis, each etching site is defined as the region within a
**25 nm geodesic radius** of its center.

At the first stage:

- center 1 is the surface point with the highest local etching rate; and
- center 2 is the surface point with the greatest geodesic distance from center 1.

At each subsequent stage, each center is propagated to the point on the new mesh
with the shortest Euclidean distance from its position in the preceding stage.

> The current demonstration notebook divides the mesh using relative geodesic
> distance thresholds (`<20%` and `>80%` of the maximum distance). To reproduce the
> manuscript's 25 nm site definition exactly, replace these relative thresholds
> with masks selecting vertices within 25 nm of each tracked center.

---

## 5. Chiral Au nanoparticle analysis

### Input data

The chirality workflow reads seven binarized 3D tomograms:

```text
Chiral Au NP/000.labels.tif
...
Chiral Au NP/006.labels.tif
```

Each file must be a three-dimensional TIFF volume in which:

- values greater than the background threshold represent the nanoparticle; and
- background voxels are zero.

The volumes must have a consistent orientation. The positive z-direction is defined
as pointing opposite to the incident electron beam, with the highest occupied
z-values representing the upper surface used to form the surface imprint.

### Surface-imprint calculation

For each tomogram, the notebook:

1. finds the occupied extent of the nanoparticle along z;
2. selects a fraction of that extent at the highest z-values;
3. sums the selected voxels along z to form a two-dimensional surface imprint;
4. applies a twofold rotational overlay to reduce sensitivity to isolated defects;
   and
5. compares the imprint with horizontal, vertical, and diagonal mirror images.

The manuscript defines the surface imprint using the upper 20% of the occupied
z-extent:

```text
SI(x,y) = sum of I(x,y,z) over the upper 20% of the particle
```

The notebook currently uses `top_frac=0.17`, corresponding to the upper 17%, for
the included demonstration.

### Chirality metrics

The notebook calculates several complementary descriptors:

- `A_x` — normalized left-right mirror asymmetry;
- `A_y` — normalized up-down mirror asymmetry;
- `A_main` — normalized main-diagonal mirror asymmetry;
- `A_anti` — normalized anti-diagonal mirror asymmetry;
- `H_pseudo` — signed handedness pseudoscalar;
- `HU_phi7` — seventh Hu moment, whose sign changes under reflection; and
- `HU_phi7_log` — signed logarithmic form of the seventh Hu moment.

The plotted quantities corresponding most closely to the manuscript's
\(D_\sigma\) comparison are:

- `A_x` for the vertical mirror plane; and
- `A_main` for the diagonal mirror plane.

These notebook values are normalized L1 differences, which reduces sensitivity to
changes in particle size and total imprint intensity.

### Running the analysis

1. Run the cells under **“8.8 Characterizing of shape chirality”** in order.
2. Confirm that:

   ```python
   tif_dir = "Chiral Au NP/"
   ```

3. Set the desired surface fraction:

   ```python
   top_frac = 0.20
   ```

   Use `0.17` to reproduce the current notebook demonstration.

4. Run the projection and metric-calculation cells.
5. Run the final cell to plot mirror asymmetry as a function of etching time.

### Expected output

For each input TIFF, the notebook writes a surface-imprint image beside the source
volume:

```text
NNN.labels_top17proj.png
```

The suffix changes if a different `top_frac` is used.

The notebook also creates:

- the `projs` list containing the seven surface-imprint arrays;
- arrays containing each chirality metric across the seven stages; and
- a plot of horizontal and diagonal mirror asymmetry versus time from 0 to 1614 s.

The metric arrays and final plot are not automatically saved to disk.

### Interpretation

A mirror-asymmetry value near zero indicates that the surface imprint is nearly
symmetric under the corresponding reflection. A larger value indicates stronger
mirror-symmetry breaking.

The signed handedness and seventh Hu-moment metrics can distinguish reflected
versions of a shape, whereas the unsigned mirror-asymmetry values quantify the
degree of asymmetry without independently assigning handedness.

---

## 6. Expected run time

The complete notebook should normally run in a few minutes for the included meshes
and seven TIFF volumes on a modern desktop CPU.

Interactive PyVista rendering time depends on the graphics driver and display
environment. Larger meshes increase the memory and runtime required by the
all-vertex Dijkstra calculation.

---

## 7. Instructions for use with your own data

### Cu₃As etching-site analysis

1. Export a triangular OBJ surface mesh for every stage.
2. Export one curvature value for every mesh vertex in Amira ASCII format.
3. Calculate the corresponding per-vertex local etching rates.
4. Use matching zero-padded filenames for the mesh, curvature, and rate files.
5. Update `curvature_dir`, `etching_dir`, and `model_dir` in the notebook.
6. Update the loop range to match the number of available stages.
7. Confirm that the mesh coordinates are expressed in nanometers before applying
   a 25 nm geodesic-radius threshold.

### Chiral Au nanoparticle analysis

1. Prepare spatially registered and consistently oriented binary 3D TIFF volumes.
2. Place them in a dedicated directory using chronological, zero-padded filenames.
3. Update `tif_dir` and the loop range in the notebook.
4. Confirm which array axis corresponds to the electron-beam direction.
5. Set `top_frac` to the desired fraction of the occupied z-extent.
6. Replace the hard-coded time array:

   ```python
   ts = np.linspace(0, 1614, 7)
   ```

   with the acquisition times for your dataset.

> The surface-imprint calculation assumes that array axis 2 is the z-axis. Transpose
> the TIFF arrays before analysis if the slice axis or beam direction is stored on
> another array axis.

> Mesh coordinates, curvature values, and etching rates must use consistent spatial
> calibration and vertex ordering.

> The meshes must remain in a common coordinate system across stages for nearest-
> point tracking of the etching centers to be meaningful.
