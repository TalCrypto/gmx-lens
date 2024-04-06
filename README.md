## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Before Running
This project uses the [OpenZeppelin Upgrades CLI](https://docs.openzeppelin.com/upgrades-plugins/1.x/api-core) for upgrade safety checks, which are run by default during deployments and upgrades.

If you want to be able to run upgrade safety checks, the following are needed:
1. Install [Node.js](https://nodejs.org/).
2. If you are upgrading your contract from a previous version, add the `@custom:oz-upgrades-from <reference>` annotation to the new version of your contract according to [Define Reference Contracts](https://docs.openzeppelin.com/upgrades-plugins/1.x/api-core#define-reference-contracts) or specify the `referenceContract` option when calling the library's functions.
3. Run `forge clean` before running your Foundry script or tests, or include the `--force` option when running `forge script` or `forge test`.

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ npm run test
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
$ source .env

$ forge clean

# To deploy and verify our contract onto Arbitrum One
$ forge script script/01_GmxLensDeploy.s.sol:GmxLensArbiDeployScript --rpc-url $ARBITRUM_ONE_RPC_URL --broadcast --verify -vvvv

# To deploy and verify our contract onto Avalanche
$ forge script script/01_GmxLensDeploy.s.sol:GmxLensAvaDeployScript --rpc-url $AVALANCHE_RPC_URL --broadcast --verify -vvvv
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
```
