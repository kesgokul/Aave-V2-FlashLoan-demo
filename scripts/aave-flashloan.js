const { getWeth } = require("./getWeth.js");
const { getNamedAccounts, ethers, network, deployments } = require("hardhat");
const { networkConfig } = require("../helper-hardhat-config");

const chainId = network.config.chainId;
async function main() {
  const signer = (await ethers.getSigners())[0];
  const { deployer } = await getNamedAccounts();
  const wethToken = networkConfig[chainId]["wethToken"];
  const flashAmount = ethers.utils.parseEther("1");

  const wethBalance = await getWeth();

  // get the flashloan consumer contract address after deployment
  await deployments.fixture(["all"]);
  const myFlashLoan = await ethers.getContract("MyFlashLoan", deployer);

  //transfer weth to the contract so that the contract has balance to payback the flasloan + premiums
  await transferWeth(wethToken, wethBalance, myFlashLoan.address, deployer);

  // call the flasloan
  await myFlashLoan.requestFlashLoan(wethToken, flashAmount);
}

async function transferWeth(wethToken, amount, contractAddress, account) {
  const wethContract = await ethers.getContractAt("IWeth", wethToken, account);
  await wethContract.transfer(contractAddress, amount);
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });
