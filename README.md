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

- **Probability** - highest chance of a new card
- **Price** - cheapest pack
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
CARD pidgey 400 20
CARD machop 700 NONE
CARD articuno NONE 3000

PACK 100
pidgey 40
machop 10
articuno 2
END

TARGET machop articuno
```

## Usage

Requires GHC and Cabal.

```bash
cabal run gacha-solver -- <scenario-file>
```

Three example scenarios are included in `scenarios/`: `pokemon.txt`, `rpg.txt`, and `coupon.txt`.

## Example

Running the solver on the included `scenarios/pokemon.txt`:

```bash
cabal run gacha-solver -- scenarios/pokemon.txt
```

The first column is the strategy name, the second is its calculated expected cost, and the third is its average cost over simulated runs:

```
| Strategy                  |   Expected Cost |  Simulated Cost |
|---------------------------|-----------------|-----------------|
| Greedy: Probability       |        46690.05 |        46755.72 |
| Greedy: Price             |        49610.79 |        50024.17 |
| Greedy: Ratio             |        31923.78 |        31930.38 |
| Greedy: Expected Value    |        31150.12 |        31224.18 |
| Optimal                   |        30214.62 |        30192.86 |
```

## Modules

- **Types** - core data types and small helpers
- **Parser** - reads a scenario file into a `Scenario`
- **Strategies** - the four greedy heuristics
- **Solver** - the dynamic programming solution and `strategyCost` for evaluating any strategy
- **Simulate** - Monte Carlo simulation of a strategy
- **Main** - CLI entry point
