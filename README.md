# Description

Codes for the manuscript **Autonomous Liquid-Cell Electron Tomography for 4D Nanoparticle Reaction Kinetics**.  
DOI: \[Pending]  
Authors: Zhiheng Lyu, Lehan Yao, Carlos L. Bassan, Xingzhi Wang, Junseo Lee, Shengsong Yang, Binyu Wu, Falon C. Kalutantirige, Sohini Mandal, John R. Crockett, Seoeun Seol, Jiwoong Park, Maria K. Chan, Gregory S. Girolami, Robert F. Klie, A. Paul Alivisatos, Michael Engel, Qian Chen

# Contents

The following folders contain examples of data analysis codes used in the paper, corresponding to the subsections of the Supplementary Note in the Supporting Information:

* **2 error estimation example**: Codes for estimating 3D reconstruction errors when the shape transforms during tilt-series acquisition.
* **6.1 3D U-Net segmentation example**: Codes to perform 3D U-Net segmentation of two elements in the 3D reconstruction.
* **6.2 U-Net for contrast correction example**: Codes to use U-Net to correct contrast inversion in STEM projections of thick nanoparticle samples.
* **6.4 local etching rate example**: Codes to measure the local etching rate on the surface from a 3D reconstruction series.
* **6.5 shape signature example**: Codes to measure the shape signature ( d(theta, phi) ) for directional etching rates from a 3D reconstruction series.
* **6.6 moment invariant example**: Codes to measure moment invariants from 3D reconstructions.
* **6.7 \& 6.8 Cu₃As \& chiral Au nanoparticles**: Codes for the analysis of Cu₃As \& chiral Au nanoparticles.
* **6.9 facet analysis example**: Codes to assign low-index lattice facets to the surface of a 3D reconstruction.



The folders below contain codes for fast electron tomography:

* **AutoLCET data collection**: A Python application with a GUI for rapid electron tomography tilt-series acquisition.
* **tilt-series extraction example**: Codes to extract useful frames (projections) collected in the previous step to generate tilt series.
* **alignment and reconstruction example**: Codes to align projections in the tilt series and perform 3D reconstruction via MBIR.

For usage of the codes, please refer to the README files in each individual folder.

