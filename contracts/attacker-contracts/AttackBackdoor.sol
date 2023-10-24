// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../backdoor/WalletRegistry.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";
import "../DamnValuableToken.sol";

import "hardhat/console.sol";

contract AttackBackdoor {
    DamnValuableToken token;
    WalletRegistry registry;
    GnosisSafe wallet;
    IProxyCreationCallback proxyCreation;

    constructor(
        address _token,
        address _registry,
        address _proxyCreation,
        address _wallet
    ) {
        token = DamnValuableToken(_token);
        registry = WalletRegistry(_registry);
        wallet = GnosisSafe(payable(_wallet));
        proxyCreation = IProxyCreationCallback(_proxyCreation);
    }

    function attack() public {
        console.log(address(wallet));
    }
}
