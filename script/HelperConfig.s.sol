//SPDX-License-Identifier: MIT

//what we achieve with this:
//1. deploy mocks contract when we are on a local anvil chain to avoid running up bills in alchemy
//2. keep track of address across different chains
//this contract is so we don't have to hard code the address in test/script each time we
//need to test for an address and our test will work no matter what chain I'm on

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //if we are on a local anvil, we deploy mocks
    //otherwise, grab the existing address from the live network
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
        //ETH/USD price feed address
        //Creating a struct incase I want more data from the sepolia chain,
        //I could just include it to my struct
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSapoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSapoliaEthConfig() public pure returns (NetworkConfig memory) {
        //this is going to return a comfig for anything we need in sapolia or any chain
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        //1. deploy the mocks
        //2. return the mock address
        vm.startBroadcast();
        //in order to deploy our pricefeed, we'll need a pricefeed contract
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e18);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
