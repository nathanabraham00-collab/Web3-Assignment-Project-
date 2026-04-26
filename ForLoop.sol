// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BankProject1 {
    address public owner;

    // Account struct from Task 1
    struct Account {
        string name;
        uint256 accountBalance;
        address accountAddress;
        uint256 createdAt;
        bool isActive;
    }

    // Dynamic array of Account structs
    Account[] public accounts;

    // Mapping for O(1) lookup: address => index in array + 1
    // 0 means no account, so we store index + 1
    mapping(address => uint256) private accountIndex;

    // For batch creation input
    struct AccountInput {
        string name;
        address accountAddress;
    }

    event AccountCreated(address indexed user, string name, uint256 index);
    event BatchAccountsCreated(uint256 count);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Create a single account and push to array
     */
    function createAccount(string calldata _name) external {
        require(accountIndex[msg.sender] == 0, "Account exists");
        require(bytes(_name).length > 0, "Name required");

        accounts.push(Account({
            name: _name,
            accountBalance: 0,
            accountAddress: msg.sender,
            createdAt: block.timestamp,
            isActive: true
        }));

        // Store index + 1 so 0 can mean "not found"
        accountIndex[msg.sender] = accounts.length;
        emit AccountCreated(msg.sender, _name, accounts.length - 1);
    }

    /**
     * @dev Batch create multiple accounts using for loop
     * @param _newAccounts Array of AccountInput structs
     */
    function batchCreateAccounts(AccountInput[] calldata _newAccounts) external onlyOwner {
        uint256 len = _newAccounts.length;
        require(len > 0, "Empty array");

        for (uint256 i = 0; i < len; i++) {
            address userAddr = _newAccounts[i].accountAddress;
            string calldata userName = _newAccounts[i].name;

            // Skip if account already exists or invalid data
            if (accountIndex[userAddr]!= 0 || bytes(userName).length == 0) {
                continue;
            }

            accounts.push(Account({
                name: userName,
                accountBalance: 0,
                accountAddress: userAddr,
                createdAt: block.timestamp,
                isActive: true
            }));

            accountIndex[userAddr] = accounts.length;
            emit AccountCreated(userAddr, userName, accounts.length - 1);
        }

        emit BatchAccountsCreated(len);
    }

    /**
     * @dev Get total number of accounts in array
     */
    function getAccountsCount() external view returns (uint256) {
        return accounts.length;
    }

    /**
     * @dev Get account by index in array
     */
    function getAccountByIndex(uint256 _index) external view returns (Account memory) {
        require(_index < accounts.length, "Index out of bounds");
        return accounts[_index];
    }

    /**
     * @dev Get account by address using mapping
     */
    function getAccountByAddress(address _user) external view returns (Account memory) {
        uint256 idx = accountIndex[_user];
        require(idx!= 0, "No account");
        return accounts[idx - 1]; // subtract 1 because we stored index + 1
    }

    /**
     * @dev Get all accounts - careful with gas on large arrays
     */
    function getAllAccounts() external view returns (Account[] memory) {
        return accounts;
    }
}
