//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        //fundMe = new FundMe();//0x694AA1769357215DE4FAC081bf1f309aDC325306
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUsdIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        //assertEq(fundMe.i_owner(), msg.sender); this test fails because in our setUp function,
        //the FundMeTest is the contract that deployed our FundMe address and would be the owner and not us calling the FundMeTst
        //in this function, my msg.sender is whomever is calling the FundMeTest
        //I should be checking to see if FundMeTest is owner and not us(msg.sender)
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); //special keyword used to test for reverts
        fundMe.fund(); //this line fails because no value was sent in()
        //which is the test we want
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //the next tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        vm.prank(USER); //funder/USER attempts to withdraw but reverts cause USER is not owner
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        //Arrange:check our balance before calling withdraw so we can compare to our balance after
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }
}
