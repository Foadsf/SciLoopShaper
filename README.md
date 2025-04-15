# SciLoopShaper - A Scilab Loop Shaping Tool

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
_(Add other badges later, e.g., build status, version)_

**SciLoopShaper** is an open-source (FLOSS) SISO (Single-Input Single-Output) loop-shaping tool developed entirely in Scilab. It aims to provide functionality similar to the original MATLAB-based Shapeit tool developed at TU/e, allowing users to design and analyze control systems in the frequency and time domains.

## Motivation

The goal of this project is to:

1.  Provide a modern, open-source alternative to Shapeit accessible to users of the Scilab ecosystem.
2.  Offer a platform for learning and experimenting with control system design techniques (loop shaping, frequency domain analysis, time domain simulation) within Scilab.
3.  Develop a well-structured and maintainable Scilab application.

## Current Status (Very Early Development)

**Warning:** This project is in the very early stages of development.

*   **Core Functions:** Basic functionalities for defining plants (examples, workspace), creating controller blocks (Gain, Integrator, Lead/Lag, Filters, PD, etc.), calculating combined controllers, and performing basic frequency/time domain analysis (Bode, Nyquist, Nichols, step response, stability margins) have been implemented and partially tested via scripts. Core discretization functions (`dscr` using Tustin) are working via identified workarounds for the target Scilab version.
*   **GUI:** The Graphical User Interface is **NOT YET IMPLEMENTED**. The main GUI window is created, but panels, controls, and plotting areas are placeholders.
*   **Testing:** Core logic has been tested through command-line scripts (`examples/` directory). GUI interaction and end-to-end workflows are untested.

## Features (Implemented Core / Planned GUI)

*   **Plant Definition:**
    *   Load from Scilab workspace (`syslin` objects) - *Core Implemented*
    *   Use built-in examples (Mass, 2-Mass systems) - *Core Implemented*
    *   Load from file (Planned)
    *   Load Frequency Response Data (FRD) (Planned)
*   **Controller Design:**
    *   Add/Remove standard controller blocks (Gain, Integrator, Lead/Lag, Lowpass 1st/2nd, Notch, PD) - *Core Implemented*
    *   Define multiple controllers (up to 3 planned) - *Core partially implemented*
    *   Tune parameters of controller blocks (Planned GUI)
    *   Cascade blocks to form the overall controller - *Core Implemented*
    *   Save/Load controller designs (Planned)
*   **Analysis & Visualization:**
    *   Frequency Domain Plots: Bode, Nyquist, Nichols - *Core Plotting Implemented*
    *   Display various transfer functions (P, C, PC, Sensitivity, Closed Loop) - *Core Calculation Implemented*
    *   Time Domain Simulation (Step, Sine, etc.) - *Core Calculation Implemented*
    *   Stability Margins (Gain, Phase, Modulus) - *Core Calculation Implemented*
    *   Bandwidth Calculation - *Core Calculation Implemented*
    *   Plotting within an interactive GUI (Planned GUI)
*   **Discretization:**
    *   Discretize controller (Tustin via numeric code) - *Core Implemented*
    *   Discretize plant (ZOH planned) - *Core function exists, needs integration*
    *   Visualize discrete-time responses (Planned)
*   **Xcos Integration:**
    *   Export controller design to Xcos (Planned)

## Screenshots

_(Screenshots will be added once the GUI is functional)_

## Requirements

*   **Scilab:** Version **2024.0.0** was used during initial development.
    *   **Important:** This version exhibits non-standard behavior for `length()` on string arrays and requires numeric codes for `dscr` methods. See [LESSONS_LEARNED.md](LESSONS_LEARNED.md) for details. Functionality on other Scilab versions is not guaranteed.
*   **Operating System:** Developed and tested primarily on Windows 10/11. Should be largely platform-independent, but testing on Linux/macOS is needed.

## Installation & Usage

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/SciLoopShaper.git
    cd SciLoopShaper
    ```
2.  **Launch Scilab:** Start the Scilab console (`scilex` or `WScilex-cli.exe`) from the `SciLoopShaper` root directory.
3.  **Run the main script:**
    ```scilab
    --> exec('main.sce');
    ```
    This will load all necessary functions.
4.  **Run Tests (Recommended):** Execute scripts in the `examples/` subdirectories to test core functionalities:
    ```scilab
    --> exec('examples/plants/test_plant_functions.sce');
    --> exec('examples/controllers/test_controller_functions.sce');
    --> exec('examples/analysis/test_analysis_functions.sce');
    --> exec('examples/plotting/test_plotting_functions.sce');
    ```
5.  **(Future)** Launch the GUI (once implemented):
    ```scilab
    --> main_gui();
    ```

## Project Structure

```
SciLoopShaper/
├── main.sce             # Main script to load functions (and eventually launch GUI)
├── LICENSE              # GPL License file
├── README.md            # This file
├── LESSONS_LEARNED.md   # Notes on Scilab vs MATLAB issues encountered
├── src/                 # Source code
│   ├── core/            # Core control algorithms, calculations
│   ├── gui/             # GUI elements, layout, callbacks
│   ├── io/              # Input/Output (Save/Load - Planned)
│   ├── plotting/        # Plotting functions
│   ├── utils/           # Utility functions (Planned)
│   └── xcos_interface/  # Xcos integration (Planned)
├── examples/            # Test scripts and example data
│   ├── analysis/
│   ├── controllers/
│   ├── plants/
│   └── plotting/
├── assets/              # Logos, icons (Planned)
└── tests/               # Formal unit/integration tests (Planned)

```

## Contributing

Contributions are welcome! Please feel free to:

*   Report bugs or suggest features by opening an issue.
*   Submit pull requests with bug fixes or new features.
*   Improve documentation.

Please adhere to standard coding practices and ensure tests pass (once formal tests are added).

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

*   This project is inspired by the original Shapeit tool developed by the Control Systems Technology group at Eindhoven University of Technology (TU/e).
