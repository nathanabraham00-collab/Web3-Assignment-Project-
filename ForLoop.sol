// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BankProject1 {
    address public owner;
    uint256 public totalDeposits;
//Account struct from Task 1
    struct Account {
        string name;
        uint256 accountBalance;
        uint256 createdAt;
        bool isActive;
    }
