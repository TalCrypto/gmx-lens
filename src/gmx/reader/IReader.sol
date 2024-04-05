// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Market} from "../market/Market.sol";
import {MarketUtils} from "../market/MarketUtils.sol";
import {MarketPoolValueInfo} from "../market/MarketPoolValueInfo.sol";
import {Price} from "../price/Price.sol";
import {ReaderUtils} from "./ReaderUtils.sol";

interface IReader {
    /**
     * @notice Get market props
     * @param dataStore The address of gmx dataStore contract
     * @param key The address of gmx market
     */
    function getMarket(address dataStore, address key) external view returns (Market.Props memory);

    function getMarketInfo(address dataStore, MarketUtils.MarketPrices memory prices, address marketKey)
        external
        view
        returns (ReaderUtils.MarketInfo memory);

    function getMarketTokenPrice(
        address dataStore,
        Market.Props memory market,
        Price.Props memory indexTokenPrice,
        Price.Props memory longTokenPrice,
        Price.Props memory shortTokenPrice,
        bytes32 pnlFactorType,
        bool maximize
    ) external view returns (int256, MarketPoolValueInfo.Props memory);
}
