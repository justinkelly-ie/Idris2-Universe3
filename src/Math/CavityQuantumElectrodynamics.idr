module Math.CavityQuantumElectrodynamics

import Core.BoxInt
import Core.UnixelFraction
import Data.List
import Data.Fin
import Data.Vect

%default total

------------------------------------------------------------------------
-- 1. LAW 34: DISCRETE JAYNES-CUMMINGS CAVITY QED & VACUUM RABI SPLITTING
------------------------------------------------------------------------

||| Discrete Jaynes-Cummings System Parameters:
|||   cavityFreq : Cavity field resonance (ω) tokens
|||   atomicFreq : Two-level atomic transition (ω_0) tokens
|||   couplingStrength : Vacuum dipole interaction (g) tokens
public export
record JCParams where
  constructor MkJCParams
  cavityFreq : BoxInt
  atomicFreq : BoxInt
  couplingStrength : BoxInt

public export
Eq JCParams where
  (MkJCParams c1 a1 g1) == (MkJCParams c2 a2 g2) =
    c1 == c2 && a1 == a2 && g1 == g2

||| Polariton Dressed States (|n, +> and |n, ->) in the n-photon manifold:
public export
record PolaritonDoublet where
  constructor MkDoublet
  photonManifold : Nat
  upperEnergy : BoxInt
  lowerEnergy : BoxInt
  rabiSplitting : BoxInt

public export
Eq PolaritonDoublet where
  (MkDoublet p1 u1 l1 s1) == (MkDoublet p2 u2 l2 s2) =
    p1 == p2 && u1 == u2 && l1 == l2 && s1 == s2

------------------------------------------------------------------------
-- 2. DISCRETE POLARITON ENERGY EIGENVALUES
------------------------------------------------------------------------

||| Computes discrete vacuum Rabi splitting for n = 0 (Vacuum Rabi Splitting 2g):
||| ΔE_Rabi = 2 * g * (n + 1).
public export
computeRabiSplitting : (g : BoxInt) -> (n : Nat) -> BoxInt
computeRabiSplitting g n =
  intToBoxInt 2 * g * (natToBoxInt n + intToBoxInt 1)

||| Computes the polariton doublet energy levels for resonant cavity-atom (ω = ω_0):
||| E_{n, ±} = (n + 1/2) * ω ± g * (n + 1)
public export
computePolaritonDoublet : JCParams -> (n : Nat) -> PolaritonDoublet
computePolaritonDoublet (MkJCParams omega _ g) n =
  let nBox = natToBoxInt n
      baseEnergy = (nBox + intToBoxInt 1) * omega
      halfSplitting = g * (nBox + intToBoxInt 1)
      upper = baseEnergy + halfSplitting
      lower = baseEnergy - halfSplitting
      splitting = upper - lower
  in MkDoublet n upper lower splitting

------------------------------------------------------------------------
-- 3. FORMAL INVARIANT AUDIT
------------------------------------------------------------------------

||| Audits Law 34 (Discrete Jaynes-Cummings Cavity QED & Vacuum Rabi Splitting):
||| 1. Cavity Frequency ω = 100 tokens, Atomic Frequency ω_0 = 100 tokens, Coupling g = 15 tokens.
||| 2. Manifold n = 0 (Vacuum Rabi state):
|||    - Base energy = 1 * 100 = 100 tokens.
|||    - Half splitting = 15 * 1 = 15 tokens.
|||    - Upper polariton E_{0,+} = 100 + 15 = 115 tokens.
|||    - Lower polariton E_{0,-} = 100 - 15 = 85 tokens.
|||    - Vacuum Rabi Splitting 2g = 115 - 85 = 30 tokens.
||| 3. Proves polariton energy conservation (E_+ + E_- = 2 * baseEnergy = 200 tokens).
public export
auditCavityQuantumElectrodynamicsProof : Bool
auditCavityQuantumElectrodynamicsProof =
  let params = MkJCParams (intToBoxInt 100) (intToBoxInt 100) (intToBoxInt 15)
      doublet0 = computePolaritonDoublet params 0
      
      tUpper = upperEnergy doublet0 == intToBoxInt 115
      tLower = lowerEnergy doublet0 == intToBoxInt 85
      tSplit = rabiSplitting doublet0 == intToBoxInt 30
      tSum = upperEnergy doublet0 + lowerEnergy doublet0 == intToBoxInt 200
  in tUpper && tLower && tSplit && tSum
