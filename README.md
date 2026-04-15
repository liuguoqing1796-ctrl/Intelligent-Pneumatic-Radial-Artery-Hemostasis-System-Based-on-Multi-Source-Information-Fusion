# Radial Artery Compression Hemostasis System

A MATLAB/Simulink model for simulating a radial artery compression hemostasis process with pneumatic actuation, tissue interaction, multimodal sensing, feature extraction, and state estimation.

## Files
- `radial_compression.slx` — main Simulink model
- `init_params.m` — parameter initialization script
- `make_protocolB.m` — optional pressure-protocol generator for the **From Workspace** input version

## Input mode
**Current default model input is provided by Signal Editor.**  
`make_protocolB.m` is **optional** and is only used for the **From Workspace** version of the pressure command input.

## How to run
1. Open MATLAB and set the current folder to this project folder.
2. Run:
   ```matlab
   init_params
   ```
3. Open `radial_compression.slx`.
4. Check or edit the input pressure profile in **Signal Editor**.
5. Run the simulation.

## Main model blocks
- **Input** — pressure command input
- **AdaptiveTrim** — adaptive command adjustment
- **Pneumatic** — cuff pressure dynamics
- **Tissue** — tissue mechanical response
- **Vessel** — vessel/perfusion mapping
- **Sensors** — simulated multimodal sensing
- **Processing** — feature extraction
- **State** — state probability estimation

## Typical outputs
The model records signals such as:
- cuff pressure command and actual pressure
- PPG-related signals
- impedance-related signals
- EDA/SCL-related signals
- state probabilities (`Risk`, `Optimal`, `Pain`)

## Notes
- The model was organized for simulation and figure generation.
- Some `To Workspace` blocks are kept for exporting signals and post-processing.
- If you want to switch from **Signal Editor** to **From Workspace**, configure the `Input` block accordingly, then use `make_protocolB.m` to generate `Pcmd_ts`.

## License
Add your preferred license before publishing the repository.
