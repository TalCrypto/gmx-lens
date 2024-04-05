// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../market/MarketUtils.sol";
import "../market/Market.sol";

// @title ReaderUtils
// @dev Library for read utils functions
// convers some internal library functions into external functions to reduce
// the Reader contract size
library ReaderUtils {

    struct VirtualInventory {
        uint256 virtualPoolAmountForLongToken;
        uint256 virtualPoolAmountForShortToken;
        int256 virtualInventoryForPositions;
    }

    struct BaseFundingValues {
        MarketUtils.PositionType fundingFeeAmountPerSize;
        MarketUtils.PositionType claimableFundingAmountPerSize;
    }

    struct MarketInfo {
        Market.Props market;
        uint256 borrowingFactorPerSecondForLongs;
        uint256 borrowingFactorPerSecondForShorts;
        BaseFundingValues baseFunding;
        MarketUtils.GetNextFundingAmountPerSizeResult nextFunding;
        VirtualInventory virtualInventory;
        bool isDisabled;
    }

}