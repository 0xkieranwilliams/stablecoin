// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {DecentralisedStableCoin} from "src/DecentralisedStableCoin.sol";
import {MockERC20} from "test/mocks/MockERC20.sol";

contract Handler is Test{
  DSCEngine dsce;
  DecentralisedStableCoin dsc;
  MockERC20 weth;
  MockERC20 wbtc;

  constructor(DSCEngine _dscEngine, DecentralisedStableCoin _dsc) {
    dsce = _dscEngine;
    dsc = _dsc;
    address[] memory collateralTokens = dsce.getCollateralTokens();
    weth = MockERC20(collateralTokens[0]);
    wbtc = MockERC20(collateralTokens[1]);
  }

  function mintDsc(uint256 amount) public {
    amount = bound(amount, 1, 1000e18);
    (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(msg.sender);
    int256 maxDscToMint = (int256(collateralValueInUsd)/ 2) - int256(totalDscMinted);
    if (maxDscToMint < 0) {
      return;
    }
    amount = bound(amount, 0, uint256(maxDscToMint));
    if (amount == 0){
      return;
    }
    vm.startPrank(msg.sender);
    dsce.mintDsc(amount);
    vm.stopPrank();
  }

  function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
    MockERC20 collateral = _getCollateralFromSeed(collateralSeed);
    amountCollateral = bound(amountCollateral, 1, 1000e18);

    vm.startPrank(msg.sender);
    collateral.mint(msg.sender, amountCollateral);
    collateral.approve(address(dsce), amountCollateral);
    dsce.depositCollateral(address(collateral), amountCollateral); 
    vm.stopPrank();
  }

  function redeemCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
    MockERC20 collateral = _getCollateralFromSeed(collateralSeed);
    uint256 maxCollateralToRedeem = dsce.getCollateralBalanceOfUser(address(collateral), msg.sender);
    amountCollateral = bound(amountCollateral, 0, maxCollateralToRedeem);
    if(amountCollateral == 0) {
      return;
    }
    dsce.redeemCollateral(address(collateral), amountCollateral);
  }

  function _getCollateralFromSeed(uint256 collateralSeed) private view returns (MockERC20) { 
    if (collateralSeed % 2 == 0) {
      return weth;
    }
    return wbtc;
  }
}

