module Solver (packCost, solve, strategyCost, optimal) where

import Data.List (minimumBy)
import Data.Map qualified as Map
import Data.Ord (comparing)
import Data.Set qualified as Set
import Types

packCost :: SellPrices -> (Collection -> Double) -> Collection -> Pack -> Double
packCost sellPrices cost owned pack = totalCost / fromIntegral (newCardWeight owned pack)
  where
    newCards = [(card, weight) | (card, weight) <- packWeights pack, not (Set.member card owned)]
    duplicates = [(card, weight) | (card, weight) <- packWeights pack, Set.member card owned]
    newCardsCost = sum [fromIntegral weight * cost (Set.insert card owned) | (card, weight) <- newCards]
    income = sum [fromIntegral weight * fromIntegral (sellPrice card sellPrices) | (card, weight) <- duplicates]
    totalCost = fromIntegral (packPrice pack * totalWeight (packWeights pack)) + newCardsCost - income

solve :: [Pack] -> SellPrices -> Collection -> Map.Map Collection (Double, Pack)
solve packs sellPrices universe = solution
  where
    cost owned = fst (solution Map.! owned)
    solution = Map.fromList [(owned, optimalChoice owned) | owned <- Set.toList (Set.powerSet universe)]
    optimalChoice owned
      | owned == universe = (0, error "collection already complete")
      | otherwise = minimumBy (comparing fst) evaluated
      where
        evaluated = [(packCost sellPrices cost owned pack, pack) | pack <- candidates packs owned]

strategyCost :: SellPrices -> Collection -> Strategy -> Collection -> Double
strategyCost sellPrices universe strategy initial = costs Map.! initial
  where
    cost owned = costs Map.! owned
    costs = Map.fromList [(owned, collectionCost owned) | owned <- Set.toList (Set.powerSet universe)]
    collectionCost owned
      | owned == universe = 0
      | otherwise = packCost sellPrices cost owned (strategy owned)

optimal :: [Pack] -> SellPrices -> Collection -> Strategy
optimal packs sellPrices universe = \owned -> snd (solution Map.! owned)
  where
    solution = solve packs sellPrices universe
