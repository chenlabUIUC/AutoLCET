# Autonomous Liquid-Cell Electron Tomography for 4D Nanoparticle Reaction Kinetics

Codes for the manuscript **"Autonomous Liquid-Cell Electron Tomography for 4D
Nanoparticle Reaction Kinetics."**

- **DOI:** [Pending]
- **License:** See [LICENSE](./LICENSE) (MIT)
- **Code functionality / pseudocode:** described in the **Supplementary Note** of the
  Supporting Information; each folder below maps to the indicated subsection.

**Authors:** Zhiheng Lyu, Lehan Yao, Carlos L. Bassan, Xingzhi Wang, Junseo Lee,
Shengsong Yang, Binyu Wu, Falon C. Kalutantirige, Sohini Mandal, John R. Crockett,
Seoeun Seol, Jiwoong Park, Maria K. Chan, Gregory S. Girolami, Robert F. Klie,
A. Paul Alivisatos, Michael Engel, Qian Chen.

---

## About this repository

This repository is **not a single software package**. It is a collection of
independent analysis modules and acquisition tools, each in its own folder. Because
the modules use very different environments (Python/Colab, MATLAB, deep-learning and
tomography libraries), **system requirements, installation, demo data, expected
output, and run times are documented in the `README.md` inside each folder.**

A small demo dataset is provided with each module (either included in the folder or
linked for download in that folder's README) so the code can be tested.

---

## Contents

### Data analysis (Supplementary Note subsections)

| Folder | Supp. Note | Language | Description |
|---|---|---|---|
| **2 error estimation example** | §2 | <MATLAB/Python> | Estimate 3D reconstruction errors when the shape transforms during tilt-series acquisition |
| **6.1 3D U-Net segmentation example** | §6.1 | Python | 3D U-Net segmentation of two elements in a 3D reconstruction |
| **6.2 U-Net for contrast correction example** | §6.2 | Python | U-Net correction of contrast inversion in STEM projections of thick nanoparticle samples |
| **6.4 local etching rate example** | §6.4 | MATLAB | Measure the local etching rate on the surface from a 3D reconstruction series |
| **6.5 shape signature example** | §6.5 | MATLAB | Measure the shape signature *d(θ, φ)* for directional etching rates from a 3D reconstruction series |
| **6.6 moment invariant example** | §6.6 | <MATLAB/Python> | Measure moment invariants from 3D reconstructions |
| **6.7 & 6.8 Cu₃As & chiral Au nanoparticles** | §6.7–6.8 | <MATLAB/Python> | Analysis of Cu₃As and chiral Au nanoparticles |
| **6.9 facet analysis example** | §6.9 | MATLAB | Assign low-index lattice facets to the surface of a 3D reconstruction |

### Fast electron tomography pipeline

| Folder | Language | Description |
|---|---|---|
| **AutoLCET data collection** | Python (GUI) | Application with a GUI for rapid electron tomography tilt-series acquisition with real-time particle tracking |
| **tilt series extraction example** | MATLAB & Python | Extract useful frames (projections) from the raw acquisition to generate tilt series |
| **alignment and reconstruction example** | Python | Align projections in the tilt series and perform 3D reconstruction via MBIR |

> The three pipeline modules are meant to be run in order:
> **AutoLCET data collection → tilt series extraction → alignment and reconstruction.**

---

## Usage

For system requirements, installation, demo instructions, expected output, and run
times, please refer to the `README.md` file inside each individual folder.

## Citation

If you use this code, please cite:

> <citation to be added upon publication>
