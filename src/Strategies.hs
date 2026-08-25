module Strategies (greedyPrice, greedyProbability, greedyRatio, greedyExpectedValue) where

import Data.List (maximumBy, minimumBy)
import Data.Ord (comparing)
import Data.Set qualified as Set
import Types

greedyPrice :: [Pack] -> Strategy
greedyPrice packs owned = minimumBy (comparing packPrice) (candidates packs owned)

greedyProbability :: [Pack] -> Strategy
greedyProbability packs owned = maximumBy (comparing (newCardProbability owned)) (candidates packs owned)

greedyRatio :: [Pack] -> Strategy
greedyRatio packs owned = maximumBy (comparing ratio) (candidates packs owned)
  where
    ratio :: Pack -> Double
    ratio pack = newCardProbability owned pack / fromIntegral (packPrice pack)

greedyExpectedValue :: SellPrices -> [Pack] -> Strategy
greedyExpectedValue sellPrices packs owned = maximumBy (comparing expectedValue) (candidates packs owned)
  where
    expectedValue :: Pack -> Double
    expectedValue pack = newCardProbability owned pack / expectedCost
      where
        totalIncome = sum [weight * sellPrice card sellPrices | (card, weight) <- packWeights pack, Set.member card owned]
        expectedIncome = fromIntegral totalIncome / fromIntegral (totalWeight (packWeights pack))
        expectedCost = max 0 (fromIntegral (packPrice pack) - expectedIncome)
