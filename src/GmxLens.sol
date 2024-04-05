// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract GmxLens is UUPSUpgradeable, OwnableUpgradeable {
    /// @custom:storage-location erc7201:logarithm.storage.gmxreader
    struct GmxReaderStorage {
        address reader;
        address dataStore;
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

    // keccak256(abi.encode(uint256(keccak256("logarithm.storage.gmxreader")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant GmxReaderStorageLocation =
        0xbce1d4318a1e299492a97d978aca925117f372c83762806dec7145e898132200;

    function initialize(address gmxReader, address gmxDataStorage) public initializer {
        __Ownable_init(_msgSender());
        _setGmxReaderStorage(GmxReaderStorage({reader: gmxReader, dataStore: gmxDataStorage}));
    }

    function setGmxReaderAddresses(address gmxReader, address gmxDataStorage) external onlyOwner {
        _setGmxReaderStorage(GmxReaderStorage({reader: gmxReader, dataStore: gmxDataStorage}));
    }

    function getMarketData(address marketID) external view returns (MarketDataState memory state) {
        
    }

    function getGmxReaderAddresses() public view returns (address reader, address dataStore) {
        GmxReaderStorage storage $ = _getGmxReaderStorage();
        reader = $.reader;
        dataStore = $.dataStore;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function _getGmxReaderStorage() private pure returns (GmxReaderStorage storage $) {
        assembly {
            $.slot := GmxReaderStorageLocation
        }
    }

    function _setGmxReaderStorage(GmxReaderStorage memory value) private {
        GmxReaderStorage storage $ = _getGmxReaderStorage();
        $.reader = value.reader;
        $.dataStore = value.dataStore;
    }
}
