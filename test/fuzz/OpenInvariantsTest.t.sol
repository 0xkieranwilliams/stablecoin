// // SPDX-License-Identifier: MIT
//
//
// // Have our invariant aka properties
//
// // What are our invariants?
//
// // 1. The total supply of DSC should be less than the total value of collateral
// // 2. Getter view functions should never rever <- evergreen invariant
//
// pragma solidity ^0.8.19;
//
// import {Test, console} from "forge-std/Test.sol";
// import {StdInvariant} from "forge-std/StdInvariant.sol";
// import {DeployDSC} from "../../script/DeployDSC.s.sol";
// import {DSCEngine} from "../../src/DSCEngine.sol";
// import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
// import {HelperConfig} from "../../script/HelperConfig.s.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//
//
// contract OpenInvariantsTest is StdInvariant, Test {
//   DeployDSC deployer;
//   DSCEngine dsce;
//   DecentralisedStableCoin dsc;
//   HelperConfig config;
//   address weth;
//   address wbtc;
//
//   function setUp() external {
//     deployer = new DeployDSC();
//     (dsc, dsce, config) = deployer.run();
//     (, , weth, wbtc,) = config.activeNetworkConfig();
//     targetContract(address(dsce));
//   }
//
//   function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
//     // get the value of all the collateral in the protocol
//     // compare it to all the debt (dsc)
//     uint256 totalSupply = dsc.totalSupply();
//     uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsce));
//     uint256 totalBtcDeposited = IERC20(wbtc).balanceOf(address(dsce));
//
//     uint256 wethValue = dsce.getUsdValue(weth, totalWethDeposited);
//     uint256 wbtcValue = dsce.getUsdValue(wbtc, totalBtcDeposited);
//
//     console.log("weth value: ", wethValue);
//     console.log("wbtc value: ", wbtcValue);
//
//     assert(wethValue + wbtcValue >= totalSupply);
//   }
// }
//
