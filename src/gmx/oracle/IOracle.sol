// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../price/Price.sol";

interface IOracle {
    function getPrimaryPrice(address token) external view returns (Price.Props memory);
}
