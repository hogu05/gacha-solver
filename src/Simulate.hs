module Simulate (simulateOne, simulate) where

import Data.Set qualified as Set
import System.Random (randomRIO)
import Types

pickCard :: Int -> CardWeights -> Card
pickCard _ [] = error "roll exceeded maximum value"
pickCard roll ((card, weight) : rest)
  | roll < weight = card
  | otherwise = pickCard (roll - weight) rest

draw :: CardWeights -> IO Card
draw cardWeights = do
  roll <- randomRIO (0, totalWeight cardWeights - 1)
  return (pickCard roll cardWeights)

simulateOne :: SellPrices -> Collection -> Strategy -> Collection -> IO Int
simulateOne sellPrices universe strategy initial = go initial 0
  where
    go owned spent
      | owned == universe = return spent
      | otherwise = do
          let pack = strategy owned
          card <- draw (packWeights pack)
          let income = if Set.member card owned then sellPrice card sellPrices else 0
          go (Set.insert card owned) (spent + packPrice pack - income)

simulate :: Int -> SellPrices -> Collection -> Strategy -> Collection -> IO Double
simulate n sellPrices universe strategy initial = do
  total <- go n 0
  return (fromIntegral total / fromIntegral n)
  where
    go 0 total = return total
    go k total = do
      spent <- simulateOne sellPrices universe strategy initial
      go (k - 1) (total + spent)
