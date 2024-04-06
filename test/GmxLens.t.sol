// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {GmxLens} from "../src/GmxLens.sol";
import {ArbitrumOneAddresses} from "../src/config/ArbitrumOneAddresses.sol";
import {AvalancheAddresses} from "../src/config/AvalancheAddresses.sol";
import {IReader} from "../src/gmx/reader/IReader.sol";
import {Market} from "../src/gmx/market/Market.sol";
import {MarketUtils} from "../src/gmx/market/MarketUtils.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract GmxLensTest is Test {
    using stdJson for string;
    address public constant ArbiEthMarketID = 0x70d95587d40A2caf56bd97485aB3Eec10Bee6336;
    address public constant ArbiDogeMarketID = 0x6853EA96FF216fAb11D2d930CE3C508556A4bdc4;

    struct OffchainPrice {
        uint256 updatedAt;
        uint256 maxPrice;
        uint256 minPrice;
        address tokenAddress;
        bytes32 tokenSymbol;
    }

    GmxLens gmxLens;
    uint256 arbitrumFork;

    function setUp() public {
        arbitrumFork = vm.createFork(vm.rpcUrl("arbitrum_one"));
        vm.selectFork(arbitrumFork);
        address proxy = Upgrades.deployUUPSProxy(
            "GmxLens.sol",
            abi.encodeCall(GmxLens.initialize, (ArbitrumOneAddresses.Reader, ArbitrumOneAddresses.DataStore))
        );
        gmxLens = GmxLens(proxy);
    }

    function test_fork() public view{
        assertEq(vm.activeFork(), arbitrumFork);
    }

    function test_getMarketData() public view{
        (address reader, address dataStore) = gmxLens.getGmxLensAddresses();
        Market.Props memory market = IReader(reader).getMarket(dataStore, ArbiDogeMarketID);
        MarketUtils.MarketPrices memory marketPrices;

        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/priceData.json");
        string memory json = vm.readFile(path);

        OffchainPrice memory data;

        for(uint i; i<20; i++) {
            bytes memory priceData = json.parseRaw(string(abi.encodePacked(abi.encodePacked(".data[", Strings.toString(i)), "]")));
            data = abi.decode(priceData, (OffchainPrice));
            
            if(data.tokenAddress == market.indexToken) {
                marketPrices.indexTokenPrice.min = data.minPrice;
                marketPrices.indexTokenPrice.max = data.maxPrice;
            }
            if(data.tokenAddress == market.longToken) {
                marketPrices.longTokenPrice.min = data.minPrice;
                marketPrices.longTokenPrice.max = data.maxPrice;
            }
            if(data.tokenAddress == market.shortToken) {
                marketPrices.shortTokenPrice.min = data.minPrice;
                marketPrices.shortTokenPrice.max = data.maxPrice;
            }
        } 

        GmxLens.MarketDataState memory state =  gmxLens.getMarketData(ArbiDogeMarketID, marketPrices);
        console2.log("marketToken:      ", state.marketToken);
        console2.log("indexToken:       ", state.indexToken);
        console2.log("longToken:        ", state.longToken);
        console2.log("shortToken:       ", state.shortToken);
        console2.log("poolValue:        ", state.poolValue);
        console2.log("longTokenAmount:  ", state.longTokenAmount);
        console2.log("longTokenUsd:     ", state.longTokenUsd);
        console2.log("shortTokenAmount: ", state.shortTokenAmount);
        console2.log("shortTokenUsd:    ", state.shortTokenUsd);
        console2.log("openInterestLong: ", state.openInterestLong);
        console2.log("openInterestShort:", state.openInterestShort);
        console2.log("pnlLong:          ", state.pnlLong);
        console2.log("pnlShort:         ", state.pnlShort);
        console2.log("netPnl:           ", state.netPnl);
        console2.log("longsPayShorts:   ", state.longsPayShorts);
        console2.log("reservedUsdLong:  ", state.reservedUsdLong);
        console2.log("reservedUsdShort: ", state.reservedUsdShort);
        console2.log("borrowingFactorPerSecondForLongs:  ", state.borrowingFactorPerSecondForLongs);
        console2.log("borrowingFactorPerSecondForShorts: ", state.borrowingFactorPerSecondForShorts);
        console2.log("fundingFactorPerSecond:            ", state.fundingFactorPerSecond);
        console2.log("fundingFactorPerSecondLongs:       ", state.fundingFactorPerSecondLongs);
        console2.log("fundingFactorPerSecondShorts:      ", state.fundingFactorPerSecondShorts);
        console2.log("maxOpenInterestUsdLong:            ", state.maxOpenInterestUsdLong);
        console2.log("maxOpenInterestUsdShort:           ", state.maxOpenInterestUsdShort);
    }

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
