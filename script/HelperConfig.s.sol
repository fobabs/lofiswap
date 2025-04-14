// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract HelperConfig is Script {
    error HelperConfig__InvalidChainId(uint256 chainId);

    address public erc20TokenAddress;

    // Chain Ids
    uint256 public constant MAINNET_CHAIN_ID = 1;
    uint256 public constant SEPOLIA_CHAIN_ID = 11_155_111;
    uint256 public constant ANVIL_CHAIN_ID = 31_337;

    // Token addresses
    address public constant USDC_TOKEN_ADDRESS = 0x0000000000000000000000000000000000000000;
    address public constant SEPOLIA_USDC_TOKEN_ADDRESS = 0x0000000000000000000000000000000000000000;

    constructor() {
        if (block.chainid == ANVIL_CHAIN_ID) {
            erc20TokenAddress = getOrCreateAnvilEthTokenAddress();
        } else if (block.chainid == SEPOLIA_CHAIN_ID) {
            erc20TokenAddress = getSepoliaEthTokenAddress();
        } else if (block.chainid == MAINNET_CHAIN_ID) {
            erc20TokenAddress = getEthTokenAddress();
        } else {
            revert HelperConfig__InvalidChainId(block.chainid);
        }
    }

    function getEthTokenAddress() public pure returns (address) {
        return USDC_TOKEN_ADDRESS;
    }

    function getSepoliaEthTokenAddress() public pure returns (address) {
        return SEPOLIA_USDC_TOKEN_ADDRESS;
    }

    function getOrCreateAnvilEthTokenAddress() public returns (address) {
        if (erc20TokenAddress != address(0)) {
            return erc20TokenAddress;
        }

        vm.startBroadcast();
        ERC20Mock usdcToken = new ERC20Mock();
        vm.stopBroadcast();

        return address(usdcToken);
    }
}
