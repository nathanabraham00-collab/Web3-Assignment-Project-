// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BankProject1 {
    address public owner;
    uint256 public totalDeposits;

    struct Account {
        string name;
        uint256 accountBalance;
        uint256 createdAt;
        bool isActive;
    }

    mapping(address => Account) private accounts;
    mapping(address => bool) public hasAccount;

    event AccountCreated(address indexed user, string name);
    event Deposit(address indexed user, uint256 amount, uint256 newBalance);
    event Withdrawal(address indexed user, uint256 amount, uint256 newBalance);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyActiveUser() {
        require(hasAccount[msg.sender], "No account");
        require(accounts[msg.sender].isActive, "Account frozen");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createAccount(string calldata _name) external {
        require(!hasAccount[msg.sender], "Account exists");
        require(bytes(_name).length > 0, "Name required");

        accounts[msg.sender] = Account({
            name: _name,
            accountBalance: 0,
            createdAt: block.timestamp,
            isActive: true
        });
        
        hasAccount[msg.sender] = true;
        emit AccountCreated(msg.sender, _name);
    }

    function deposit() external payable onlyActiveUser {
        require(msg.value > 0, "Send ETH to deposit");
        
        accounts[msg.sender].accountBalance += msg.value;
        totalDeposits += msg.value;
        
        emit Deposit(msg.sender, msg.value, accounts[msg.sender].accountBalance);
    }

    function withdraw(uint256 _amount) external onlyActiveUser {
        Account storage userAccount = accounts[msg.sender];
        require(_amount > 0, "Amount > 0");
        require(userAccount.accountBalance >= _amount, "Insufficient funds");

        userAccount.accountBalance -= _amount;
        totalDeposits -= _amount;

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(msg.sender, _amount, userAccount.accountBalance);
    }

    function getBalance() external view onlyActiveUser returns (uint256) {
        return accounts[msg.sender].accountBalance;
    }

    function setAccountStatus(address _user, bool _status) external onlyOwner {
        require(hasAccount[_user], "User not found");
        accounts[_user].isActive = _status;
    }

    receive() external payable {
        if (hasAccount[msg.sender] && accounts[msg.sender].isActive) {
            accounts[msg.sender].accountBalance += msg.value;
            totalDeposits += msg.value;
            emit Deposit(msg.sender, msg.value, accounts[msg.sender].accountBalance);
        }
    }



