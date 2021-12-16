pragma solidity >=0.5.0;

interface IManagerRouter {
  function validate(address contractAddress)  external returns (bool);
  function getCommission(address contractAddress) external returns (uint32);
}