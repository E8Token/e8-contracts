// This contract is under development and has not yet been deployed on mainnet

pragma solidity ^0.8.0;

import './interfaces/IERC20.sol';
import './interfaces/IRouter.sol';
import './interfaces/IManagerRouter.sol';
import './utils/Ownable.sol';

contract CustomerRouter is IRouter, Ownable {
  
  address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
  IERC20 private immutable _token;
  IManagerRouter private _managerRouter;
  address public managerRouterAddress;
  uint32 public depositFeeAdmin = 0;
  uint32 public depositBurn = 0;
  uint32 public depositFee = 0;
  uint32 public withdrawFeeAdmin = 0;
  uint32 public withdrawBurn = 0;
  uint32 public withdrawFee = 0;
  
  constructor(IERC20 token, address managerRouter) {
    require(address(0) != managerRouter, "Bad manager router");
    _token = token;
    managerRouterAddress = managerRouter;
    _managerRouter = IManagerRouter(managerRouter);
  }
  
  function deposit(uint32 serverId, string calldata nickname, uint amount) external {
    require(_managerRouter.validate(address(this)), "Server or Router is not valid!");
    require(amount > 0, "Amount must be greater than 0");
    
    uint managerFeeAmount = _getPercentage(amount, _managerRouter.getCommission(address(this)));
    uint adminFeeAmount = _getPercentage(amount, depositFeeAdmin);
    uint burnAmount = _getPercentage(amount, depositBurn);
    uint feeAmount = _getPercentage(amount, depositFee);
    
    uint depositAmount = amount - adminFeeAmount - burnAmount - feeAmount - managerFeeAmount;

    _token.transferFrom(msg.sender, address(this), amount);

    if (burnAmount > 0) {
      _token.transfer(DEAD, burnAmount);
    }

    if (adminFeeAmount > 0) {
      _token.transfer(_owner, adminFeeAmount);
    }

    if (managerFeeAmount > 0) {
      _token.transfer(managerRouterAddress, managerFeeAmount);
    }

    emit Deposit(serverId, nickname, msg.sender, depositAmount);
  }
  
  /*
    At the moment, the withdrawal is made on behalf of the owner,
    because it is necessary to ensure that the withdrawal is made
    directly by the owner of the game account, for this,
    certain checks are made on the centralized server
    
    In future versions of the router this will be rewritten
    and there will be no centralized server 
  */
  function withdraw(uint32 serverId, address recipient, string calldata nickname, uint amount) external onlyOwner {
    require(_managerRouter.validate(address(this)), "Server or Router is not valid!");
    require(amount > 0, "Amount must be greater than 0");

    uint managerFeeAmount = _getPercentage(amount, _managerRouter.getCommission(address(this)));
    uint adminFeeAmount = _getPercentage(amount, withdrawFeeAdmin);
    uint burnAmount = _getPercentage(amount, withdrawBurn);
    uint feeAmount = _getPercentage(amount, withdrawFee);
    
    uint withdrawAmount = amount - adminFeeAmount - burnAmount - feeAmount - managerFeeAmount;
    
    _token.transfer(recipient, withdrawAmount);
    
    if (burnAmount > 0) {
      _token.transfer(DEAD, burnAmount);
    }
    
    if (adminFeeAmount > 0) {
      _token.transfer(_owner, adminFeeAmount);
    }
    
    if (managerFeeAmount > 0) {
      _token.transfer(managerRouterAddress, managerFeeAmount);
    }
      
    emit Withdraw(serverId, nickname, recipient, amount);
  }

  function setDepositFees(uint32 depositFeeAdmin, uint32 depositBurn, uint32 depositFee) external view onlyOwner {
    require(
      depositFeeAdmin <= 10000 &&
      depositBurn <= 10000 &&
      depositFee <= 10000
    );

    depositFeeAdmin = depositFeeAdmin;
    depositBurn = depositBurn;
    depositFee = depositFee;
  }

  function setWithdrawFees(uint32 withdrawFeeAdmin, uint32 withdrawBurn, uint32 withdrawFee) external view onlyOwner {
    require(
      withdrawFeeAdmin <= 10000 &&
      withdrawBurn <= 10000 &&
      withdrawFee <= 10000
    );
    
    withdrawFeeAdmin = withdrawFeeAdmin;
    withdrawBurn = withdrawBurn;
    withdrawFee = withdrawFee;
  }
  
  function _getPercentage(uint number, uint32 percent) internal pure returns (uint) {
    return (number * percent) / 10000;
  }
}
