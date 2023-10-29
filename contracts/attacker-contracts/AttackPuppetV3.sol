// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../puppet-v3/PuppetV3Pool.sol";

import "hardhat/console.sol";

contract AttackPuppetV3 {
    PuppetV3Pool pool;

    constructor(address _pool) {
        pool = PuppetV3Pool(_pool);
    }

    function attack(uint256 amount) public {
        uint256 wethAmount = pool.calculateDepositOfWETHRequired(amount);
        console.log(wethAmount);
    }
}
