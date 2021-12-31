interface IRouter {
  event Deposit(uint32 serverId, string username, address indexed sender, uint value);
  event Withdraw(uint32 serverId, string username, address indexed recipient, uint value);
}