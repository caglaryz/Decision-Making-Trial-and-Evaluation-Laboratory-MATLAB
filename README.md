# DEMATEL & Fuzzy-DEMATEL Risk Analysis Toolkit

This repository provides a MATLAB implementation of both **crisp** and **fuzzy** DEMATEL methods to transform expert-judged influence matrices into causal maps, prominence/relation scores, and driver-knockout leverage analyses. It follows:

- **Crisp DEMATEL** (Fontela & Gabus, 1973; see Falatoonitoosi _et al._ 2013 for a worked example)  
- **Fuzzy DEMATEL** (Lin & Wu, 2008) with CFCS defuzzification (Chen & Hwang, 1992)

---

## Repository structure

    .
    ├── data/
    │   ├── your_matrix.csv                       # row×column codes + linguistic labels (NO, VL, L, H, VH)
    │   └── your_names.csv                        # mapping from code → full description
    │
    ├── src/
    │   ├── main.m                                # orchestrates import, DEMATEL runs, all plots & tables
    │   ├── dematel_crisp.m                       # implements crisp DEMATEL
    │   ├── dematel_fuzzy.m                       # implements fuzzy DEMATEL (Lin & Wu 2008 + CFCS)
    │   ├── driver_knockout.m                     # computes % drop in total P when removing each driver
    │   ├── load_direct_matrix.m                  # reads & converts the CSV-encoded linguistic matrix
    │   └── plot/
    │       ├── plot_causal_map_v1_callout.m      # P vs C scatter with pop-out labels
    │       ├── plot_causal_map_full.m            # full DEMATEL: curved, alpha-scaled arrows + weights
    │       └── plot_causal_map_cmb.m             # combined crisp vs fuzzy with dual callouts & legend
    │
    └── output/                                   # all CSV tables and PNG plots are written here

---

## Getting started

1. **Prepare your data CSVs**  
   - In `data/`, create a file (e.g. `your_matrix.csv`) whose first column is the factor code (e.g. `F1`, `F2`, …) and whose subsequent cells contain one of the five linguistic labels:  
     ```
     Code, NO,  VL,   L,    H,   VH,  …
     F1,   NO,  L,    H,    VL,  NO,  …
     F2,   L,   H,    L,    NO,  VL,  …
     …
     ```
   - (Optional) In `data/`, create a names file (e.g. `your_names.csv`) with two columns, `Code` and `Description`, to give human-readable factor names.  

2. **Open `main.m`** and set the `dataDir` variable to point to your `data/` folder.  

3. **Run `main`** in MATLAB. It will:  
   - Load and convert your linguistic matrix to numeric (0…4).  
   - Run **crisp DEMATEL** → output:  
     - `output/crisp_total_relation.csv` (the T matrix)  
     - `output/crisp_results.csv` (P, C, Cause/Effect)  
     - `output/crisp_causal_map.png` (P vs C scatter w/ callouts)  
     - `output/crisp_full_map.png` (curved arrows + weight labels)  
   - Run **fuzzy DEMATEL** → output:  
     - `output/fuzzy_total_relation.csv`  
     - `output/fuzzy_results.csv`  
     - `output/fuzzy_causal_map.png`  
     - `output/fuzzy_full_map.png`  
   - Run **combined crisp vs fuzzy** → `combined_causal_map.png` and `combined_shifted_causal_map.png`  
   - Compute **driver-knockout leverage** and generate `driver_leverage_grouped.png` and `driver_leverage_delta.png`  
   - Produce a **heatmap** of fuzzy leverage drop → `leverage_heatmap.png`  

4. **Inspect the `output/` folder** for all CSV tables and high-resolution PNG figures.

---

## Key algorithms

### 1. Crisp DEMATEL
1. **Normalize** the direct-influence matrix by its maximum row sum.  
2. **Compute** the total-relation matrix  
   \[
     T = D \,(I - D)^{-1}
   \]
3. **Prominence**: \(P_i = \sum_j T_{ij} + \sum_j T_{ji}\)  
4. **Relation**:  \(C_i = \sum_j T_{ij} - \sum_j T_{ji}\)  
5. **Cause/Effect**: sign of \(C_i\) (positive → Cause, negative → Effect)

### 2. Fuzzy DEMATEL
1. **Map** each linguistic code to a triangular fuzzy number (TFN) via Lin & Wu (2008).  
2. **Normalize** the upper slice by its max row sum.  
3. **Compute** three total-relation slices \(T_{\text{low}},T_{\text{mid}},T_{\text{up}}\).  
4. **Defuzzify** via CFCS (global min/max) to a crisp \(T\).  
5. **Compute** \(P\), \(C\), and Cause/Effect as above.

### 3. Driver knockout
For each **cause** factor \(k\):  
1. Set row \(k\) to zero in the original matrix.  
2. Re-run DEMATEL, measure the **percent drop** in \(\sum_i P_i\).  
3. Higher % → more critical driver.

---

## Alternative analyses

- **Grouped bar chart** of crisp vs fuzzy leverage drops per driver  
- **Scatter plot** of \(\Delta_i = dF_i - dC_i\) to highlight shifts under fuzzification  
- **Top-N table** of the most critical drivers with their % drops

_Code snippets for these are included at the end of `main.m`._

---

## Customizing & Extensions

- **Plot styles** are in the `plot_*.m` files—swap colormaps, marker shapes, or callout thresholds to fit your taste.  
- **Thresholding**: adjust the percentile cutoff for showing weight labels or arrow transparency in the full map.  
- **New data**: add your own `*_linguistic.csv` + optional `_names.csv` and point `main.m` to them.  
- **Further metrics**: try cumulative leverage curves or sensitivity analyses by modifying `driver_knockout.m`.

---

## References

1. Fontela, E., & Gabus, A. (1973). _The DEMATEL Observer_. Battelle Geneva Research Center.  
2. Lin, T.-Y., & Wu, B.-W. (2008). _Fuzzy DEMATEL approach for complex systems_. Expert Systems with Applications.  
3. Falatoonitoosi, E., Leman, Z., Sorooshian, S., & Salimi, M. (2013). _DEMATEL method in risk assessment_.  
4. Chen, S.-J., & Hwang, C.-L. (1992). _Fuzzy Multiple Attribute Decision Making: Methods and Applications_. Springer.
