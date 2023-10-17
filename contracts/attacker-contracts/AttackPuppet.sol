// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract AttackPuppet {
    address S_puppetPool;

    constructor(address _puppetPool) {
        S_puppetPool = _puppetPool;
    }
}
