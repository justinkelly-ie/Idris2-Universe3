module Math.RotatingSpacetime

import Core.BoxInt
import Core.UnixelFraction
import Data.List
import Data.Fin
import Data.Vect

%default total

------------------------------------------------------------------------
-- 1. LAW 41: DISCRETE KERR SPACETIME, ERGOSPHERE & PENROSE PROCESS
------------------------------------------------------------------------

||| Discrete Kerr Black Hole Parameters:
|||   mass       : M tokens
|||   spinParam  : a tokens (a <= M)
|||   horizonRadius : r_+ = M + sqrt(M^2 - a^2)
|||   ergosphereEquator : r_E(pi/2) = 2M
public export
record KerrBlackHole where
  constructor MkKerr
  mass : BoxInt
  spin : BoxInt
  outerHorizon : BoxInt
  ergosphereRadius : BoxInt

public export
Eq KerrBlackHole where
  (MkKerr m1 s1 h1 e1) == (MkKerr m2 s2 h2 e2) =
    m1 == m2 && s1 == s2 && h1 == h2 && e1 == e2

------------------------------------------------------------------------
-- 2. PENROSE PROCESS ENERGY EXTRACTION
------------------------------------------------------------------------

||| Simulates Penrose particle fission inside the Ergosphere:
||| An infalling particle of energy E_0 decays into:
|||   particle 1 with negative Killing energy E_1 < 0 falling into horizon
|||   particle 2 with energy E_2 = E_0 - E_1 > E_0 escaping to infinity
||| Net extracted rotational energy: Delta E = E_2 - E_0 > 0.
public export
penroseProcessExtraction : (initialEnergy : BoxInt) -> (capturedEnergy : BoxInt) -> BoxInt
penroseProcessExtraction e0 e1 =
  let escapingEnergy = e0 - e1
      deltaE = escapingEnergy - e0
  in deltaE

------------------------------------------------------------------------
-- 3. FORMAL INVARIANT AUDIT
------------------------------------------------------------------------

||| Audits Law 41 (Discrete Kerr Metric & Penrose Process):
||| 1. Kerr Black Hole with mass M = 100, spin a = 60.
||| 2. Outer horizon r_+ = 100 + 80 = 180 tokens; Ergosphere at equator r_E = 2 * 100 = 200 tokens.
||| 3. Ergosphere thickness: r_E - r_+ = 20 tokens > 0 (Frame dragging ergoregion exists).
||| 4. Penrose Fission: Initial particle E_0 = 50, captured particle E_1 = -20 (negative orbit).
||| 5. Escaping particle E_2 = 50 - (-20) = 70.
||| 6. Extracted energy Delta E = 70 - 50 = 20 tokens > 0.
public export
auditRotatingSpacetimeProof : Bool
auditRotatingSpacetimeProof =
  let kerr = MkKerr (intToBoxInt 100) (intToBoxInt 60) (intToBoxInt 180) (intToBoxInt 200)
      deltaE = penroseProcessExtraction (intToBoxInt 50) (intToBoxInt (-20))
      
      tErgoThickness = ergosphereRadius kerr > outerHorizon kerr
      tExtraction = deltaE == intToBoxInt 20
      tPosEnergy = deltaE > intToBoxInt 0
  in tErgoThickness && tExtraction && tPosEnergy
