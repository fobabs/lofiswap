// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract LofiToken is ERC20Burnable {
    string private constant TOKEN_NAME = "LofiToken";
    string private constant TOKEN_SYMBOL = "LOFI";

    constructor() ERC20(TOKEN_NAME, TOKEN_SYMBOL) {}

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}
