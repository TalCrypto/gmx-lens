// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract GmxLens is UUPSUpgradeable, OwnableUpgradeable {

    /// @custom:storage-location erc7201:logarithm.storage.gmxreader
    struct GmxReaderStorage {
        address reader;
    }

    // keccak256(abi.encode(uint256(keccak256("logarithm.storage.gmxreader")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant GmxReaderStorageLocation = 0xbce1d4318a1e299492a97d978aca925117f372c83762806dec7145e898132200;

    function initialize(address _gmxReader) public initializer {
        __Ownable_init(_msgSender());
        GmxReaderStorage storage $ = _getGmxReaderStorage();
        $.reader = _gmxReader;
    }

    function gmxReader() public view returns (address) {
        GmxReaderStorage storage $ = _getGmxReaderStorage();
        return $.reader;
    }

    function _getGmxReaderStorage() private pure returns (GmxReaderStorage storage $) {
        assembly {
            $.slot := GmxReaderStorageLocation
        }
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
