# Common Neighbor Analysis Automation Scripts

This repository contains Bash scripts designed to automate atomic simulations, specifically focusing on **Common Neighbor Analysis (CNA)** in liquids.

## Overview

The scripts allow you to:

- Run simulations at **multiple temperatures** automatically.
- Perform multiple runs at the **same temperature but different time intervals** to improve statistical accuracy.
- Generate outputs ready for post-processing and analysis.
- Easily **adapt scripts** for other types of atomic or structural analysis.

These tools are especially useful for researchers working on liquids or disordered systems, where statistical sampling is critical.

## Features

✅ Automated temperature  
✅ Multiple time-based runs for statistical accuracy  
✅ Suitable for use with tools like LAMMPS, VASP, OVITO, or custom post-processing scripts

## Requirements

- Unix-based system (Linux/macOS)
- Bash shell
- Molecular dynamics software (e.g., **LAMMPS**,**VASP**)  
- Post-processing tools for CNA (e.g., **OVITO**, custom scripts)

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/alfahs/MolecularDynamicsScripts.git
   cd MolecularDynamicsScripts
