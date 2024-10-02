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
  address btcUsdPriceFeed;
  address weth;
  address wbtc;

  address public USER = makeAddr("user");
  uint256 public constant AMOUNT_COLLATERAL = 10 ether;
  uint256 public constant STARTING_ERC20_BALANCE = 10 ether;

  function setUp() public {
    deployer = new DeployDSC();
    (dsc, dsce, helperConfig) = deployer.run();
    (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc,) = helperConfig.activeNetworkConfig();

    MockERC20(weth).mint(USER, STARTING_ERC20_BALANCE);
  } 

  //////////////////////////////////////
  //        Constructor Tests         //
  //////////////////////////////////////

  address[] public tokenAddresses;
  address[] public priceFeedAddresses;

  function testRevertsIfTokenLengthDoesntMatchPriceFeeds() public {
    tokenAddresses.push(weth);
    priceFeedAddresses.push(ethUsdPriceFeed);
    priceFeedAddresses.push(btcUsdPriceFeed);

    vm.expectRevert(DSCEngine.DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength.selector);
    new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));
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

  function testGetTokenAmountFromUsd() public {
    uint256 usdAmount = 100 ether;
    // $2000 / ETH $100
    uint256 expectedWeth = 0.05 ether;
    uint256 actualWeth = dsce.getTokenAmountFromUsd(weth, usdAmount);
    assertEq(expectedWeth, actualWeth);
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

  function testRevertsWithUnapprovedCollateral() public {
    MockERC20 ranToken = new MockERC20("RAN", "RAN", USER, AMOUNT_COLLATERAL);
    vm.startPrank(USER); 
    vm.expectRevert(DSCEngine.DSCEngine__NotAllowedToken.selector);
    dsce.depositCollateral(address(ranToken), AMOUNT_COLLATERAL);
  }

  modifier depositedCollateral() {
    vm.startPrank(USER);
    MockERC20(weth).approve(address(dsce), AMOUNT_COLLATERAL);
    dsce.depositCollateral(weth, AMOUNT_COLLATERAL);
    vm.stopPrank();
    _;
  }

  function testCanDepositCollateralAndGetAccountInfo() public depositedCollateral {
    (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(USER);

    uint256 expectedTotalDscMinted = 0;
    uint256 expectedDepositAmount = dsce.getTokenAmountFromUsd(weth, collateralValueInUsd);
    assertEq(totalDscMinted, expectedTotalDscMinted);
    assertEq(AMOUNT_COLLATERAL, expectedDepositAmount);
  }



}
