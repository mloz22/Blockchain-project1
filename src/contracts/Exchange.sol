pragma solidity ^0.5.0;

import "./Token.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";


//Deposit & Withdraw Funds
//Manage Orders - Make or Cancel
//Handle Trades - Charge fees


// TODO: 
// [X] Set the fee account
// [X] Deposit Ether
// [X] Withdraw Ether
// [X] Deposit tokens
// [X] Withdraw tokens
// [X] Check balances
// [X] Make order
// [X] Cancel order
// [X] Fill order 
// [ ] Charge fees






contract Exchange {
	using SafeMath for uint;

	// Variables
	address public feeAccount; // the account which receives exchange fees
	uint256 public feePercent; // fee percentage
	address constant ETHER = address(0); // Stores Ether in tokens mapping with a blank address

	mapping(address => mapping(address => uint256)) public tokens;
	// A way to store the order on the blockchain
	mapping (uint256 => _Order) public orders;
	uint256 public orderCount; //keeps track of orders as a counter cache, starts at 0
	mapping (uint256 => bool) public orderCancelled;
	mapping (uint256 => bool) public orderFilled;


	// Events
	event Deposit(address token, address user, uint256 amount, uint256 balance);
	event Withdraw(address token, address user, uint256 amount, uint256 balance);
	event Order(
		uint256 id,
		address user,
		address tokenGet,
		uint256 amountGet,
		address tokenGive,
		uint256 amountGive,
		uint256 timestamp
	);

	event Cancel(
		uint256 id,
		address user,
		address tokenGet,
		uint256 amountGet,
		address tokenGive,
		uint256 amountGive,
		uint256 timestamp
	);
	event Trade(
		uint256 id,
		address user,
		address tokenGet,
		uint256 amountGet,
		address tokenGive,
		uint256 amountGive,
		address userFill,
		uint256 timestamp
	);

	//Structs
	struct _Order{
		
		// A way to model the order
		//Attributes 
		uint256 id; 
		address user;
		address tokenGet; //token wanted
		uint256 amountGet; 
		address tokenGive; //token to be given
		uint256 amountGive;
		uint256 timestamp;
	}


	


	// Set the fee account and percent
	constructor(address _feeAccount, uint256 _feePercent) public {
		feeAccount = _feeAccount;
		feePercent = _feePercent;
	}

	// Fallback: reverts if Ether is sent to this smart contract by mistake.
	function() external {
		revert();
	}

	function depositEther() payable public {
		// keeps track of the amount of Ether inside the token's mapping. It'll reduce the amount of storage on the blockchain.
		tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].add(msg.value);
		// Emit event
		emit Deposit(ETHER, msg.sender, msg.value, tokens[ETHER][msg.sender]);
	}

	function withdrawEther(uint256 _amount) public {
		require(tokens[ETHER][msg.sender] >= _amount);
		tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].sub(_amount);
		msg.sender.transfer(_amount);
		emit Withdraw(ETHER, msg.sender, _amount, tokens[ETHER][msg.sender] );
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

	function withdrawToken(address _token, uint256 _amount) public {
		require(_token != ETHER);
		require(tokens[_token][msg.sender] >= _amount);

		tokens[_token][msg.sender] = tokens[_token][msg.sender].sub(_amount);
		require(Token(_token).transfer(msg.sender, _amount));
		emit Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender] );
	}

	function balanceOf(address _token, address _user) public view returns (uint256) {
		return tokens[_token][_user];
	}
	
	// Add the order to storage
	function makeOrder(address _tokenGet, uint256 _amountGet, address _tokenGive, uint256 _amountGive) public {
		// Instantiate the struct
		orderCount = orderCount.add(1);
		orders[orderCount] = _Order(orderCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, now);

		emit Order(orderCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, now);
	}

	function cancelOrder(uint256 _id) public{
		
		//passing the id, fetching the order from the mapping with variable _order of type _Order, fetching from storage
		_Order storage _order = orders[_id]; 
		// Must be "my" order
		require(address(_order.user) == msg.sender);

		// Must be a valid order. The order must exist
		require(_order.id == _id);


		orderCancelled[_id] = true;
		emit Cancel(_order.id, msg.sender, _order.tokenGet, _order.amountGet, _order.tokenGive, _order.amountGive, now);
	}

	function fillOrder(uint256 _id) public {
		
		require(_id > 0 && _id <= orderCount);
		require(!orderFilled[_id]);
		require(!orderCancelled[_id]);
		// Fetch the Order
		_Order storage _order = orders[_id]; 
		
		// Execute the trade, Charge fees, Emit a trade event
		_trade(_order.id, _order.user, _order.tokenGet, _order.amountGet, _order.tokenGive, _order.amountGive);
		
		// Mark the order as filled
		orderFilled[_order.id] = true;
	}

	function _trade(uint256 _orderId, address _user,  address _tokenGet, uint256 _amountGet, address _tokenGive, uint256 _amountGive ) internal {
		/*
		Charge fees
		
		Fee paid by the user that fills th order, aka msg.sender, and the 
		Fee is deducted from _amountGet 
		*/
		uint256 _feeAmount = _amountGet.mul(feePercent).div(100);

		// Execute the trade
		tokens[_tokenGet][msg.sender] = tokens[_tokenGet][msg.sender].sub(_amountGet.add(_feeAmount));
		tokens[_tokenGet][_user] = tokens[_tokenGet][_user].add(_amountGet);
		tokens[_tokenGet][feeAccount] = tokens[_tokenGet][feeAccount].add(_feeAmount);
		tokens[_tokenGive][_user] = tokens[_tokenGive][_user].sub(_amountGive);
		tokens[_tokenGive][msg.sender] = tokens[_tokenGive][msg.sender].add(_amountGive);
		
		// Emit a trade event
		emit Trade(_orderId, _user, _tokenGet, _amountGet, _tokenGive, _amountGive, msg.sender, now);
	}
}
