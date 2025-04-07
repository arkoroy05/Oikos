// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Escrow} from "../src/Escrow.sol";
import {RealEstate} from "../src/RealEstate.sol";


contract CounterScript is Script {
   Escrow public escrow;
   RealEstate public realEstate;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        realEstate = new RealEstate();
        escrow = new Escrow(address(realEstate), msg.sender, msg.sender, msg.sender);

        vm.stopBroadcast();
    }
}
