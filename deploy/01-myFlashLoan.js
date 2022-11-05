const { network } = require("hardhat");
const { networkConfig } = require("../helper-hardhat-config.js");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deployer } = await getNamedAccounts();
  const { deploy, log } = deployments;
  const chainId = network.config.chainId;

  //args lendingPoolAddressesProvider, BUSD address, borrow amount
  const lendingPoolAddressesProvider =
    networkConfig[chainId]["lendingPoolAddressesProvider"];
  const daiToken = networkConfig[chainId]["daiToken"];
  const borrowAmount = networkConfig[chainId]["borrowAmount"];

  log("Deploying contract.....");
  await deploy("MyFlashLoan", {
    contract: "MyFlashLoan",
    from: deployer,
    args: [lendingPoolAddressesProvider, daiToken, borrowAmount],
    log: true,
  });

  log("FlashLoan contract deployer..!!");
};

module.exports.tags = ["all", "flashLoan"];
