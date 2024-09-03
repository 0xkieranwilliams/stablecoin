// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployDSC} from "script/DeployDSC.s.sol";
import {DecentralisedStableCoin} from "src/DecentralisedStableCoin.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {MockERC20} from "test/mocks/MockERC20.sol";

contract DSCEngineTest is Test {
  DeployDSC deployer;
  DecentralisedStableCoin dsc;
  DSCEngine dsce;
  HelperConfig helperConfig;
  address ethUsdPriceFeed;
  address weth;

  address public USER = makeAddr("user");
  uint256 public constant AMOUNT_COLLATERAL = 10 ether;
  uint256 public constant STARTING_ERC20_BALANCE = 10 ether;

  function setUp() public {
    deployer = new DeployDSC();
    (dsc, dsce, helperConfig) = deployer.run();
    (ethUsdPriceFeed, , weth, ,) = helperConfig.activeNetworkConfig();

    MockERC20(weth).mint(USER, STARTING_ERC20_BALANCE);
  } 

  //////////////////////////////////////
  //           Price Tests            //
  //////////////////////////////////////

  function testGetUsdValue() public view {
    uint256 ethAmount = 15e18;
    // 15e18 * 2000/ETH = 30,000e18
    uint256 expectedUsd = 30000e18; 
    uint256 actualUsd = dsce.getUsdValue(weth, ethAmount);
    assertEq(expectedUsd, actualUsd);
  }

  //////////////////////////////////////
  //     Deposit Collateral Tests     //
  //////////////////////////////////////

  function testRevertsIfCollateralIsZero () public {
    vm.startPrank(USER);
    MockERC20(weth).approve(address(dsce), AMOUNT_COLLATERAL);
    vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
    dsce.depositCollateral(weth, 0);
    vm.stopPrank();
  }

}
