# Gacha Solver

Implementation of a solver for a simplified variation of the [Gacha game](https://en.wikipedia.org/wiki/Gacha_game), finding the strategy that minimizes the expected cost of collecting a target set of cards.

## Problem

A gacha game consists of `n` distinct cards and several types of packs.
The goal is to collect a target set of cards while minimizing the expected amount of money spent.
The rules are:

- **Packs** can be bought for a fixed price
- **Opening** a pack pulls exactly one card, chosen randomly according to a probability distribution specific to that pack type
- **Duplicates** can be sold for a fixed price
- **Singles** (specific cards) can be bought for a fixed price

## Approach

The optimal strategy is computed with dynamic programming over all subsets of owned cards.
For each subset, each candidate pack (or single purchase) is evaluated based on the expected costs of the resulting subsets, and the cheapest option is chosen.
This approach enumerates every subset of the card universe, so it only scales to a small number of distinct cards.

For comparison, four greedy heuristics are also included, each picking the next pack by a different rule:

- **Price** - cheapest pack
- **Probability** - highest chance of a new card
- **Ratio** - best probability:price ratio
- **Expected value** - best probability:cost ratio (accounting for duplicate income)

The expected cost of each strategy is calculated via dynamic programming in a similar style to the optimal strategy.
A Monte Carlo simulation is used to verify the computed expected cost of any strategy against its actual average cost over many simulated runs.

## Scenario Format

A scenario is defined in a plain text file using the following declarations:

- `CARD <name> <buy-price|NONE> <sell-price|NONE>` - declares a card
  - `NONE` means the card cannot be bought/sold
- `PACK <price> ... END` - declares a pack
  - Followed by one line per card it can contain, in the format `<card> <weight>`
  - Terminated by `END`
- `TARGET ALL` or `TARGET <card> <card> ...` - declares the set of cards to collect
  - Multiple `TARGET` lines can be used, the sets are combined

Example:

```
CARD Pidgey 400 20
CARD Machop 700 NONE
CARD Articuno NONE 3000

PACK 100
Pidgey 40
Machop 10
Articuno 2
END

TARGET Machop Articuno
```

## Usage

Requires GHC and Cabal.

```bash
cabal run gacha-solver -- <scenario-file>
```

## Example

Running the solver on the included `scenarios/scenario.txt`:

```bash
cabal run gacha-solver -- scenarios/scenario.txt
```

The first column is the strategy name, the second is its calculated expected cost, and the third is its average cost over simulated runs:

```
| Strategy                  |   Expected Cost |  Simulated Cost |
|---------------------------|-----------------|-----------------|
| Greedy: Price             |        70973.56 |        70469.78 |
| Greedy: Probability       |        88714.00 |        88772.92 |
| Greedy: Ratio             |        68913.84 |        68800.53 |
| Greedy: Expected Value    |        65195.92 |        64930.22 |
| Optimal                   |        56339.46 |        56509.28 |
```

## Modules

- **Types** - core data types and small helpers
- **Parser** - reads a scenario file into a `Scenario`
- **Strategies** - the four greedy heuristics
- **Solver** - the dynamic programming solution and `strategyCost` for evaluating any strategy
- **Simulate** - Monte Carlo simulation of a strategy
- **Main** - CLI entry point
