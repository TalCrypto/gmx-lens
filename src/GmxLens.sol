// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

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
    bytes32 private constant GmxLensStorageLocation =
        0x46ddb7b117f47e3c543a4da0d79b5a9346fd0f9dececc4cd0df8c125c5135100;

    function initialize(address gmxReader, address gmxDataStorage, address gmxOracle) public initializer {
        __Ownable_init(_msgSender());
        _setGmxLensStorage(GmxLensStorage({reader: gmxReader, dataStore: gmxDataStorage, oracle: gmxOracle}));
    }

    function getMarketData(address marketID) external view returns (MarketDataState memory state) {

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
