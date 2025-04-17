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

    uint256 public constant TOKEN_TOTAL_SUPPLY = 100_000_000 ether;

    uint256 public constant USER_STARTING_BALANCE = 100 ether;
    uint256 public constant USER_TOKEN_AMOUNT = 1_000 ether;

    uint256 public constant INITIAL_ETH_AMOUNT = 20 ether;
    uint256 public constant INITIAL_TOKEN_AMOUNT = 100 ether;

    function setUp() public {
        DeployScript deployer = new DeployScript();
        (lofiswap, helperConfig) = deployer.run();

        address tokenAddress = helperConfig.erc20TokenAddress();
        erc20Token = ERC20Mock(tokenAddress);
        erc20Token.mint(address(lofiswap), TOKEN_TOTAL_SUPPLY);

        lofiToken = lofiswap.i_lofiToken();

        // Funds users with ETH
        vm.deal(ALICE, USER_STARTING_BALANCE);
        vm.deal(BOB, USER_STARTING_BALANCE);

        // Fund users with USDC Tokens
        vm.startPrank(address(lofiswap));
        erc20Token.transfer(ALICE, USER_TOKEN_AMOUNT);
        erc20Token.transfer(BOB, USER_TOKEN_AMOUNT);
        vm.stopPrank();
    }

    function testConstructorInvalidTokenAddress() public {
        vm.expectRevert(Lofiswap.Lofiswap__InvalidTokenAddress.selector);
        new Lofiswap(address(0));
    }

    function testAddInitialLiquidity() public {
        // Arrange
        vm.startPrank(ALICE);
        // Act
        erc20Token.approve(address(lofiswap), INITIAL_TOKEN_AMOUNT);
        uint256 lofiAmount = lofiswap.addLiquidity{value: INITIAL_ETH_AMOUNT}(INITIAL_TOKEN_AMOUNT);
        vm.stopPrank();

        (uint256 ethReserve, uint256 tokenReserve) = lofiswap.getReserves();
        // Assert
        assertEq(ethReserve, INITIAL_ETH_AMOUNT);
        assertEq(tokenReserve, INITIAL_TOKEN_AMOUNT);
        assertEq(lofiAmount, INITIAL_ETH_AMOUNT);
        assertEq(lofiToken.balanceOf(ALICE), INITIAL_ETH_AMOUNT);
    }

    function testAddLiquidityZeroETH() public {
        // Arrange
        vm.startPrank(ALICE);
        // Act/Assert
        erc20Token.approve(address(lofiswap), INITIAL_TOKEN_AMOUNT);
        vm.expectRevert(Lofiswap.Lofiswap__MustSendETH.selector);
        lofiswap.addLiquidity{value: 0}(INITIAL_TOKEN_AMOUNT);
        vm.stopPrank();
    }

    function testAddLiquidityZeroTokens() public {
        // Arrange
        vm.startPrank(ALICE);
        // Act/Assert
        vm.expectRevert(Lofiswap.Lofiswap__MustSendTokens.selector);
        lofiswap.addLiquidity{value: INITIAL_ETH_AMOUNT}(0);
        vm.stopPrank();
    }

    function testAddLiquidityMaintainRatio() public {
        // Arrange
        vm.startPrank(ALICE);
        // Act
        erc20Token.approve(address(lofiswap), INITIAL_TOKEN_AMOUNT);
        lofiswap.addLiquidity{value: INITIAL_ETH_AMOUNT}(INITIAL_TOKEN_AMOUNT);
        vm.stopPrank();

        // Add more liquidity
        uint256 additionalEth = 8 ether;
        uint256 expectedToken = (additionalEth * INITIAL_TOKEN_AMOUNT) / INITIAL_ETH_AMOUNT;

        vm.startPrank(BOB);
        erc20Token.approve(address(lofiswap), expectedToken);
        uint256 lofiAmount = lofiswap.addLiquidity{value: additionalEth}(expectedToken);
        (uint256 ethReserve, uint256 tokenReserve) = lofiswap.getReserves();
        vm.stopPrank();
        uint256 totalSupply = lofiToken.totalSupply();
        uint256 expectedLofiAmount = (additionalEth * totalSupply) / ethReserve;
        // Assert
        assertEq(ethReserve, INITIAL_ETH_AMOUNT + additionalEth);
        assertEq(tokenReserve, INITIAL_TOKEN_AMOUNT + expectedToken);
        assertEq(lofiAmount, expectedLofiAmount);
    }
}
