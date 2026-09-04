module Math.TripleAlphaNucleosynthesis

import Core.BoxInt
import Data.List

%default total

------------------------------------------------------------------------
-- 1. LAW 52: DISCRETE TRIPLE-ALPHA CARBON & PHOSPHORUS NUCLEOSYNTHESIS
------------------------------------------------------------------------

||| Evaluates Triple-Alpha fusion mass token conservation: 3 * Alpha (108) = Carbon-12 (324).
%inline
public export
tripleAlphaFusionTokens : BoxInt -> BoxInt
tripleAlphaFusionTokens alphaMass = intToBoxInt 3 * alphaMass

||| Evaluates Phosphorus-31 synthesis token count (837 tokens = 31 * 27).
%inline
public export
phosphorus31MassTokens : BoxInt
phosphorus31MassTokens = intToBoxInt 837

------------------------------------------------------------------------
-- 2. FORMAL INVARIANT AUDIT PROOFS
------------------------------------------------------------------------

||| Audits Law 52 (Triple-Alpha Carbon & Phosphorus Nucleosynthesis):
||| 1. 3 * 108 = 324 mass tokens for 12C core.
||| 2. 31P carries 837 mass tokens (31 amu).
%inline
public export
auditLaw52TripleAlphaProof : Bool
auditLaw52TripleAlphaProof =
  let c12 = tripleAlphaFusionTokens (intToBoxInt 108)
  in (unwrapBox c12 == 324) && (unwrapBox phosphorus31MassTokens == 837)
