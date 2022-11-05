# AAVE-V2 Flash loan Demo

<sub>This project was created for learning purposes only. Not a production version</sub>

## Overview

This repo contains `MyFlashLoan.sol` contract that makes use of the flash loan
functionality and perform the following operations in **one transaction**.

1. Requests the aave lending pool for a flash loan of `1 WETH`.
2. Deposits the loaned WETH to the Lending pool as a collateral.
3. Borrows `DAI` token according on the borrowing power available based on the collateral.
4. Repays the Debt borrowed (`DAI`).
5. Withdraws the deposited Collateral (`WETH`).
6. Approves the Lending pool to be able to 'pull' the flash loan amount back. (aave's way of making the contract repay the flash loan).

## Tech used and learnings:

1. Used the `@aave/protocol-v2` contracts/interfaces such as `ILendingPoolAddressesProvider` and `ILendingPool` to access Aave's Lending pool.
2. `FlashLoanReceiverBase` to make out contract the receiver of the flasloan.
3. Used the `hardhat` dev environment. `hardhat-deploy` to deploy contract.
4. Forked the Ethereum Mainet to the local hardat network for devlopment.
5. Used QuickNode's RPC to deploy the contract and run scripts on the Gorëli test net.

## Issues during development

1. Contract did not have enough balance to repay the flash loan principle + premium.
   fix: Ensure the contract has enough balance by funding it prior to calling the flasLoan() function.
