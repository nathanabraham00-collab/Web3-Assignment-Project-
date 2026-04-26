// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BankProject1.sol";

contract BankProject1SingleUserTest is Test {
    BankProject1 bank;
    address alice = makeAddr("alice");

    event AccountCreated(address indexed user, string name);
    event Deposit(address indexed user, uint256 amount, uint256 newBalance);
    event Withdrawal(address indexed user, uint256 amount, uint256 newBalance);

    function setUp() public {
        bank = new BankProject1();
        vm.deal(alice, 10 ether);
    }

    function test_FullFlow_SingleUser() public {
        // 1. Create account
        vm.prank(alice);
        vm.expectEmit(true, false, false, true);
        emit AccountCreated(alice, "Alice");
        bank.createAccount("Alice");
        assertTrue(bank.hasAccount(alice));

        // 2. Check initial balance = 0
        vm.prank(alice);
        assertEq(bank.getBalance(), 0);

        // 3. Deposit 3 ETH
        vm.prank(alice);
        vm.expectEmit(true, false, false, true);
        emit Deposit(alice, 3 ether, 3 ether);
        bank.deposit{value: 3 ether}();
        
        vm.prank(alice);
        assertEq(bank.getBalance(), 3 ether);
        assertEq(bank.totalDeposits(), 3 ether);

        // 4. Withdraw 1 ETH
        vm.prank(alice);
        vm.expectEmit(true, false, false, true);
        emit Withdrawal(alice, 1 ether, 2 ether);
        bank.withdraw(1 ether);

        vm.prank(alice);
        assertEq(bank.getBalance(), 2 ether);
        assertEq(bank.totalDeposits(), 2 ether);
    }

    function test_RevertPaths_SingleUser() public {
        // No account yet
        vm.prank(alice);
        vm.expectRevert("No account");
        bank.deposit{value: 1 ether}();

        vm.prank(alice);
        vm.expectRevert("No account");
        bank.withdraw(1 ether);

        vm.prank(alice);
        vm.expectRevert("No account");
        bank.getBalance();

        // Create account
        vm.prank(alice);
        bank.createAccount("Alice");

        // 0 deposit
        vm.prank(alice);
        vm.expectRevert("Send ETH to deposit");
        bank.deposit{value: 0}();

        // 0 withdraw
        vm.prank(alice);
        vm.expectRevert("Amount > 0");
        bank.withdraw(0);

        // Insufficient funds
        vm.prank(alice);
        vm.expectRevert("Insufficient funds");
        bank.withdraw(1 ether);

        // Duplicate account
        vm.prank(alice);
        vm.expectRevert("Account exists");
        bank.createAccount("Alice2");
    }

    function test_OwnerCanFreezeThisUser() public {
        vm.prank(alice);
        bank.createAccount("Alice");
        vm.prank(alice);
        bank.deposit{value: 1 ether}();

        // Owner freezes alice
        bank.setAccountStatus(alice, false);

        vm.prank(alice);
        vm.expectRevert("Account frozen");
        bank.getBalance();

        vm.prank(alice);
        vm.expectRevert("Account frozen");
        bank.deposit{value: 1 ether}();

        vm.prank(alice);
        vm.expectRevert("Account frozen");
        bank.withdraw(0.5 ether);

        // Owner unfreezes
        bank.setAccountStatus(alice, true);
        vm.prank(alice);
        assertEq(bank.getBalance(), 1 ether);
    }

    function testFuzz_SingleUserDepositWithdraw(uint96 amount) public {
        amount = uint96(bound(amount, 1, 10 ether));
        
        vm.startPrank(alice);
        bank.createAccount("Alice");
        bank.deposit{value: amount}();
        assertEq(bank.getBalance(), amount);
        
        bank.withdraw(amount);
        assertEq(bank.getBalance(), 0);
        vm.stopPrank();
    }
}
