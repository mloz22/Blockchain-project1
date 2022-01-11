//Deposit & Withdraw Funds
//Manage Orders - Make or Cancel
//Handle Trades - Charge fees

pragma solidity ^0.5.0;

contract Exchange {
	//Variables
	address public feeAccount; //the account which receives exchange fees
	
	//Set the fee account
	constructor(address _feeAccount) public {
		feeAccount = _feeAccount;
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

