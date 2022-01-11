//Deposit & Withdraw Funds
//Manage Orders - Make or Cancel
//Handle Trades - Charge fees

pragma solidity ^0.5.0;

contract Exchange {
	//Variables
	address public feeAccount; //the account which receives exchange fees
	uint256 public feePercent; //fee percentage
	
	//Set the fee account and percent
	constructor(address _feeAccount, uint256 _feePercent) public {
		feeAccount = _feeAccount;
		feePercent = _feePercent;
	}
}

// TODO:
// [ ] Set the fee account
// [ ] Deposit Ether
// [ ] Withdraw Ether
// [ ] Deposit tokens
// [ ] Withdraw tokens
// [ ] Check balances
// [ ] Make order
// [ ] Cancel order
// [ ] Fill order 
// [ ] Charge fees

