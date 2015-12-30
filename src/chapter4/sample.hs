module Main where

import Sally
import Data.Hashable (Hashable, hash, hashWithSalt)
import Data.HashMap.Strict
import System.Environment

toBitList :: Int -> Int -> [Bool]
toBitList len n | len > 0 = ((n `mod` 2) == 1): toBitList (len-1) (n `div` 2)
                | otherwise = []

data Nat = InNat Int | OutNat Int | TmpNat Int deriving (Show,Read,Ord,Eq)
instance Hashable Nat where
  hashWithSalt s (InNat k) = s + hash k
  hashWithSalt s (TmpNat k) = s + hash k + 1043950
  hashWithSalt s (OutNat k) = s + hash k + 1309482590

makeConst :: (Int -> Nat) -> Int -> Int -> Fml Nat
makeConst type_ bitLength value =
      And $
        fmap (\(bi,b) -> if b then var (type_ bi) else Not (var (type_ bi)))
        (zip [0..] (toBitList bitLength value))

makeEq :: Nat -> Nat -> Fml Nat
makeEq from_ to_ = Or [And[var from_, var to_], And[Not (var from_), Not (var to_)]]

makeNotEq :: Nat -> Nat -> Fml Nat
makeNotEq from_ to_ = Or [And[var from_, Not (var to_)], And[Not (var from_), var to_]]

makeInc :: (Int -> Nat) -> (Int -> Nat) -> Int -> Fml Nat
makeInc from_ to_ bitLength =
  And $ And[makeNotEq (from_ 0) (to_ 0), makeEq (from_ 0) (TmpNat 0)]
          :((\bidx ->
              Or [
                And [      var $ TmpNat (bidx-1),  makeNotEq (from_ bidx) (to_ bidx), makeEq (from_ bidx) (TmpNat bidx)],
                And [Not $ var $ TmpNat (bidx-1), makeEq (from_ bidx) (to_ bidx), Not $ var $ TmpNat bidx]
              ]) <$> [1..(bitLength-1)])

makeDec :: (Int -> Nat) -> (Int -> Nat) -> Int -> Fml Nat
makeDec from_ to_ bitLength =
  And $ And[makeNotEq (from_ 0) (to_ 0), makeNotEq (from_ 0) (TmpNat 0)]
          :((\bidx ->
              Or [
                And [      var $ TmpNat (bidx-1),  makeNotEq (from_ bidx) (to_ bidx), makeNotEq (from_ bidx) (TmpNat bidx)],
                And [Not $ var $ TmpNat (bidx-1), makeEq (from_ bidx) (to_ bidx), Not $ var $ TmpNat bidx]
              ]) <$> [1..bitLength-1])

toInt :: HashMap Nat Bool -> (Int -> Nat) -> Int -> Int
toInt dict type_ bitLength = toInt' bitLength 0 1
  where
    toInt' 0 r _ = r
    toInt' left r f = toInt' (left-1) (r + num * f) (f*2)
      where
        num = if dict ! type_ (bitLength - left) then 1 else 0

main = do
  let fml = And [makeConst InNat 8 255, makeInc InNat OutNat 8]
  let cnf = toCNF (removeNot fml)
  let (vars,dict) = makeAlias cnf
  arg <- getArgs
  case arg of
    "read":_ -> do
      ans <- fromDIMACS dict "p.ans"
      print "Variables: "
      print ans
      print "InNat:"
      print (toInt ans InNat 8)
      print "OutNat:"
      print (toInt ans OutNat 8)
    _ -> do
      toDIMACS vars dict "p.sat"
      print "write to p.sat"
