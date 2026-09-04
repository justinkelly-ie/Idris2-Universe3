module Math.ActionPrinciple

import Core.BoxInt
import Core.VexelMaxel
import Math.LinAlgebra.MetricTensor
import Math.FourGeometries
import Data.Vect
import Data.List

%default total

------------------------------------------------------------------------
-- 1. DISCRETE LATTICE TRAJECTORY & VARIATIONAL ACTION SUM
------------------------------------------------------------------------

||| A 2D spatial coordinate on the discrete lattice.
public export
record Coord2D where
  constructor MkCoord2D
  posX : BoxInt
  posY : BoxInt

public export
Eq Coord2D where
  (MkCoord2D x1 y1) == (MkCoord2D x2 y2) = x1 == x2 && y1 == y2

||| Difference vector between two lattice coordinates: Δx = x_{k+1} - x_k.
%inline
public export
coordDiff : Coord2D -> Coord2D -> Coord2D
coordDiff (MkCoord2D x2 y2) (MkCoord2D x1 y1) = MkCoord2D (x2 - x1) (y2 - y1)

||| Computes metric kinetic quadrance: T_g(Δx) = Δx^T · g · Δx.
%inline
public export
metricKineticQuadrance : Maxel -> Coord2D -> BoxInt
metricKineticQuadrance m (MkCoord2D dx dy) =
  let g11Val = g11 m
      g12Val = g12 m
      g22Val = g22 m
      row1 = (g11Val * dx) + (g12Val * dy)
      row2 = (g12Val * dx) + (g22Val * dy)
  in (dx * row1) + (dy * row2)

||| Discrete Lagrangian: L(x_k, x_{k+1}) = T_g(Δx) + SubstrateCoupling(x_k, x_{k+1}) - V(x_k).
%inline
public export
discreteLagrangian : FundamentalGeometry -> Coord2D -> Coord2D -> (Coord2D -> BoxInt) -> BoxInt
discreteLagrangian geom (MkCoord2D x1 y1) (MkCoord2D x2 y2) vPot =
  let metric = geometryMetric geom
      diff = MkCoord2D (x2 - x1) (y2 - y1)
      tKin = metricKineticQuadrance metric diff
      vVal = vPot (MkCoord2D x1 y1)
      causalCoupling = case geom of
                         SubstrateGeom => (x2 - x1) * y1
                         _             => intToBoxInt 0
  in (tKin + causalCoupling) - vVal

||| Computes the Discrete Action S[γ] along an ordered sequence of coordinates.
%inline
public export
discreteAction : FundamentalGeometry -> List Coord2D -> (Coord2D -> BoxInt) -> BoxInt
discreteAction _ [] _ = intToBoxInt 0
discreteAction _ [x] _ = intToBoxInt 0
discreteAction geom (x0 :: x1 :: xs) vPot =
  discreteLagrangian geom x0 x1 vPot + discreteAction geom (x1 :: xs) vPot

------------------------------------------------------------------------
-- 2. DISCRETE EULER-LAGRANGE EQUATIONS (DEL)
--    g · (x_{k+1} - 2x_k + x_{k-1}) = -∇V(x_k)  (Discrete F = ma)
------------------------------------------------------------------------

||| Discrete second-order difference / acceleration: Δ²x = x_{k+1} - 2x_k + x_{k-1}.
%inline
public export
discreteAcceleration : Coord2D -> Coord2D -> Coord2D -> Coord2D
discreteAcceleration (MkCoord2D xPrev yPrev) (MkCoord2D xCurr yCurr) (MkCoord2D xNext yNext) =
  MkCoord2D ( xNext - (intToBoxInt 2 * xCurr) + xPrev )
            ( yNext - (intToBoxInt 2 * yCurr) + yPrev )

||| Discrete Euler-Lagrange residual: g · Δ²x + ∇V(x_k).
||| For extremal physical trajectories, this residual evaluates strictly to (0, 0).
%inline
public export
discreteEulerLagrangeResidual : Maxel -> Coord2D -> Coord2D -> Coord2D -> Coord2D -> Coord2D
discreteEulerLagrangeResidual m prev curr next (MkCoord2D gradVx gradVy) =
  let MkCoord2D ax ay = discreteAcceleration prev curr next
      forceX = (g11 m * ax) + (g12 m * ay) + gradVx
      forceY = (g12 m * ax) + (g22 m * ay) + gradVy
  in MkCoord2D forceX forceY

------------------------------------------------------------------------
-- 3. CONSTRUCTIVE FORMAL AUDIT PROOFS
------------------------------------------------------------------------

||| Zero potential function for free particle trajectories.
%inline
public export
zeroPotential : Coord2D -> BoxInt
zeroPotential _ = intToBoxInt 0

||| Linear potential gradient: V(x, y) = x -> ∇V = (1, 0).
%inline
public export
linearPotentialGrad : Coord2D
linearPotentialGrad = MkCoord2D (intToBoxInt 1) (intToBoxInt 0)

||| Audits Discrete Euler-Lagrange Equivalence on Geodesics:
||| Proves that the discrete Euler-Lagrange residual evaluates to (0, 0)
||| along the geodesic [(0,0), (1,1), (2,2)].
%inline
public export
auditDiscreteEulerLagrangeEquivalenceProof : Bool
auditDiscreteEulerLagrangeEquivalenceProof =
  let p0 = MkCoord2D (intToBoxInt 0) (intToBoxInt 0)
      p1 = MkCoord2D (intToBoxInt 1) (intToBoxInt 1)
      p2 = MkCoord2D (intToBoxInt 2) (intToBoxInt 2)
      res = discreteEulerLagrangeResidual (geometryMetric EllipticGeom) p0 p1 p2 (MkCoord2D (intToBoxInt 0) (intToBoxInt 0))
  in (unwrapBox (posX res) == 0) && (unwrapBox (posY res) == 0)

||| Audits Substrate Action Asymmetry (The Causal Arrow of Time in Hamilton's Principle):
||| Proves that under SubstrateGeom, S[forward] ≠ S[reverse] for path [(0,0) -> (1,2)].
%inline
public export
auditSubstrateActionAsymmetryProof : Bool
auditSubstrateActionAsymmetryProof =
  let p1 = [MkCoord2D (intToBoxInt 0) (intToBoxInt 0), MkCoord2D (intToBoxInt 1) (intToBoxInt 2)]
      p2 = [MkCoord2D (intToBoxInt 1) (intToBoxInt 2), MkCoord2D (intToBoxInt 0) (intToBoxInt 0)]
      sFwd = discreteAction SubstrateGeom p1 zeroPotential
      sRev = discreteAction SubstrateGeom p2 zeroPotential
  in (unwrapBox sFwd /= unwrapBox sRev) && (unwrapBox sFwd > 0)

||| Computes discrete canonical momentum token: p_k = g · (x_{k+1} - x_k).
%inline
public export
discreteCanonicalMomentum : Maxel -> Coord2D -> Coord2D -> Coord2D
discreteCanonicalMomentum m (MkCoord2D x1 y1) (MkCoord2D x2 y2) =
  let dx = x2 - x1
      dy = y2 - y1
      px = (g11 m * dx) + (g12 m * dy)
      py = (g12 m * dx) + (g22 m * dy)
  in MkCoord2D px py

||| Audits Geodesic Least Action Optimality:
||| Proves that the straight geodesic path [(0,0), (1,1), (2,2)] strictly minimizes
||| Action over the deflected path [(0,0), (0,2), (2,2)].
%inline
public export
auditGeodesicLeastActionOptimalityProof : Bool
auditGeodesicLeastActionOptimalityProof =
  let pStraight = [MkCoord2D (intToBoxInt 0) (intToBoxInt 0), MkCoord2D (intToBoxInt 1) (intToBoxInt 1), MkCoord2D (intToBoxInt 2) (intToBoxInt 2)]
      pDeflected = [MkCoord2D (intToBoxInt 0) (intToBoxInt 0), MkCoord2D (intToBoxInt 0) (intToBoxInt 2), MkCoord2D (intToBoxInt 2) (intToBoxInt 2)]
      sStraight = discreteAction EllipticGeom pStraight zeroPotential
      sDeflected = discreteAction EllipticGeom pDeflected zeroPotential
  in unwrapBox sStraight < unwrapBox sDeflected

||| Audits Discrete Noether Momentum Conservation:
||| Proves that for free motion along a geodesic, discrete momentum p_k = g · Δx
||| is strictly identical across consecutive steps: p_0 == p_1.
%inline
public export
auditDiscreteMomentumConservationProof : Bool
auditDiscreteMomentumConservationProof =
  let p0 = MkCoord2D (intToBoxInt 0) (intToBoxInt 0)
      p1 = MkCoord2D (intToBoxInt 1) (intToBoxInt 1)
      p2 = MkCoord2D (intToBoxInt 2) (intToBoxInt 2)
      m0 = discreteCanonicalMomentum (geometryMetric EllipticGeom) p0 p1
      m1 = discreteCanonicalMomentum (geometryMetric EllipticGeom) p1 p2
  in (unwrapBox (posX m0) == unwrapBox (posX m1)) && (unwrapBox (posY m0) == unwrapBox (posY m1))

||| Audits Parabolic Null Momentum Zero Invariant:
||| Proves that in Parabolic geometry (det g = 0), momentum along the degenerate
||| null direction (0, 1) evaluates to exactly (0, 0).
%inline
public export
auditParabolicNullMomentumZeroProof : Bool
auditParabolicNullMomentumZeroProof =
  let p0 = MkCoord2D (intToBoxInt 0) (intToBoxInt 0)
      p1 = MkCoord2D (intToBoxInt 0) (intToBoxInt 1)
      m  = discreteCanonicalMomentum (geometryMetric ParabolicGeom) p0 p1
  in (unwrapBox (posX m) == 0) && (unwrapBox (posY m) == 0)

||| Audits Sector-Specific Action Signatures across the 4 Geometries:
||| For displacement Δx = (1, 1).
%inline
public export
auditSectorSpecificActionSignaturesProof : Bool
auditSectorSpecificActionSignaturesProof =
  let path = [MkCoord2D (intToBoxInt 0) (intToBoxInt 0), MkCoord2D (intToBoxInt 1) (intToBoxInt 1)]
      sEll = discreteAction EllipticGeom path zeroPotential
      sHyp = discreteAction HyperbolicGeom path zeroPotential
      sPar = discreteAction ParabolicGeom path zeroPotential
      sSub = discreteAction SubstrateGeom path zeroPotential
  in unwrapBox sEll == 2 &&
     unwrapBox sHyp == 0 &&
     unwrapBox sPar == 1 &&
     unwrapBox sSub == 3
