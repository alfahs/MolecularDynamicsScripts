# Contributing to CNA Automation Scripts

Thank you for your interest in contributing to this project!  
This repository provides Bash scripts to automate Common Neighbor Analysis (CNA) for atomic simulations in liquids.

We welcome all types of contributions, including but not limited to:

---

## 🔧 1. Add AI-Based Code Commenting

Improve the readability and usability of the scripts by:

- Adding meaningful comments to complex Bash code using clear, human-readable explanations.
- Using AI-assisted tools (like GitHub Copilot or ChatGPT) to help generate or improve comments.
- Refactoring parts of the script to make logic easier to follow.

---

## 🧩 2. Make the Scripts More User-Friendly

Help improve the user experience by:

- Turning command-line scripts into interactive prompts or menu-driven interfaces.
- Adding config files (e.g., `config.yaml` or `.ini`) to avoid hardcoding variables.
- Creating GUI wrappers using Python (Tkinter, PyQt) or web-based interfaces.

---

## 🔌 3. Integrate with Simulation or Analysis Software

Extend the functionality by integrating these scripts with other tools, such as:

- **LAMMPS** – run simulations and analyze trajectory outputs directly.
- **OVITO** – export CNA data in OVITO-readable formats or use its Python scripting API.
- **GROMACS**, **VMD**, etc. – support for other simulation ecosystems.
- Job schedulers (e.g., **SLURM**, **PBS**) for running on HPC systems.


## 📌 How to Contribute

1. **Fork the repository**
2. **Create a new branch** for your feature or fix:
   ```bash
   git checkout -b feature-name

    Make your changes, commit them, and push to your fork:

git commit -m "Add useful feature"
git push origin feature-name

Open a Pull Request with a clear explanation of what you changed and why.
