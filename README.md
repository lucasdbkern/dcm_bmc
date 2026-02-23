# Bayesian Structure Learning: Comparing BMC and PEB+BMR for DCM

MATLAB codebase accompanying the paper:

> **Bayesian Structure Learning: Comparing Bayesian Model Comparison and Bayesian Model Reduction**  
> Lucas Kern, Peter Zeidman, Karl Friston, Johan Medrano — UCL Queen Square Institute of Neurology

This repository provides scripts for simulating synthetic EEG subjects, running Bayesian Model Comparison (BMC) and Parametric Empirical Bayes with Bayesian Model Reduction (PEB+BMR) on Dynamic Causal Models (DCMs), and reproducing all figures in the paper.

---

## Prerequisites

- MATLAB (tested on R2022b+)
- [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)

Ensure SPM12 is on your MATLAB path before running any scripts. You can use `scripts/04_utils/addpaths.m` to add the relevant subject data directories.

---

## Models

Three candidate DCM architectures are compared, all based on a 5-region auditory hierarchy (lA1, rA1, lSTG, rSTG, rIFG) fit to OPMEG mismatch negativity (MMN) data:

- **Model 1 (Full)** — full modulatory connectivity
- **Model 2 (ORA)** — rIFG↔rSTG modulatory connections removed
- **Model 3 (TRA)** — all modulatory connections removed except lA1 and rA1 self-connections

---

## Repository Structure

```
scripts/
  01_pipeline/        # Entry-point scripts that generate data and run inversion
  02_analysis/        # Analysis scripts that process results
  03_visualization/   # Plotting scripts that produce the paper figures
  04_utils/           # Helper functions (path setup, GCM builders)

connectivity_matrices/ # FullA1.mat, ORA1.mat, TRA1.mat etc.
subject_folder/        # Per-subject DCM files (subject_1/ ... subject_20/)
results/               # Saved .mat outputs from pipeline runs
Archive/               # Deprecated scripts, no longer in use
```

---

## Reproducing the Paper Figures

### Figure 3 — Confusion Matrices (BMC and PEB+BMR)

**Pipeline 1: BMC**

1. `scripts/01_pipeline/generate_subjects_and_run_bmc.m` — Simulates 20 subjects (adding noise to parameters, timeseries, and input) and runs subject-level BMC, saving `DCMij.mat` per subject.
2. `scripts/03_visualization/plot_bmc_confusion_matrix.m` → **Figure 3 left panel** (BMC posterior probability heatmap)

**Pipeline 2: PEB+BMR**

1. `scripts/04_utils/build_gcm.m` — Assembles `GCM.mat` and `GCM_for_PEB.mat` from per-subject DCM files.
2. `scripts/01_pipeline/run_peb_bmr.m('Full')`, `run_peb_bmr('ORA')`, `run_peb_bmr('TRA')` — Runs PEB followed by BMR for each model type, saving `peb_bmr_results_<type>.mat`.
3. `scripts/03_visualization/plot_peb_heatmap.m` → **Figure 3 right panel** (PEB+BMR posterior probability heatmap)

Both pipelines share the same simulated subjects from step 1 of Pipeline 1.

**Figure 3C — Accuracy across SNR (hE 2–6)**

Run Pipeline 1 and Pipeline 2 at each hE value (2–6), saving `averagePost_bmc_B_hE<N>.mat` and `averagePost_pebbmr_B_hE<N>.mat`, then:

- `scripts/02_analysis/compare_free_energies_across_hE.m` → **Figure 3C left** (accuracy curves)

---

### Figure 4 — Modulatory Connection Pruning

- `scripts/03_visualization/compare_posteriors.m` → **Figure 4** — loads PEB+BMR and BMC posteriors and plots group-level posterior means with 95% confidence intervals for modulatory parameters.

---

### Figure 5 — Progressive Pruning

**Figure 5B — BMR failure case**

1. `scripts/01_pipeline/prune_connections_vary_strength.m(1)` — Progressively scales down prior variance of the rSTG↔rIFG connections (hE=6, strengths 0–4 in steps of 0.1) across 20 subjects via full VL re-inversion. Saves `DCMs_multi_subject_final_fine_pruning_bmr_fail.mat`.
2. `scripts/02_analysis/compare_f_full_reduced.m` → **Figure 5B** — computes BMR quadratic approximation via `spm_log_evidence_reduce` and VL free energy differences, plots group mean with shaded 95% confidence intervals.

**Figure 5C — BMC failure case**

1. `scripts/01_pipeline/prune_connections_across_subjects.m` — Progressively scales down prior variance of bilateral A1↔STG connections (ORA model, hE=6, multipliers exp(0), exp(−8), exp(−16)) across 20 subjects. Saves `dcm_hE4_connection_sensitivity_ORA_reset_2.mat`.
2. `scripts/02_analysis/compare_f_full_reduced.m` (pointed at the BMC failure data file) → **Figure 5C**

---

## Utility Scripts

- `scripts/04_utils/addpaths.m` — Adds subject data directories to MATLAB path
- `scripts/04_utils/build_gcm.m` — Builds `GCM.mat` (diagonal entries of DCMij, used for PEB)
- `scripts/04_utils/build_gcm_from_subject_files.m` — Alternative GCM builder loading directly from subject model files

---

## Archive

The `Archive/` folder contains deprecated scripts that are no longer part of the active pipeline. These are retained for reference only and should not be used to reproduce results. Notable examples include `compare_bmc_bmr_one_subject.m` (single-subject prototype) and `peb2.m` (early PEB iteration).

---

## Notes on Naming Conventions

- **Full / ORA / TRA** refer to Model 1, 2, and 3 respectively. ORA = "Once Removed A-matrix connections" (rIFG↔rSTG removed). TRA = "Twice Removed A-matrix connections" (all modulatory connections except lA1/rA1 self-connections removed).
- `hE` controls the log-precision of measurement noise and serves as a proxy for SNR. Higher hE = higher SNR. The default used in the paper is hE=6.
- `DCMij{i,j}` denotes Model i fitted to the timeseries generated by Model j.