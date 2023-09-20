//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether; //value i want to send when fund function is called

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        console.log("funded FundMe with %s", SEND_VALUE);
        vm.stopBroadcast();
    }

    //this will be script for funding the fundMe contract
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        //calling fund on the most recently deployed address
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    //this will be script for withdrawing from fundMe contract
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    //this will be script for funding the fundMe contract
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        //calling fund on the most recently deployed address
        withdrawFundMe(mostRecentlyDeployed);
    }
}
