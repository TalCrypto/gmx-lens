// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {IReader} from "./gmx/reader/IReader.sol";
import {IOracle} from "./gmx/oracle/IOracle.sol";
import {IDataStore} from "./gmx/data/IDataStore.sol";
import {Market} from "./gmx/market/Market.sol";
import {MarketPoolValueInfo} from "./gmx/market/MarketPoolValueInfo.sol";
import {MarketUtils} from "./gmx/market/MarketUtils.sol";
import {ReaderUtils} from "./gmx/reader/ReaderUtils.sol";
import {Keys} from "./gmx/data/Keys.sol";

contract GmxLens is UUPSUpgradeable, OwnableUpgradeable {
    /// @custom:storage-location erc7201:logarithm.storage.gmxlens
    struct GmxLensStorage {
        address reader;
        address dataStore;
        address oracle;
    }

    struct MarketDataState {
        address marketToken;
        address indexToken;
        address longToken;
        address shortToken;
        uint256 poolValue; // 30 decimals
        uint256 longTokenAmount; // token decimals
        uint256 longTokenUsd; // 30 decimals
        uint256 shortTokenAmount; // token decimals
        uint256 shortTokenUsd; // 30 decimals
        int256 openInterestLong; // 30 decimals
        int256 openInterestShort; // 30 decimals
        int256 pnlLong; // 30 decimals
        int256 pnlShort; // 30 decimals
        int256 netPnl; // 30 decimals
        uint256 borrowingFactorPerSecondForLongs; // 30 decimals
        uint256 borrowingFactorPerSecondForShorts; // 30 decimals
        bool longsPayShorts;
        uint256 fundingFactorPerSecond; // 30 decimals
        int256 fundingFactorPerSecondLongs; // 30 decimals
        int256 fundingFactorPerSecondShorts; // 30 decimals
        uint256 reservedUsdLong; // 30 decimals
        uint256 reservedUsdShort; // 30 decimals
        uint256 maxOpenInterestUsdLong; // 30 decimals
        uint256 maxOpenInterestUsdShort; // 30 decimals
    }

    // keccak256(abi.encode(uint256(keccak256("logarithm.storage.gmxlens")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant GmxLensStorageLocation = 0x46ddb7b117f47e3c543a4da0d79b5a9346fd0f9dececc4cd0df8c125c5135100;

    function initialize(address gmxReader, address gmxDataStore, address gmxOracle) public initializer {
        __Ownable_init(_msgSender());
        _setGmxLensStorage(GmxLensStorage({reader: gmxReader, dataStore: gmxDataStore, oracle: gmxOracle}));
    }

    /**
     * @param marketID The address of market token
     * @return state MarketDataState
     */
    function getMarketData(address marketID) external view returns (MarketDataState memory state) {
        (address reader, address dataStore, address oracle) = getGmxLensAddresses();
        Market.Props memory market = IReader(reader).getMarket(dataStore, marketID);

        state.marketToken = market.marketToken;
        state.indexToken = market.indexToken;
        state.longToken = market.longToken;
        state.shortToken = market.shortToken;

        MarketUtils.MarketPrices memory marketPrices = MarketUtils.getMarketPrices(IOracle(oracle), market);

        bytes32 pnlFactorType = Keys.MAX_PNL_FACTOR_FOR_DEPOSITS;
        bool maximize = true;

        (, MarketPoolValueInfo.Props memory marketPoolValueInfo) = IReader(reader).getMarketTokenPrice(
            dataStore,
            market,
            marketPrices.indexTokenPrice,
            marketPrices.longTokenPrice,
            marketPrices.shortTokenPrice,
            pnlFactorType,
            maximize
        );

        state.poolValue = uint256(marketPoolValueInfo.poolValue);
        state.longTokenAmount = marketPoolValueInfo.longTokenAmount;
        state.longTokenUsd = marketPoolValueInfo.longTokenUsd;
        state.shortTokenAmount = marketPoolValueInfo.shortTokenAmount;
        state.shortTokenUsd = marketPoolValueInfo.shortTokenUsd;
        state.pnlLong = marketPoolValueInfo.longPnl;
        state.pnlShort = marketPoolValueInfo.shortPnl;
        state.netPnl = marketPoolValueInfo.netPnl;

        state.openInterestLong = int256(MarketUtils.getOpenInterest(IDataStore(dataStore), market, true));
        state.openInterestShort = int256(MarketUtils.getOpenInterest(IDataStore(dataStore), market, false));

        ReaderUtils.MarketInfo memory marketInfo = IReader(reader).getMarketInfo(dataStore, marketPrices, marketID);

        state.borrowingFactorPerSecondForLongs = marketInfo.borrowingFactorPerSecondForLongs;
        state.borrowingFactorPerSecondForShorts = marketInfo.borrowingFactorPerSecondForShorts;
        state.longsPayShorts = marketInfo.nextFunding.longsPayShorts;
        state.fundingFactorPerSecond = marketInfo.nextFunding.fundingFactorPerSecond;
        // state.fundingFactorPerSecondLongs => not exit
        // state.fundingFactorPerSecondShorts => not exit

        state.reservedUsdLong = MarketUtils.getReservedUsd(IDataStore(dataStore), market, marketPrices, true);
        state.reservedUsdShort = MarketUtils.getReservedUsd(IDataStore(dataStore), market, marketPrices, false);
        state.maxOpenInterestUsdLong = MarketUtils.getMaxOpenInterest(IDataStore(dataStore), market.marketToken, true);
        state.maxOpenInterestUsdShort = MarketUtils.getMaxOpenInterest(IDataStore(dataStore), market.marketToken, false);
    }

    function getGmxLensAddresses() public view returns (address reader, address dataStore, address oracle) {
        GmxLensStorage storage $ = _getGmxLensStorage();
        reader = $.reader;
        dataStore = $.dataStore;
        oracle = $.oracle;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function _getGmxLensStorage() private pure returns (GmxLensStorage storage $) {
        assembly {
            $.slot := GmxLensStorageLocation
        }
    }

    function _setGmxLensStorage(GmxLensStorage memory value) private {
        GmxLensStorage storage $ = _getGmxLensStorage();
        $.reader = value.reader;
        $.dataStore = value.dataStore;
        $.oracle = value.oracle;
    }
}
