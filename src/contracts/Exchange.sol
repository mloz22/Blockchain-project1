pragma solidity ^0.5.0;

import "./Token.sol";

//Deposit & Withdraw Funds
//Manage Orders - Make or Cancel
//Handle Trades - Charge fees


// TODO:
// [X] Set the fee account
// [ ] Deposit Ether
// [ ] Withdraw Ether
// [ ] Deposit tokens
// [ ] Withdraw tokens
// [ ] Check balances
// [ ] Make order
// [ ] Cancel order
// [ ] Fill order 
// [ ] Charge fees






contract Exchange {
	//Variables
	address public feeAccount; //the account which receives exchange fees
	uint256 public feePercent; //fee percentage
	
	//Set the fee account and percent
	constructor(address _feeAccount, uint256 _feePercent) public {
		feeAccount = _feeAccount;
		feePercent = _feePercent;
	}

	function depositToken(address _token, uint256 _amount) public {
		// Which token? --any ERC20, paramenter of _token

		// How much of that token? parameter of _amount

		// Send toeksn to this contract
		Token(_token).transferFrom(msg.sender, address(this), _amount);

		// Manage deposit -- update balance

		// Emit event

	}
}
