// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import {ILendingPool} from "@aave/protocol-v2/contracts/interfaces/ILendingPool.sol";
import {ILendingPoolAddressesProvider} from "@aave/protocol-v2/contracts/interfaces/ILendingPoolAddressesProvider.sol";
import {FlashLoanReceiverBase} from "@aave/protocol-v2/contracts/flashloan/base/FlashLoanReceiverBase.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {SafeMath} from "@aave/protocol-v2/contracts/dependencies/openzeppelin/contracts/SafeMath.sol";

import "hardhat/console.sol";

/**
 * @dev This contracts does the following operations using the aave/protocol-v2 flash loan functionality
 * 1. Requests a flash loan of 1 weth
 * 2. Deposits the Loaned amount to the lending pool as collateral
 * 3. Borrows a particular amount of USD stable coin (USDC)
 * 4. Repays the borrowed USD stable coing Debt
 * 5. Allows aave lending pool to pull back the flashed loan
 */

contract MyFlashLoan is FlashLoanReceiverBase {
    ILendingPoolAddressesProvider private immutable i_provider;
    address private immutable i_borrowAsset;
    uint256 private immutable i_borrowAmount;

    using SafeMath for uint256;

    // initialize the lending pool provider and the lending pool
    constructor(
        ILendingPoolAddressesProvider ADDRESSES_PROVIDER,
        address borrowAsset,
        uint256 borrowAmount
    ) public FlashLoanReceiverBase(ADDRESSES_PROVIDER) {
        i_provider = ADDRESSES_PROVIDER;
        i_borrowAsset = borrowAsset;
        i_borrowAmount = borrowAmount;
    }

    // execute operation function that aave will call to pull the flashed loan back
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        address asset = assets[0];
        uint256 amount = amounts[0];
        // uint256 premium = premiums[0];

        // Deposit the flased asset to the lending pool as collateral
        depositFlash(asset, amount);
        // borrow new asset
        // uint256 borrowAmount = 20 * 10e18; //20 units of the asset
        borrow(i_borrowAsset, i_borrowAmount);

        // repay the borrowed asset
        repay(i_borrowAsset, i_borrowAmount);

        // withdraw the collateral
        withdraw(asset, amount);

        // approve lending pool to be able to pull back the flashed assets
        IERC20(asset).approve(address(LENDING_POOL), amount.add(premiums[0]));

        return true;
    }

    function depositFlash(address asset, uint256 amount) public {
        // aprove the lending pool to transfer the asset to be deposited
        IERC20(asset).approve(address(LENDING_POOL), amount);

        LENDING_POOL.deposit(asset, amount, address(this), uint16(0));
        console.log("Deposited!");

        uint256 wethBalance = IERC20(asset).balanceOf(address(this));
        console.log(wethBalance);
    }

    function borrow(address asset, uint256 amount) public {
        LENDING_POOL.borrow(asset, amount, uint16(1), uint16(0), address(this));
        console.log("Borrowed DAI.!");
    }

    function repay(address asset, uint256 amount) public {
        IERC20(asset).approve(address(LENDING_POOL), amount);
        LENDING_POOL.repay(asset, amount, uint16(1), address(this));
        console.log("Repayed DAI.!");
    }

    function withdraw(address asset, uint256 amount) public {
        LENDING_POOL.withdraw(asset, amount, address(this));
        console.log("Collateral withdrawn..!");
    }

    //call the flashloan from outiside (Public)
    function requestFlashLoan(address asset, uint256 amount) public {
        // setting up the arguments for the flasLoan call
        address receiverAddress = address(this);

        address[] memory assets = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        uint256[] memory modes = new uint256[](1);

        assets[0] = asset;
        amounts[0] = amount;
        modes[0] = 0;

        address onBehalfOf = address(this);
        bytes memory params = "";
        uint16 referalCode = 0;

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referalCode
        );
    }

    //receive

    receive() external payable {
        console.log("Received weth");
        console.log(msg.sender, msg.value);
    }
}
