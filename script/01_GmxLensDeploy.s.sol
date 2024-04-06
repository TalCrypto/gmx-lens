// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {ArbitrumOneAddresses} from "../src/config/ArbitrumOneAddresses.sol";
import {AvalancheAddresses} from "../src/config/AvalancheAddresses.sol";
import {GmxLens} from "../src/GmxLens.sol";

contract GmxLensArbiDeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address proxy = Upgrades.deployUUPSProxy(
            "GmxLens.sol",
            abi.encodeCall(GmxLens.initialize, (ArbitrumOneAddresses.Reader, ArbitrumOneAddresses.DataStore))
        );
        console.log("deployed address", proxy);
        vm.stopBroadcast();
    }
}

contract GmxLensAvaDeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address proxy = Upgrades.deployUUPSProxy(
            "GmxLens.sol",
            abi.encodeCall(GmxLens.initialize, (AvalancheAddresses.Reader, AvalancheAddresses.DataStore))
        );
        console.log("deployed address", proxy);
        vm.stopBroadcast();
    }
}
