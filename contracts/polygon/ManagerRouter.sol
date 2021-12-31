// This contract is under development and has not yet been deployed on mainnet

pragma solidity ^0.8.0;

import './interfaces/IERC20.sol';
import './interfaces/IManagerRouter.sol';
import './utils/Ownable.sol';

contract ManagerRouter is IManagerRouter, Ownable {
  struct Game {
    string name; // readable game name for dapp
    string icon; // link to the game icon for dapp
    bool isActive;
  }

  struct Router {
    string name; // readable server name for dapp
    string icon; // link to the server icon for dapp. If not, then you need to use the game icon 
    address adminAddress;
    address contractAddress;
    uint8 gameId;
    string host;
    bool isActive;
    uint32 commission;
  }
  
  Game[] public games;
  Router[] public routers;

  address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
  IERC20 private immutable _token;
  
  constructor(IERC20 token) {
    _token = token;
  }
  
  function addGame(string calldata name, string calldata icon, bool isActive) external onlyOwner {
    games.push(
      Game(name, icon, isActive)
    );
  }
  
  function setGameName(uint32 gameId, string calldata name) external onlyOwner { 
    games[gameId].name = name;
  }
  
  function setGameIcon(uint32 gameId, string calldata icon) external onlyOwner {
    games[gameId].icon = icon;
  }

  function setGameActive(uint32 gameId, bool value) external onlyOwner {
    games[gameId].isActive = value;
  }

  function addRouter(uint8 gameId, string calldata name, string calldata icon, address adminAddress, address contractAddress, string calldata host, bool active, uint32 commission) external onlyOwner {
      routers.push(
          Router(
              name,
              icon,
              adminAddress,
              contractAddress,
              gameId,
              host,
              active,
              commission
          )
      );
  }

  function setRouterName(uint32 routerId, string calldata name) external onlyOwner { 
    routers[routerId].name = name;
  }

  function setRouterIcon(uint32 routerId, string calldata icon) external onlyOwner { 
    routers[routerId].icon = icon;
  }

  function setRouterHost(uint32 routerId, string calldata host) external onlyOwner { 
    routers[routerId].host = host;
  }

  function setRouterAdminAddress(uint32 routerId, address addr) external onlyOwner { 
    routers[routerId].adminAddress = addr;
  }

  function setRouterContractAddress(uint32 routerId, address addr) external onlyOwner { 
    routers[routerId].contractAddress = addr;
  }

  function setRouterActive(uint32 routerId, bool value) external onlyOwner {
    routers[routerId].isActive = value;
  }

  function setRouterCommission(uint32 routerId, uint32 value) external onlyOwner {
    routers[routerId].commission = value;
  }

  function routerNumber() external view returns (uint) {
      return routers.length;
  }

  function validate(address contractAddress) external override view returns (bool) {
    bool result = false;
    for(uint i = 0; i < routers.length; i++) {
        if(routers[i].contractAddress == contractAddress && routers[i].isActive == true && games[routers[i].gameId].isActive == true) {
            result = true;
            break;
        }
    }
    return result;
  }

  
  function getCommission(address contractAddress) external override view returns (uint32) {
        uint32 result = 0;
        for(uint i = 0; i < routers.length; i++) {
            if(routers[i].contractAddress == contractAddress) {
                result = routers[i].commission;
                break;
            }
        }
        return result;
  }
}
