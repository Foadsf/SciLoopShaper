# SciLoopShaper - A Scilab Loop Shaping Tool

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
_(Add other badges later, e.g., build status, version)_

**SciLoopShaper** is an open-source (FLOSS) SISO (Single-Input Single-Output) loop-shaping tool developed entirely in Scilab. It aims to provide functionality similar to the original MATLAB-based Shapeit tool developed at TU/e, allowing users to design and analyze control systems in the frequency and time domains.

## Motivation

The goal of this project is to:

1.  Provide a modern, open-source alternative to Shapeit accessible to users of the Scilab ecosystem.
2.  Offer a platform for learning and experimenting with control system design techniques (loop shaping, frequency domain analysis, time domain simulation) within Scilab.
3.  Develop a well-structured and maintainable Scilab application.

## Current Status (Early Development - Basic GUI Functional)

**Warning:** This project is still in the early stages of development.

*   **Core Functions:** Backend functionalities for plant/controller definition, combination, analysis (margins, bandwidth), time simulation, discretization (Tustin), and frequency plotting (Bode, Nyquist, Nichols) are implemented and tested via scripts. Specific workarounds for Scilab 2024.0.0 issues (`length`, `syslin`, `dscr`) are included.
*   **GUI:** A basic Graphical User Interface is now implemented and functional for core tasks:
    *   The main window layout with distinct panels (Plant, Controller, Performance, Frequency Response, Time Response) is established.
    *   The "Plant" panel allows selecting built-in examples via a dropdown menu.
    *   Selecting a plant example triggers backend calculations and updates the Frequency Response panel to display the corresponding Bode plot.
    *   Frequency range parameters can be edited, triggering plot updates.
    *   Other panels (Controller, Performance, Time Response controls, FRF selections) are currently placeholders.
*   **Testing:** Core logic is validated via scripts (`examples/`). Basic GUI interaction (plant selection -> plot update) is manually tested.

## Features (Implemented Core / Partially Implemented GUI)

*   **Plant Definition:**
    *   Load from Scilab workspace (`syslin` objects) - *Core Implemented*
    *   Use built-in examples (Mass, 2-Mass systems) - **GUI Functional**
    *   Load from file (Planned)
    *   Load Frequency Response Data (FRD) (Planned)
    *   Edit Frequency Range - **GUI Functional**
*   **Controller Design:**
    *   Add/Remove standard controller blocks - *Core Implemented*
    *   Define multiple controllers - *Core partially implemented*
    *   Tune parameters of controller blocks (Planned GUI)
    *   Cascade blocks - *Core Implemented*
    *   Save/Load controller designs (Planned)
*   **Analysis & Visualization:**
    *   Frequency Domain Plots: Bode, Nyquist, Nichols - *Core Plotting Implemented*
    *   Display various transfer functions (P, C, PC, etc.) - *Core Calculation Implemented, GUI display TBD*
    *   Time Domain Simulation - *Core Calculation Implemented*
    *   Stability Margins - *Core Calculation Implemented*
    *   Bandwidth Calculation - *Core Calculation Implemented*
    *   Plotting within GUI: **Partially Implemented (Bode Plot)**
*   **Discretization:**
    *   Discretize controller (Tustin via numeric code) - *Core Implemented*
    *   Discretize plant (ZOH planned) - *Core function exists, needs integration*
    *   Visualize discrete-time responses (Planned)
*   **Xcos Integration:**
    *   Export controller design to Xcos (Planned)

## Screenshots

_(Add screenshot of the current GUI showing the layout and a Bode plot)_

## Requirements

*   **Scilab:** Version **2024.0.0** was used during initial development and debugging.
    *   **Important:** This version exhibits specific behaviors/bugs regarding `length()` on string arrays, `syslin()` constants, `dscr()` method strings, `ishandle` in callbacks, and `plot2d`/`xtitle` interactions. Specific workarounds are implemented. See [LESSONS_LEARNED.md](LESSONS_LEARNED.md) for details. Functionality on other Scilab versions is not guaranteed and may require code changes.
*   **Operating System:** Developed and tested primarily on Windows 10/11. Should be largely platform-independent, but testing on Linux/macOS is needed.

## Installation & Usage

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Foadsf/SciLoopShaper.git
    cd SciLoopShaper
    ```
2.  **Launch Scilab:** Start the Scilab console (`scilex` or `WScilex-cli.exe`) **interactively** (do not use `-quit` if you want to see the GUI).
3.  **Set Working Directory:** Navigate Scilab's current directory to the `SciLoopShaper` root folder (e.g., using `cd C:\path\to\SciLoopShaper`).
4.  **Load Functions:** Execute the main loading script:
    ```scilab
    --> exec('main.sce');
    ```
    *(Wait for "SciLoopShaper functions loaded successfully." message).*
5.  **Launch GUI:** Call the GUI function from the console:
    ```scilab
    --> main_gui();
    ```
    *(The SciLoopShaper window should appear).*
6.  **Interact:** Select an example plant from the dropdown menu to see its Bode plot. Edit frequency ranges and press Enter to update the plot.

## Project Structure

```
SciLoopShaper/
├── main.sce             # Main script to load functions
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
*   Test on different Scilab versions or operating systems.

Please adhere to standard coding practices and ensure tests pass (once formal tests are added).

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

*   This project is inspired by the original Shapeit tool developed by the Control Systems Technology group at Eindhoven University of Technology (TU/e).
*   Includes examples adapted from Scilab documentation and community resources.
