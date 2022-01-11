pragma solidity ^0.5.0;

import "./Token.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";


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
	using SafeMath for uint;

	// Variables
	address public feeAccount; // the account which receives exchange fees
	uint256 public feePercent; // fee percentage
	address constant ETHER = address(0); // Stores Ether in tokens mapping with a blank address

	mapping(address => mapping(address => uint256)) public tokens;

	// Events
	event Deposit(address token, address user, uint256 amount, uint256 balance);


	// Set the fee account and percent
	constructor(address _feeAccount, uint256 _feePercent) public {
		feeAccount = _feeAccount;
		feePercent = _feePercent;
	}

	function depositEther() payable public {
		// keeps track of the amount of Ether inside the token's mapping. It'll reduce the amount of storage on the blockchain.
		tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].add(msg.value);
			// Emit event
		emit Deposit(ETHER, msg.sender, msg.value, tokens[ETHER][msg.sender]);
	}

	function depositToken(address _token, uint256 _amount) public {
		// Don't allow Ether deposits
		require(_token != ETHER);
		// Which token? --any ERC20, paramenter of _token...How much of that token? parameter of _amount

		// Send toeksn to this contract
		require(Token(_token).transferFrom(msg.sender, address(this), _amount)); //must return a true value

		// Manage deposit -- update balance
		tokens[_token][msg.sender] = tokens[_token][msg.sender].add(_amount);

		// Emit event
		emit Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]);

		
	}
}
