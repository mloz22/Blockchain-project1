import {tokens, EVM_REVERT} from './helpers'

const Token = artifacts.require('./Token')
const Exchange = artifacts.require('./Exchange')

require('chai')
	.use(require('chai-as-promised'))
	.should()

contract('Exchange', ([deployer, feeAccount, user1]) => {
	let token
	let exchange
	const feePercent = 10

	beforeEach(async () => {
		// Deploy token
		token = await Token.new()
		// Transfer some tokens to user1
		token.transfer(user1, tokens(100), {from: deployer})

		// Deploy exchange
		exchange = await Exchange.new(feeAccount, feePercent)

	})

	describe('deployment', () => {
		it('tracks the fee account', async () => {
			const result = await exchange.feeAccount()
			result.should.equal(feeAccount)
		})

		it('tracks the fee percent', async () => {
			const result = await exchange.feePercent()
			result.toString().should.equal(feePercent.toString())
		})
	})

	describe('depositing tokens', () => {
		let result
		let amount

		beforeEach(async () =>{
			amount = tokens(10)
			await token.approve(exchange.address, amount, {from: user1})
			const result = await exchange.depositToken(token.address, amount, {from: user1})
		})

		describe('success', () => {
			it('tracks the token deposit', async () => {
			// Check exchange's token balance
			let balance
			balance = await token.balanceOf(exchange.address)
			balance.toString().should.equal(amount.toString())
		})

		})

		describe('failure', () => {
			it('tracks failure', async () => {
			
		})
		})

		
		
	})
})