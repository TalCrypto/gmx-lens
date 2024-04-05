// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

contract CounterTest is Test {
    function setUp() public {}

    function test_storage() public {
        emit log_bytes32(
            keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Ownable")) - 1)) & ~bytes32(uint256(0xff))
        );
        emit log_bytes32(
            keccak256(abi.encode(uint256(keccak256("logarithm.storage.gmxreader")) - 1)) & ~bytes32(uint256(0xff))
        );
    }
}
