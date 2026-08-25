module Types
  ( Card,
    CardWeights,
    BuyPrices,
    SellPrices,
    Collection,
    Pack (..),
    totalWeight,
    newCardWeight,
    newCardProbability,
    candidates,
    unobtainableTargets,
    sellPrice,
    singlesPacks,
    Strategy,
  )
where

import Data.Map qualified as Map
import Data.Set qualified as Set

type Card = Int

type CardWeights = [(Card, Int)]

type BuyPrices = Map.Map Card Int

type SellPrices = Map.Map Card Int

type Collection = Set.Set Card

data Pack = Pack
  { packWeights :: CardWeights,
    packPrice :: Int
  }

totalWeight :: CardWeights -> Int
totalWeight cardWeights = sum [weight | (_, weight) <- cardWeights]

newCardWeight :: Collection -> Pack -> Int
newCardWeight owned pack = sum [weight | (card, weight) <- packWeights pack, not (Set.member card owned)]

newCardProbability :: Collection -> Pack -> Double
newCardProbability owned pack = fromIntegral (newCardWeight owned pack) / fromIntegral (totalWeight (packWeights pack))

candidates :: [Pack] -> Collection -> [Pack]
candidates packs owned = [pack | pack <- packs, newCardWeight owned pack > 0]

unobtainableTargets :: [Pack] -> Collection -> Set.Set Card
unobtainableTargets packs target = Set.difference target (Set.fromList [card | pack <- packs, (card, _) <- packWeights pack])

sellPrice :: Card -> SellPrices -> Int
sellPrice = Map.findWithDefault 0

singlesPacks :: BuyPrices -> [Pack]
singlesPacks prices = [Pack {packWeights = [(card, 1)], packPrice = cardPrice} | (card, cardPrice) <- Map.toList prices]

type Strategy = Collection -> Pack
