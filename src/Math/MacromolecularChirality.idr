module Math.MacromolecularChirality

import Core.BoxInt
import Data.List

%default total

------------------------------------------------------------------------
-- 1. LAW 49: DISCRETE MACROMOLECULAR HOMOCHIRALITY & PEPTIDE CONDENSATION
------------------------------------------------------------------------

||| Stereochemical Enantiomer Chirality Handedness.
public export
data EnantiomerHand = LHand | DHand

public export
Eq EnantiomerHand where
  LHand == LHand = True
  DHand == DHand = True
  _     == _     = False

||| Inverts enantiomer chirality (L <-> D inversion).
%inline
public export
invertChirality : EnantiomerHand -> EnantiomerHand
invertChirality LHand = DHand
invertChirality DHand = LHand

||| Verifies homochiral peptide chain uniformity (all L-amino acids).
%inline
public export
isHomochiralChain : List EnantiomerHand -> Bool
isHomochiralChain chain = all (== LHand) chain

||| Evaluates peptide condensation token conservation: (m1 + m2 - 18) = mPeptide.
%inline
public export
condensePeptideBond : BoxInt -> BoxInt -> BoxInt
condensePeptideBond m1 m2 = (m1 + m2) - intToBoxInt 18

------------------------------------------------------------------------
-- 2. FORMAL INVARIANT AUDIT PROOFS
------------------------------------------------------------------------

||| Audits Law 49 (Macromolecular Homochirality & Peptide Condensation):
||| 1. Enantiomer inversion is an involution: invert(invert(L)) == L.
||| 2. Peptide condensation conserves mass tokens: (100 + 100 - 18) == 182.
%inline
public export
auditLaw49MacromolecularChiralityProof : Bool
auditLaw49MacromolecularChiralityProof =
  (invertChirality (invertChirality LHand) == LHand) &&
  isHomochiralChain [LHand, LHand, LHand] &&
  (unwrapBox (condensePeptideBond (intToBoxInt 100) (intToBoxInt 100)) == 182)
