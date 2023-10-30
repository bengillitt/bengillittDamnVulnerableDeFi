// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";

import "hardhat/console.sol";

interface IPuppetV3Pool {
    function calculateDepositOfWETHRequired(
        uint256 amount
    ) external returns (uint256);

    function borrow(uint256 borrowAmount) external;
}

contract AttackPuppetV3 {
    IPuppetV3Pool pool;
    DamnValuableToken token;

    constructor(address _pool, address _token) {
        pool = IPuppetV3Pool(_pool);
        token = DamnValuableToken(_token);
    }

    function attack(uint256 amount) public payable {
        token.transferFrom(msg.sender, address(this), 110 ether);
        uint256 wethAmount = pool.calculateDepositOfWETHRequired(amount);
        console.log(wethAmount / 1 ether);
        console.log(token.balanceOf(address(this)) / 1 ether);
    }
}
