const Token = artifacts.require("Token");
const Exchange = artifacts.require("Exchange");

module.exports = async function (deployer) {
  //gets the array of accounts --provided by ganache in this case
  const accounts = await web3.eth.getAccounts();

  await deployer.deploy(Token);
  
  const feeAccount = accounts[0];
  const feePercent = 10;

  
  await deployer.deploy(Exchange, feeAccount, feePercent);
};

