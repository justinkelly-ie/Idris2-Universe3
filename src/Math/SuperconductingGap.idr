module Math.SuperconductingGap

import Core.BoxInt
import Core.UnixelFraction
import Core.Multiset
import Math.ExclusionPrinciple
import Data.List
import Data.Fin
import Data.Vect

%default total

------------------------------------------------------------------------
-- 1. LAW 29: DISCRETE BCS SUPERCONDUCTIVITY & ENERGY GAP
------------------------------------------------------------------------

||| Discrete BCS Superconducting State on a multi-fermion lattice.
||| Represents Cooper pair pairing amplitude and discrete energy gap.
public export
record DiscreteBCSState where
  constructor MkBCSState
  ||| Debye cutoff energy tokens (ω_D)
  debyeEnergy : BoxInt
  ||| Pairing coupling strength tokens (V_0)
  couplingStrength : BoxInt
  ||| Electronic density of states tokens (N_0)
  densityOfStates : BoxInt
  ||| Cooper pair condensation energy gap tokens (Δ_0)
  energyGap : BoxInt
  ||| Ground state condensation energy saving (E_cond < 0)
  condensationEnergy : BoxInt

public export
Eq DiscreteBCSState where
  (MkBCSState d1 c1 n1 g1 e1) == (MkBCSState d2 c2 n2 g2 e2) =
    d1 == d2 && c1 == c2 && n1 == n2 && g1 == g2 && e1 == e2

------------------------------------------------------------------------
-- 2. DISCRETE GAP EQUATION & CONDENSATION FREE ENERGY
------------------------------------------------------------------------

||| Computes the discrete BCS energy gap:
||| Δ_0 = (2 * ω_D * couplingStrength * densityOfStates) / (couplingStrength * densityOfStates + 10)
public export
computeBCSGap : (debye : BoxInt) -> (coupling : BoxInt) -> (dos : BoxInt) -> BoxInt
computeBCSGap debye coupling dos =
  let g = coupling * dos
      denom = g + intToBoxInt 10
  in if unwrapBox denom > 0
        then (intToBoxInt 2 * debye * g) `div` denom
        else intToBoxInt 0

||| Computes the discrete condensation energy saving:
||| E_cond = - (1/2) * N_0 * Δ_0^2
public export
computeCondensationSaving : (dos : BoxInt) -> (gap : BoxInt) -> BoxInt
computeCondensationSaving dos gap =
  let gapSq = gap * gap
      saving = (dos * gapSq) `div` intToBoxInt 2
  in intToBoxInt (-1) * saving

||| Constructs a discrete BCS ground state for given parameters.
public export
synthesizeBCSState : (debye : BoxInt) -> (coupling : BoxInt) -> (dos : BoxInt) -> DiscreteBCSState
synthesizeBCSState debye coupling dos =
  let gap = computeBCSGap debye coupling dos
      cond = computeCondensationSaving dos gap
  in MkBCSState debye coupling dos gap cond

------------------------------------------------------------------------
-- 3. FORMAL INVARIANT AUDIT
------------------------------------------------------------------------

||| Audits Law 29 (Discrete BCS Superconductivity & Energy Gap):
||| 1. Debye energy ω_D = 100, Coupling V_0 = 2, DOS N_0 = 5.
||| 2. Coupling product g = 2 * 5 = 10.
||| 3. Energy Gap Δ_0 = (2 * 100 * 10) / (10 + 10) = 2000 / 20 = 100 tokens.
||| 4. Condensation saving E_cond = - (1/2) * 5 * 100^2 = - (5 * 10000) / 2 = -25000 tokens.
||| 5. Condensation energy is strictly negative (superconducting state is thermodynamically favored).
public export
auditSuperconductingGapProof : Bool
auditSuperconductingGapProof =
  let bcs = synthesizeBCSState (intToBoxInt 100) (intToBoxInt 2) (intToBoxInt 5)
      tGap = energyGap bcs == intToBoxInt 100
      tCond = condensationEnergy bcs == intToBoxInt (-25000)
      tThermodynamic = unwrapBox (condensationEnergy bcs) < 0
  in tGap && tCond && tThermodynamic
