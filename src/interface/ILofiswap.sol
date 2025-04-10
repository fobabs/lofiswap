// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title ILofiswap
/// @author FOBABS
/// @dev An interface of the Lofiswap contract
interface ILofiswap {
    /// @dev Emitted when an account adds liquidity to the pool.
    /// @param provider The address that added the liquidity.
    /// @param ethAmount The amount of ETH that was added to the pool.
    /// @param tokenAmount The amount of LofiToken that was minted.
    event LiquidityAdded(address indexed provider, uint256 ethAmount, uint256 tokenAmount);

    /// @dev Emitted when an account removes liquidity from the pool.
    /// @param provider The address that removed the liquidity.
    /// @param ethAmount The amount of ETH that was removed from the pool.
    /// @param tokenAmount The amount of LofiToken that was burned.
    event LiquidityRemoved(address indexed provider, uint256 ethAmount, uint256 tokenAmount);

    /// @dev Emitted when an account swaps ETH for LofiToken.
    /// @param user The address that performed the swap.
    /// @param ethIn The amount of ETH that was swapped.
    /// @param tokenOut The amount of LofiToken that was received.
    event SwapETHForToken(address indexed user, uint256 ethIn, uint256 tokenOut);

    /// @dev Emitted when an account swaps LofiToken for ETH.
    /// @param user The address that performed the swap.
    /// @param tokenIn The amount of LofiToken that was swapped.
    /// @param ethOut The amount of ETH that was received.
    event SwapTokenForETH(address indexed user, uint256 tokenIn, uint256 ethOut);

    /// @dev Adds liquidity to the pool.
    /// @param minETHOut The minimum amount of ETH that must be sent to the pool.
    /// @return ethAmount The amount of ETH that was sent to the pool.
    /// @return tokenAmount The amount of LofiToken that was minted.
    ///
    /// Emits a {LiquidityAdded} event.
    function addLiquidity(uint256 minETHOut) external returns (uint256 ethAmount, uint256 tokenAmount);

    /// @dev Removes liquidity from the pool.
    /// @param lofiAmount The amount of LofiToken to burn.
    /// @return ethAmount The amount of ETH that was removed from the pool.
    /// @return tokenAmount The amount of LofiToken that was burned.
    ///
    /// Emits a {LiquidityRemoved} event.
    function removeLiquidity(uint256 lofiAmount) external returns (uint256 ethAmount, uint256 tokenAmount);

    /// @dev Swaps ETH for LofiToken.
    /// @param minTokensOut The minimum amount of LofiToken that must be received.
    /// @return tokenAmount The amount of LofiToken that was received.
    ///
    /// Emits a {SwapETHForToken} event.
    function swapETHForToken(uint256 minTokensOut) external returns (uint256 tokenAmount);

    /// @dev Swaps LofiToken for ETH.
    /// @param tokenAmount The amount of LofiToken to swap.
    /// @param minETHOut The minimum amount of ETH that must be received.
    /// @return ethAmount The amount of ETH that was received.
    ///
    /// Emits a {SwapTokenForETH} event.
    function swapTokenForETH(uint256 tokenAmount, uint256 minETHOut) external returns (uint256 ethAmount);

    /// @dev Returns the reserves of the pool.
    /// @return ethReserve The amount of ETH in the pool.
    /// @return tokenReserve The amount of LofiToken in the pool.
    function getReserves() external view returns (uint256 ethReserve, uint256 tokenReserve);
}
