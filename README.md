## Description

GMX <mark>does use offchain price providers<mark> of Chainlink, of which values are signed by operators and verified when excuting transactions.
So we have to input the oracle prices as the data lens function's parameter.

The Oracle smart contract of GMX stores the oracle prices only when executing a transaction.
Once the transantion has been executed, then the oracle price values of the Oracle smart contract get cleared.
That's why we can't use onchain oracle prices while reading smart contracts.

For example, let's see `executeLiquidation` funtion
https://github.com/gmx-io/gmx-synthetics/blob/178290846694d65296a14b9f4b6ff9beae28a7f7/contracts/exchange/LiquidationHandler.sol#L32-L50
```python:
    // @dev executes a position liquidation
    // @param account the account of the position to liquidate
    // @param market the position's market
    // @param collateralToken the position's collateralToken
    // @param isLong whether the position is long or short
    // @param oracleParams OracleUtils.SetPricesParams
    function executeLiquidation(
        address account,
        address market,
        address collateralToken,
        bool isLong,
        OracleUtils.SetPricesParams calldata oracleParams
    ) external
        globalNonReentrant
        onlyLiquidationKeeper
@>>     withOraclePrices(oracle, dataStore, eventEmitter, oracleParams)
    {
        uint256 startingGas = gasleft();
```
https://github.com/gmx-io/gmx-synthetics/blob/178290846694d65296a14b9f4b6ff9beae28a7f7/contracts/oracle/OracleModule.sol#L13-L35
```python:
    // @dev sets oracle prices, perform any additional tasks required,
    // and clear the oracle prices after
    //
    // care should be taken to avoid re-entrancy while using this call
    // since re-entrancy could allow functions to be called with prices
    // meant for a different type of transaction
    // the tokensWithPrices.length check in oracle.setPrices should help
    // mitigate this
    //
    // @param oracle Oracle
    // @param dataStore DataStore
    // @param eventEmitter EventEmitter
    // @param params OracleUtils.SetPricesParams
    modifier withOraclePrices(
        Oracle oracle,
        DataStore dataStore,
        EventEmitter eventEmitter,
        OracleUtils.SetPricesParams memory params
    ) {
@>>     oracle.setPrices(dataStore, eventEmitter, params);
        _;
@>>     oracle.clearAllPrices();
    }
```

## Before Running
This project uses the [OpenZeppelin Upgrades CLI](https://docs.openzeppelin.com/upgrades-plugins/1.x/api-core) for upgrade safety checks, which are run by default during deployments and upgrades.

If you want to be able to run upgrade safety checks, the following are needed:
1. Install [Node.js](https://nodejs.org/).
2. If you are upgrading your contract from a previous version, add the `@custom:oz-upgrades-from <reference>` annotation to the new version of your contract according to [Define Reference Contracts](https://docs.openzeppelin.com/upgrades-plugins/1.x/api-core#define-reference-contracts) or specify the `referenceContract` option when calling the library's functions.
3. Run `forge clean` before running your Foundry script or tests, or include the `--force` option when running `forge script` or `forge test`.

## Usage

### Install Dependencies

```shell
$ npm install
$ forge install
```

### Configuration

Run below cmd and then fill it with the parameters in .env.example
```shell
$ touch .env
```

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
