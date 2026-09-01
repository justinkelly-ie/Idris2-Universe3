# 🌌 Idris2-Universe3

**10D Substrate Metric, State Evolution & Reflection Auditor for Idris 2**

`Idris2-Universe3` is the core physical engine unifying all metric sectors:
- **Strict QTT Linearity**: State evolution enforcing linear multiplicity `(1 state : UniverseState vm de dm)`.
- **Discrete Helmholtz Free Energy Minimization**: Unique global ground state minimum $F = -1320$ at Primorial $210$.
- **163 Reflection Proof Auditors**: Compile-time macro reflection invariants (`%macro`).
- **Norman Wildberger Finitist Foundation**: Built on Wildberger's Box Arithmetic, Rational Trigonometry, Chromogeometry, and Dyck path combinatorics.

---

## 📐 Mathematical & Physical Foundations

### 1. Norman Wildberger's Box Arithmetic
Rather than relying on continuous real manifolds ($\mathbb{R}^n$) and uncountable infinities, state space is built constructivally from discrete integer multisets (**Pixel Boxes**):
$$\text{[]}=0, \quad \text{[[]]}=1, \quad \text{[[] []]}=2, \quad \text{[[] [] []]}=3, \dots$$
Geometric separation is computed strictly using rational **Quadrance** ($Q = \Delta x^2 + \Delta y^2$) and **Spread** ($S$), eliminating trigonometric approximations.

### 2. Canonical Dyck Contour Walks
Every nested `BoxSpec` multiset configuration maps bijectively to a canonical non-negative Dyck contour walk ($+1$ up-step for open brackets/descent into a sub-box, $-1$ down-step for close brackets/ascent out of a sub-box):
- **Serialization**: Encoded via `contourWalk` into prefix-free bitstrings and validated total via `isDyckPath`.
- **Narayana Refinement**: Narayana numbers $N(n, k)$ index Dyck paths by peak count $k$, partitioning state capacity across the 4 metric sectors:
  - **Elliptic** ($\det g = +1$, 27 Bound-State VM)
  - **Hyperbolic** ($\det g = -1$, 128 Gauge-Flux DE)
  - **Parabolic** ($\det g = 0$, 55 Dissipation DM)
  - **Substrate** ($g_{22} = 0, g_{12} = 1$, Primorial 210 Ground State)
- **Holographic Bound & Evaporation**: Serves as the prefix-free boundary bitstream for Law 13 (Holographic Area Bound) and Law 21 (Unitary Hawking Radiation Page Curve Stream).

---

## 🚀 Building & Installing

Built with Idris 2 (`0.8.0`):

```bash
idris2 --build Idris2-Universe3.ipkg
idris2 --install Idris2-Universe3.ipkg
```

---

## 🔬 Language & Framework Integration

Written in **Idris 2** enforcing total constructivism (`%default total`).
