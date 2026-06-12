# Replication — Witheridge (2024), *Monetary Policy and Fiscal-led Inflation in Emerging Markets*

Partial replication of the **theoretical** results in Witheridge (2024). The code
reproduces the model-generated impulse-response functions (IRFs) and the welfare
exercises from the paper's theory section, using **Dynare** on **MATLAB**.

**Authors:** Theo Garcia · Ana Victoria Pelliccione
**Date:** August 2025

---

## Scope

This repository replicates a specific part of the paper: the **calibrated
log-linear New Keynesian small open economy** and its dynamics. Concretely:

- Impulse responses to a monetary policy shock under the **monetary-led** and
  **fiscal-led** regimes (Figures 5 and 6).
- Impulse responses to **productivity** and **markup** shocks (Figure 8).
- **Welfare** as a function of the monetary policy parameter `phi_pi`, under both
  regimes (Figure 9, panels a and b).

It does **not** cover the empirical panel estimation or the Bayesian estimation of
the quantitative model.

---

## Repository structure

| File | Reproduces | Regime | Shock(s) |
|------|------------|--------|----------|
| `irf_monetary_led.mod` | Figure 5 | monetary-led | monetary policy |
| `irf_fiscal_led.mod` | Figure 6 | fiscal-led | monetary policy |
| `welfare_base_fiscal_led.mod` | base for Fig. 9(a); run alone → Fig. 8 IRFs | fiscal-led | productivity + markup |
| `welfare_base_monetary_led.mod` | base for Fig. 9(b) | monetary-led | productivity + markup |
| `welfare_scan_fiscal_led.m` | Figure 9(a) | fiscal-led | scans `phi_pi` |
| `welfare_scan_monetary_led.m` | Figure 9(b) | monetary-led | scans `phi_pi` |

The two `welfare_scan_*.m` scripts read their corresponding `welfare_base_*.mod`
file, sweep `phi_pi` over a grid, run Dynare for each value, compute intertemporal
welfare from the `piH` and `ygap` IRFs, and produce the welfare-vs-`phi_pi` plots.

---

## Requirements

- **MATLAB** — _tested on version: TODO (fill in)_
- **Dynare** — _tested on version: TODO (fill in, e.g. 5.x / 6.x)_

Make sure Dynare is on the MATLAB path before running, e.g.:

```matlab
addpath('C:\dynare\<version>\matlab')   % adjust to your install
```

---

## How to run

Run everything **from the repository root**, so the scripts can find their
`base_mod` files.

### Impulse responses (Figures 5, 6, 8)

```matlab
dynare irf_monetary_led        % Figure 5
dynare irf_fiscal_led          % Figure 6
dynare welfare_base_fiscal_led % markup / productivity IRFs behind Figure 8
```

Each call produces Dynare's standard IRF figures for the reported variables.

### Welfare scans (Figure 9)

```matlab
welfare_scan_fiscal_led        % Figure 9(a)
welfare_scan_monetary_led      % Figure 9(b)
```

Each script:

1. writes temporary `.mod` files (one per `phi_pi`) into a results subfolder,
2. runs Dynare on each,
3. computes welfare under productivity and markup shocks,
4. saves everything to `ALL_phi_scan.mat`, and
5. exports two PNGs (`welfare_markup.png`, `welfare_productivity.png`).

Outputs are written to:

- `results_phi_scan_fiscal_led/`
- `results_phi_scan_monetary_led/`

These folders are generated artifacts and are not meant to be committed.

---

## Notes

- **Shock scale (`stderr`).** The model is linear, so the standard deviation of a
  shock is a pure vertical-scale factor: it changes the axis only, never the sign,
  shape, or timing of any response. The `stderr` values in the IRF files are chosen
  only to line up with the scale of the paper's figures and carry no economic
  content. Expect the *shapes* of the IRFs to match the paper while the absolute
  *scale* may differ — as also noted in the accompanying report.

- **Welfare comparability.** In the welfare scans, the structural shock size is
  held fixed across the whole `phi_pi` grid; that fixed size (not impact
  normalization) is what makes the welfare values comparable across runs.

- **Re-running the scans.** The scripts substitute `phi_pi` in the base model via a
  regular expression that expects a plain assignment line of the form
  `phi_pi = <number>;` (no trailing comment on that line). Keep that format if you
  edit the base `.mod` files.

---

## Original paper

The original article is **not** included in this repository for copyright reasons.
Please obtain it from the author's official source.

> Witheridge, W. (2024). *Monetary Policy and Fiscal-led Inflation in Emerging
> Markets.* Job Market Paper.

---

## License

_TODO:_ choose a license. A common choice for replication code is the
[MIT License](https://opensource.org/license/mit) for the code in this repository
(this does not cover the original paper, which belongs to its author).
