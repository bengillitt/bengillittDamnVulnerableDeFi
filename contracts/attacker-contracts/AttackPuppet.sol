// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract AttackPuppet {
    address S_puppetPool;
    address S_token;

    constructor(address _puppetPool, address _token) {
        S_puppetPool = _puppetPool;
        S_token = _token;
    }
}
