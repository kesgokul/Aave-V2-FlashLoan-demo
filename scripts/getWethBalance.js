const { ethers, network, getNamedAccounts } = require("hardhat");
const { networkConfig } = require("../helper-hardhat-config");
async function getWethBalance() {
  const { deployer } = await getNamedAccounts();
  const myFlashLoan = await ethers.getContract("MyFlashLoan, deployer");
  const wethToken = networkConfig[chainId]["wethToken"];

  console.log(myFlashLoan.address);
}

getWethBalance()
  .then(() => process.exit(0))
  .catch((e) => {
    console.log(e);
    process.exit(1);
  });
