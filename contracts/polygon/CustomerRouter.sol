// This contract is under development and has not yet been deployed on mainnet

pragma solidity ^0.8.0;

import './interfaces/IERC20.sol';
import './interfaces/IManagerRouter.sol';
import './utils/Ownable.sol';

interface IRouter {
  event Deposit(uint32 serverId, string username, address indexed sender, uint value);
  event Withdraw(uint32 serverId, string username, address indexed recipient, uint value);
}

contract Router is IRouter, Ownable {
  
  address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
  IERC20 private immutable _token;
  IManagerRouter private _managerRouter;
  address public managerRouterAddress;
  uint32 depositFeeAdmin = 0;
  uint32 depositBurn = 0;
  uint32 depositFee = 0;
  uint32 withdrawFeeAdmin = 0;
  uint32 withdrawBurn = 0;
  uint32 withdrawFee = 0;
  
  constructor(IERC20 token, address managerRouter) {
    _token = token;
    managerRouterAddress = managerRouter;
    _managerRouter = IManagerRouter(managerRouter);
  }
  
  function deposit(uint32 serverId, string calldata nickname, uint amount) external {
    require(_managerRouter.validate(address(this)) == true, "Server or Router is not valid!");
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
    require(_managerRouter.validate(address(this)) == true, "Server or Router is not valid!");
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
  
  function _getPercentage(uint number, uint32 percent) internal pure returns (uint) {
    return (number * percent) / 10000;
  }
}
