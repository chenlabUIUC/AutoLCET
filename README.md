# Description

Codes for the manuscript **Autonomous 4D Videotomography of Nanoparticle Reactions**.  
DOI: TBD  
Authors: TBD

# Contents

The following folders contain examples of data analysis codes used in the paper, corresponding to the subsections of the Supplementary Note in the Supporting Information:

- **6.1 3D U-Net segmentation example**: Codes to perform 3D U-Net segmentation of two elements in the 3D reconstruction.
- **6.2 U-Net for contrast correction example**: Codes to use U-Net to correct contrast inversion in STEM projections of thick nanoparticle samples.
- **6.4 Local etching rate example**: Codes to measure the local etching rate on the surface from a 3D reconstruction series.
- **6.5 Shape signature example**: Codes to measure the shape signature ( d(theta, phi) ) for directional etching rates from a 3D reconstruction series.
- **6.6 Moment invariant example**: Codes to measure moment invariants from 3D reconstructions.
- **6.7 & 6.8 Cu₃As & chiral Au nanoparticles**: Codes for the analysis of Cu₃As & chiral Au nanoparticles.
- **6.9 Facet analysis example**: Codes to assign low-index lattice facets to the surface of a 3D reconstruction.
- **X.X Error estimation example**: Codes for estimating 3D reconstruction errors when the shape transforms during tilt-series acquisition.

The folders below contain codes for fast electron tomography:

- **AutoLCET data collection**: A Python application with a GUI for rapid electron tomography tilt-series acquisition.
- **Tilt-series extraction example**: Codes to extract useful frames (projections) collected in the previous step to generate tilt series.
- **Alignment and reconstruction example**: Codes to align projections in the tilt series and perform 3D reconstruction via MBIR.

For usage of the codes, please refer to the README files in each individual folder.
