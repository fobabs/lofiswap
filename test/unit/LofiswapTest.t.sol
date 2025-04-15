// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {DeployScript, HelperConfig} from "../../script/Deploy.s.sol";
import {Lofiswap} from "../../src/Lofiswap.sol";
import {LofiToken} from "../../src/LofiToken.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract LofiswapTest is Test {
    Lofiswap public lofiswap;
    HelperConfig public helperConfig;
    LofiToken public lofiToken;

    ERC20Mock public erc20Token;

    address public ALICE = makeAddr("alice");
    address public BOB = makeAddr("bob");

    uint256 public constant USER_STARTING_BALANCE = 100 ether;
    uint256 public constant INITIAL_TOKEN_AMOUNT = 1_000 ether;

    function setUp() public {
        DeployScript deployer = new DeployScript();
        (lofiswap, helperConfig) = deployer.run();

        address tokenAddress = helperConfig.erc20TokenAddress();
        erc20Token = ERC20Mock(tokenAddress);
        erc20Token.mint(address(lofiswap), INITIAL_TOKEN_AMOUNT);

        lofiToken = lofiswap.i_lofiToken();

        // Funds users with ETH
        vm.deal(ALICE, USER_STARTING_BALANCE);
        vm.deal(BOB, USER_STARTING_BALANCE);

        // Fund users with USDC Tokens
        erc20Token.mint(ALICE, INITIAL_TOKEN_AMOUNT);
        erc20Token.mint(BOB, INITIAL_TOKEN_AMOUNT);
    }

    function testConstructorInvalidTokenAddress() public {
        vm.expectRevert(Lofiswap.Lofiswap__InvalidTokenAddress.selector);
        new Lofiswap(address(0));
    }
}
