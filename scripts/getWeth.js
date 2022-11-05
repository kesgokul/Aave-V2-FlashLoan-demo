const { getNamedAccounts, network, ethers } = require("hardhat");
const { networkConfig } = require("../helper-hardhat-config.js");

async function getWeth() {
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;
  const wethTokenAddress = networkConfig[chainId]["wethToken"];
  const depositAmount = networkConfig[chainId]["wethAmount"];

  const wethContract = await ethers.getContractAt(
    "IWeth",
    wethTokenAddress,
    deployer
  );

  console.log("Depositing ETH for WETH");
  const tx = await wethContract.deposit({ value: depositAmount });
  await tx.wait(1);
  console.log("Got WETH!!");
  const wethBalance = await wethContract.balanceOf(deployer);
  return wethBalance;
}

module.exports = { getWeth };
