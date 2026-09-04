import Control.Monad (unless)
import Data.Set qualified as Set
import Parser (Scenario (..), parseScenario)
import Simulate (simulate)
import Solver (optimal, strategyCost)
import Strategies (greedyExpectedValue, greedyPrice, greedyProbability, greedyRatio)
import System.Environment (getArgs)
import Text.Printf (printf)
import Types

reportStrategy :: SellPrices -> Collection -> String -> Strategy -> Collection -> IO ()
reportStrategy sellPrices universe name strategy target = do
  let initial = Set.difference universe target
  let expectedCost = strategyCost sellPrices universe strategy initial
  simulatedCost <- simulate 10000 sellPrices universe strategy initial
  printf "| %-25s | %15.2f | %15.2f |\n" name expectedCost simulatedCost

getScenarioPath :: [String] -> String
getScenarioPath [path] = path
getScenarioPath _ = error "usage: gacha-solver <scenario-file>"

main :: IO ()
main = do
  args <- getArgs
  let path = getScenarioPath args
  input <- readFile path
  let scenario = parseScenario input
  let universe = scenarioUniverse scenario
  let sellPrices = scenarioSellPrices scenario
  let packs = scenarioPacks scenario ++ singlesPacks (scenarioBuyPrices scenario)
  let target = scenarioTarget scenario
  let unobtainable = unobtainableTargets packs target
  unless (Set.null unobtainable) (error ("target includes unobtainable cards: " ++ show (Set.toList unobtainable)))

  printf "| %-25s | %15s | %15s |\n" "Strategy" "Expected Cost" "Simulated Cost"
  putStrLn "|---------------------------|-----------------|-----------------|"
  reportStrategy sellPrices universe "Greedy: Probability" (greedyProbability packs) target
  reportStrategy sellPrices universe "Greedy: Price" (greedyPrice packs) target
  reportStrategy sellPrices universe "Greedy: Ratio" (greedyRatio packs) target
  reportStrategy sellPrices universe "Greedy: Expected Value" (greedyExpectedValue sellPrices packs) target
  reportStrategy sellPrices universe "Optimal" (optimal packs sellPrices universe) target
