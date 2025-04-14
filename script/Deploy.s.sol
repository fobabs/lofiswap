// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {Lofiswap} from "../src/Lofiswap.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployScript is Script {
    function run() external returns (Lofiswap) {
        HelperConfig helperConfig = new HelperConfig();
        address tokenAddress = helperConfig.erc20TokenAddress();

        vm.startBroadcast();
        Lofiswap lofiswap = new Lofiswap(tokenAddress);
        vm.stopBroadcast();
        return lofiswap;
    }
}
