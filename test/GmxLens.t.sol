// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {GmxLens} from "../src/GmxLens.sol";
import {ArbitrumOne} from "../src/address/ArbitrumOne.sol";

contract GmxLensTest is Test {
    GmxLens gmxLens;
    uint256 arbitrumFork;

    function setUp() public {
        arbitrumFork = vm.createFork(vm.rpcUrl("arbitrum_one"));
        vm.selectFork(arbitrumFork);
        address proxy = Upgrades.deployUUPSProxy(
            "GmxLens.sol",
            abi.encodeCall(GmxLens.initialize, (ArbitrumOne.Reader, ArbitrumOne.DataStore, ArbitrumOne.Oracle))
        );
        gmxLens = GmxLens(proxy);
    }

    function test_fork() public {
        assertEq(vm.activeFork(), arbitrumFork);
    }

    function test_getMarketData() public {}

    function test_upgrade() public {
        GmxLens newImplementation = new GmxLens();
        address notOwner = makeAddr("notOwner");
        vm.prank(notOwner);
        vm.expectRevert();
        gmxLens.upgradeToAndCall(address(newImplementation), "");

        vm.prank(address(this));
        gmxLens.upgradeToAndCall(address(newImplementation), "");
    }
}
