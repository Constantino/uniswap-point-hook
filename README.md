
```
# uniswap-point-hook

Project inspired and taken as baseline from: https://github.com/haardikk21/points-hook, as shown in the Uniswap Hook Incubator by Atrium Academy.

A Uniswap V4 hook that implements a points-based reward system for users based on their swap activity and quantity levels.

## Points System

This hook implements a tiered points reward system that incentivizes users based on their swap behavior:

- **First Swap**: Users receive 2% points on their swap amount
- **2+ Swaps**: Users receive 4% points on their swap amount  
- **5+ Swaps**: Users receive 5% points on their swap amount
- **10+ Swaps**: Users receive 10% points on their swap amount
- **15+ Swaps**: Users receive 20% points on their swap amount

The system tracks each user's swap count and automatically applies the appropriate points multiplier. Points are calculated as a percentage of the swap amount and can compound over multiple transactions.

## Features

- **Automatic Points Calculation**: Points are automatically calculated and distributed based on swap quantities
- **Tiered Reward System**: Progressive rewards encourage continued engagement
- **User Tracking**: Maintains swap count per user address
- **Compound Points**: Users can accumulate points across multiple swaps
- **Gas Efficient**: Optimized for minimal gas overhead during swaps

## Testing

Extended test coverage includes:
- **Points Calculation Tests**: Verifies correct points distribution across all tiers
- **Compound Points Tests**: Ensures points accumulate correctly over multiple swaps
- **Edge Case Testing**: Covers boundary conditions and edge scenarios
- **Gas Optimization Tests**: Validates efficient execution



## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help