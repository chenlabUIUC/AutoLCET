# AutoLCET — Data Collection

Fast tomography control for FEI/ThermoFisher electron microscopy with a real-time
particle-tracking GUI. Corresponds to the **AutoLCET data collection** component of
the manuscript *"Autonomous Liquid-Cell Electron Tomography for 4D Nanoparticle
Reaction Kinetics."*

![Version](https://img.shields.io/badge/version-0.0.7-blue)
![Python](https://img.shields.io/badge/python-3.8+-green)

## Overview
AutoLCET enables automated tilt-series acquisition with real-time particle tracking
for electron tomography. The application captures the microscope display (via screen
capture or capture card) and uses computer vision to track particles, automatically
correcting stage position during tilting.

## Features
- **Dual Capture Modes**: Screen capture (MSS) or capture card input
- **Real-time Particle Tracking**:
  - Classical method (thresholding + contour detection)
  - ML method (YOLO-based object detection)
- **Automated Stage Control**: Position correction during tilt series
- **Live Visualization**: Original, blurred, binary, and overlay views
- **Configurable Parameters**: All settings saved automatically to `configure.json`

---

## 1. System requirements

### Software dependencies (tested versions)
Core (required to launch the GUI):
- Python <3.9.25>
- numpy <2.0.2>
- opencv-python <4.12.0>
- matplotlib <3.9.2>
- mss <10.1.0>
- tkinter (bundled with standard CPython installations)

Optional:
- temscript <2.0> — required **only** for live microscope control (FEI/ThermoFisher)
- ultralytics <8.x> — required **only** for YOLO-based ML tracking (pulls in PyTorch)

> The application is designed to run **without** `temscript` and `ultralytics`:
> if they are absent, microscope control falls back to a **simulation mode** and
> classical tracking remains fully functional. This allows reviewers to test the GUI
> on any computer without a microscope.

### Operating systems tested
- Windows <10/11> (recommended — capture-card support uses the DirectShow backend,
  `cv2.CAP_DSHOW`)
- <optionally: macOS / Linux for the screen-capture (MSS) + classical tracking path>

### Hardware
- A normal desktop is sufficient to run and test the GUI.
- **For live acquisition:** an FEI/ThermoFisher microscope reachable over the network
  (running the `temscript` server), and optionally an HDMI/video **capture card** for
  capture-card mode.
- **For ML tracking:** a CUDA-capable NVIDIA GPU is recommended for real-time YOLO
  inference (CPU works but at lower FPS).

---

## 2. Installation guide

```bash
# core (minimum to launch the GUI)
pip install numpy opencv-python matplotlib mss

# optional add-ons
pip install temscript        # only if connecting to a microscope
pip install ultralytics      # only if using ML (YOLO) tracking
```

**Typical install time:** ~2–3 minutes for the core dependencies on a normal desktop.
Installing `ultralytics` (with PyTorch/CUDA) adds ~5–10 minutes depending on
connection and platform.

---

## 3. Demo

Because live acquisition requires a microscope, the demo below runs the GUI in
**simulation mode** so it can be tested on any computer.

### Provided files
```
AutoLCET data collection/
├── fastTomo.py          # main GUI application
├── yolov8_NP.pt         # YOLO model trained to track nanoparticles
├── yolov8_cell.pt       # YOLO model trained to track cells (HAADF-STEM mode)
└── configure.json       # auto-generated on first run (stores settings)
```

### Instructions
1. Launch the application:
   ```bash
   python fastTomo.py
   ```
2. **Provide an image source** for tracking:
   - **Screen capture (MSS):** open any nanoparticle/cell image on your screen and
     set the X, Y, W, H sliders to enclose it; **or**
   - **Capture card:** select a device and click **Start**.
3. Keep **"Enable Microscopy Control" off** (or click **Connect** without a
   microscope — the app enters *Simulated* connection mode). Stage moves are logged
   but not sent to hardware.
4. Try both tracking methods:
   - **Classical**: adjust Blur / Thresh / Invert Contrast; the detected particle is
     outlined in the Overlay panel.
   - **ML (YOLO)**: click **Browse**, select `yolov8_NP.pt` (or `yolov8_cell.pt`),
     click **Load**; detections appear as bounding boxes.

### Expected output
- A live GUI window with four panels (Original, Blurred, Binary, Overlay) updating in
  real time, an FPS readout, and the tracked object's centroid coordinates.
- `configure.json` written/updated in the working directory (all UI settings).
- When a tilt series is started (`Tilt Start/Stop`), a timestamped log
  `logs/<YYYY-MM-DD_HH-MM-SS>.csv` recording elapsed time and tilt angle for each step.

### Expected run time
- The GUI launches in a few seconds and runs continuously (real-time loop, target
  update every ~10 ms). Classical tracking typically runs at tens of FPS on a normal
  desktop; YOLO FPS depends on GPU/CPU. There is no fixed "finish" time — close the
  window to exit.

---

## 4. Instructions for use (live acquisition)

### Quick start
1. **Launch**: `python fastTomo.py`
2. **Configure capture source**:
   - **Screenshot (MSS)**: capture a region of your screen (set X, Y, W, H).
   - **Capture Card**: select device + resolution, click **Start**, then crop with
     X, Y, W, H.
3. **Adjust tracking parameters** (Blur, Threshold, Area LB/UB) and choose Classical
   or ML tracking.
4. **Connect to microscope**: enable "Microscopy Control", enter IP/Port, click
   **Connect** (requires the `temscript` server running on the microscope PC).
5. **Start tilt series**: **Register Starting Pose** → set tilt angles/interval →
   **Tilt Start/Stop**.

### Configuration parameters
| Parameter | Description |
|-----------|-------------|
| FOV (nm) | Field of view in nanometers |
| Tilt angle start/end | Tilt range in degrees |
| Tilt interval | Step size in degrees |
| Delay time | Wait time between tilts (seconds) |
| Trans threshold | Minimum displacement to trigger correction (pixels) |
| Multiplier | Stage movement scaling factor |

### Controls
| Control | Function |
|---------|----------|
| Enable Microscopy Control | Activates microscope communication |
| Connect | Establishes connection to microscope |
| Track On/Off | Enables/disables position correction |
| Register Starting Pose | Saves current stage position |
| Go to Starting Pose | Returns to saved position |
| Tilt Start/Stop | Begins/ends automated tilt series |

### Tracking methods
- **Classical**: Gaussian blur → thresholding → contour detection. Fast; good for
  high-contrast particles. Parameters: Blur, Threshold, Invert Contrast.
- **ML (YOLO)**: requires a trained `.pt` model; runs inference in a separate thread.
  Better for complex scenes or low-contrast particles. `yolov8_NP.pt` (nanoparticles)
  and `yolov8_cell.pt` (cells in HAADF-STEM mode) are provided.

### How it works
1. **Image acquisition** — captures microscope display via screen grab or capture card.
2. **Particle detection** — classical CV or YOLO.
3. **Centroid tracking** — computes particle position relative to image center.
4. **Stage correction** — sends corrections to keep the particle centered during tilt.

This screen/capture-card approach is faster than polling camera APIs directly,
enabling real-time tracking during tomography acquisition.

### File output
- `configure.json` — automatically saved settings.
- `logs/` — tilt-series logs with timestamps and angles.

---

## Troubleshooting
**Capture card**: try different resolutions; click **Refresh** to rescan; ensure no
other app is using the device.
**Connection failed**: verify IP/port; check network; ensure the `temscript` server
is running on the microscope PC.
**Tracking**: tune Blur/Threshold (classical); keep the particle within Area LB/UB;
try Invert Contrast if the particle is brighter than background.

## Author
**Lance Yao** — Pacific Northwest National Laboratory — 📧 lance.yao@pnnl.gov
