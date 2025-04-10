// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {LofiToken} from "./LofiToken.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


/// @title Lofiswap
/// @author FOBABS
/// @notice A decentralized exchange (DEX) that allows users to swap between ETH and LofiToken.
contract Lofiswap is Ownable {
    using SafeERC20 for IERC20;

    ////////////////////////*/
    //       Errors
    ////////////////////////*/
    error Lofiswap__InvalidTokenAddress();
    error Lofiswap__MustSendETH();
    error Lofiswap__MustSendTokens();
    error Lofiswap__InsufficientTokenAmount();
    error Lofiswap__ETHTransferFailed();

    ////////////////////////////////////*/
    //         State Variables
    ////////////////////////////////////*/
    // Token contract instance
    IERC20 private immutable i_token;
    // LofiToken contract instance
    LofiToken private immutable i_lofiToken;

    // Pool reserves
    uint256 private s_ethReserve;
    uint256 private s_tokenReserve;

    // Pool fees
    uint256 private constant FEE_NUMERATOR = 1;
    uint256 private constant FEE_DENOMINATOR = 100;

    //////////////////////////*/
    //         Events
    //////////////////////////*/
    event LiquidityAdded(address indexed provider, uint256 ethAmount, uint256 tokenAmount);
    event LiquidityRemoved(address indexed provider, uint256 ethAmount, uint256 tokenAmount);
    event SwapETHForToken(address indexed user, uint256 ethIn, uint256 tokenOut);
    event SwapTokenForETH(address indexed user, uint256 tokenIn, uint256 ethOut);
    event ETHFeesWithdrawn(address indexed user, uint256 ethFees);
    event TokenFeesWithdrawn(address indexed user, uint256 tokenFees);

    /// @dev Initializes the Lofiswap contract
    /// @param _token Address of the token contract
    constructor(address _token) Ownable(msg.sender) {
        if (_token == address(0)) revert Lofiswap__InvalidTokenAddress();
        i_token = IERC20(_token);
        i_lofiToken = new LofiToken();
    }

    ////////////////////////////////////*/
    //       External Functions
    ////////////////////////////////////*/
    /// @notice Adds liquidity to the pool
    /// @param _tokenAmount Amount of tokens to add
    /// @return The amount of LofiToken tokens minted
    function addLiquidity(uint256 _tokenAmount) external payable returns (uint256) {
        // Check if the user has enough ETH
        if (msg.value == 0) revert Lofiswap__MustSendETH();
        if (_tokenAmount <= 0) revert Lofiswap__MustSendTokens();

        uint256 ethAmount = msg.value;
        uint256 lofiAmount;

        if (s_ethReserve == 0 && s_tokenReserve == 0) {
            // Initial liquidity
            s_ethReserve = ethAmount;
            s_tokenReserve = _tokenAmount;
            lofiAmount = ethAmount; // Initial LofiToken tokens = ETH amount
        } else {
            // Maintain ratio
            uint256 tokenAmountRequired = (ethAmount * s_tokenReserve) / s_ethReserve;
            if (_tokenAmount < tokenAmountRequired) revert Lofiswap__InsufficientTokenAmount();

            uint256 totalSupply = i_lofiToken.totalSupply();
            lofiAmount = (ethAmount * totalSupply) / s_ethReserve;

            if (_tokenAmount > tokenAmountRequired) {
                _tokenAmount = tokenAmountRequired;
            }
        }

        s_ethReserve += ethAmount;
        s_tokenReserve += _tokenAmount;

        // Ensure the caller calls `approve()`
        i_token.safeTransferFrom(msg.sender, address(this), _tokenAmount);

        i_lofiToken.mint(msg.sender, lofiAmount);

        emit LiquidityAdded(msg.sender, ethAmount, _tokenAmount);
        return lofiAmount;
    }

    /// @notice Removes liquidity from the pool
    /// @param _lofiAmount Amount of LofiToken tokens to remove
    /// @return ethAmount 
    /// @return tokenAmount 
    function removeLiquidity(uint256 _lofiAmount) 
        external   
        returns (uint256 ethAmount, uint256 tokenAmount) 
    {
        if (_lofiAmount == 0) revert Lofiswap__MustSendTokens();
        if (_lofiAmount > i_lofiToken.balanceOf(msg.sender)) 
            revert Lofiswap__InsufficientTokenAmount();

        uint256 totalSupply = i_lofiToken.totalSupply();
        ethAmount = (_lofiAmount * s_ethReserve) / totalSupply;
        tokenAmount = (_lofiAmount * s_tokenReserve) / totalSupply;

        s_ethReserve -= ethAmount;
        s_tokenReserve -= tokenAmount;

        // Ensure the caller calls `approve()`
        i_lofiToken.burnFrom(msg.sender, _lofiAmount);

        // Send Tokens and ETH to caller
        i_token.safeTransfer(msg.sender, tokenAmount);

        (bool sent, ) = payable(msg.sender).call{value: ethAmount}("");
        if (!sent) revert Lofiswap__ETHTransferFailed();

        emit LiquidityRemoved(msg.sender, ethAmount, tokenAmount);
        return (ethAmount, tokenAmount);
    }

    /// @notice Swaps ETH for LofiToken
    /// @param _minTokensOut Minimum amount of tokens to receive
    /// @return tokenAmount
    function swapETHForToken(uint256 _minTokensOut) 
        external 
        payable 
        returns (uint256 tokenAmount) 
    {
        if (msg.value == 0) revert Lofiswap__MustSendETH();

        uint256 ethIn = msg.value;

        tokenAmount = getOutputAmount(ethIn, s_ethReserve, s_tokenReserve);
        if (tokenAmount < _minTokensOut) revert Lofiswap__InsufficientTokenAmount();

        s_ethReserve += ethIn;
        s_tokenReserve -= tokenAmount;

        // Send tokens to the caller
        i_token.safeTransfer(msg.sender, tokenAmount);

        emit SwapETHForToken(msg.sender, ethIn, tokenAmount);
        return tokenAmount;
    }

    /// @notice Swaps LofiToken for ETH
    /// @param _tokenAmount Amount of tokens to swap
    /// @param _minETHOut Minimum amount of ETH to receive
    /// @return ethAmount
    function swapTokenForETH(
        uint256 _tokenAmount, 
        uint256 _minETHOut
    ) external returns (uint256 ethAmount) {
        if (_tokenAmount == 0) revert Lofiswap__MustSendTokens();

        ethAmount = getOutputAmount(_tokenAmount, s_tokenReserve, s_ethReserve);
        if (ethAmount < _minETHOut) revert Lofiswap__InsufficientTokenAmount();

        s_tokenReserve += _tokenAmount;
        s_ethReserve -= ethAmount;

        // Pull out tokens from the caller
        i_token.safeTransferFrom(msg.sender, address(this), _tokenAmount);

        // Send ETH to the caller
        (bool sent, ) = payable(msg.sender).call{value: ethAmount}("");
        if (!sent) revert Lofiswap__ETHTransferFailed();

        emit SwapTokenForETH(msg.sender, _tokenAmount, ethAmount);
        return ethAmount;
    }

    function withdrawETHFees() external onlyOwner {
        uint256 ethFees = address(this).balance;
        (bool sent, ) = payable(owner()).call{value: ethFees}("");
        if (!sent) revert Lofiswap__ETHTransferFailed();

        emit ETHFeesWithdrawn(owner(), ethFees);
    }

    function withdrawTokenFees() external onlyOwner {
        uint256 tokenFees = i_lofiToken.balanceOf(address(this));
        i_token.safeTransfer(owner(), tokenFees);

        emit TokenFeesWithdrawn(owner(), tokenFees);
    }

    //////////////////////////////////////////*/
    //         Private Pure Function
    //////////////////////////////////////////*/
    /// @dev Calculate output amount using constant product formula (x * y = k)
    /// @param inputAmount The amount of the input token to be swapped.
    /// @param inputReserve The reserve amount of the input token.
    /// @param outputReserve The reserve amount of the output token.
    /// @return The calculated output amount of the output token.
    function getOutputAmount(
        uint256 inputAmount, 
        uint256 inputReserve, 
        uint256 outputReserve
    ) private pure returns (uint256) {
        uint256 inputAmountWithFee = inputAmount * (FEE_DENOMINATOR - FEE_NUMERATOR);
        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * FEE_DENOMINATOR) + inputAmountWithFee;
        return numerator / denominator;
    }

    //////////////////////////////////////////*/
    //         External View Function
    //////////////////////////////////////////*/
    /// @notice Get pool reserves
    /// @return _s_ethReserve 
    /// @return _s_tokenReserve 
    function getReserves() 
        external 
        view 
        returns (uint256 _s_ethReserve, uint256 _s_tokenReserve) 
    {
        return (s_ethReserve, s_tokenReserve);
    }
}
