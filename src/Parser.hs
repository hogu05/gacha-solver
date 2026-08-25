module Parser (Scenario (..), parseScenario) where

import Data.Map qualified as Map
import Data.Set qualified as Set
import Types

data Scenario = Scenario
  { scenarioUniverse :: Collection,
    scenarioBuyPrices :: BuyPrices,
    scenarioSellPrices :: SellPrices,
    scenarioPacks :: [Pack],
    scenarioTarget :: Collection
  }

type CardIndex = Map.Map String Card

getCard :: CardIndex -> String -> Card
getCard index name = Map.findWithDefault (error ("unknown card: " ++ name)) name index

parsePrice :: String -> Maybe Int
parsePrice "NONE" = Nothing
parsePrice price = Just (read price)

insertPrice :: Card -> Maybe Int -> Map.Map Card Int -> Map.Map Card Int
insertPrice _ Nothing prices = prices
insertPrice card (Just price) prices = Map.insert card price prices

parseCards :: [[String]] -> (CardIndex, BuyPrices, SellPrices)
parseCards = go Map.empty Map.empty Map.empty 0
  where
    go index buyPrices sellPrices _ [] = (index, buyPrices, sellPrices)
    go index buyPrices sellPrices count (("CARD" : name : buy : sell : _) : rest) = go index' buyPrices' sellPrices' (count + 1) rest
      where
        index' = Map.insert name count index
        buyPrices' = insertPrice count (parsePrice buy) buyPrices
        sellPrices' = insertPrice count (parsePrice sell) sellPrices
    go index buyPrices sellPrices count (_ : rest) = go index buyPrices sellPrices count rest

parseScenario :: String -> Scenario
parseScenario input
  | Map.null index = error "no cards were declared"
  | otherwise = buildScenario index buyPrices sellPrices tokens
  where
    tokens = filter (not . null) (map words (lines input))
    (index, buyPrices, sellPrices) = parseCards tokens

buildScenario :: CardIndex -> BuyPrices -> SellPrices -> [[String]] -> Scenario
buildScenario index buyPrices sellPrices = go [] Set.empty
  where
    universe = Set.fromList (Map.elems index)
    go packs target [] =
      Scenario
        { scenarioUniverse = universe,
          scenarioBuyPrices = buyPrices,
          scenarioSellPrices = sellPrices,
          scenarioPacks = packs,
          scenarioTarget = target
        }
    go packs target (("CARD" : _) : rest) = go packs target rest
    go packs target (("PACK" : price : _) : rest) = go (pack : packs) target rest'
      where
        (weights, rest') = parsePack index rest
        pack = Pack {packWeights = weights, packPrice = read price}
    go packs _ (("TARGET" : "ALL" : _) : rest) = go packs universe rest
    go packs target (("TARGET" : names) : rest) = go packs (Set.union target newTargets) rest
      where
        newTargets = Set.fromList (map (getCard index) names)
    go _ _ (line : _) = error ("unexpected line: " ++ unwords line)

parsePack :: CardIndex -> [[String]] -> (CardWeights, [[String]])
parsePack _ (["END"] : rest) = ([], rest)
parsePack index ((name : weightStr : _) : rest)
  | weight <= 0 = error ("weight of " ++ name ++ " must be positive, got " ++ weightStr)
  | otherwise = ((getCard index name, weight) : restWeights, rest')
  where
    weight = read weightStr
    (restWeights, rest') = parsePack index rest
parsePack _ [] = error "PACK block missing END"
parsePack _ (line : _) = error ("unexpected line inside PACK block: " ++ unwords line)
