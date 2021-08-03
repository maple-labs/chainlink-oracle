// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.6.11;

import { DSTest } from "../../modules/ds-test/src/test.sol";

import { ChainlinkOracle } from "../ChainlinkOracle.sol";

import { SecurityAdmin } from "./accounts/SecurityAdmin.sol";

contract FakeFoo {

    function try_chainlinkOracle_setManualOverride(address oracle, bool _override) external returns (bool ok) {
        string memory sig = "setManualOverride(bool)";
        (ok,) = oracle.call(abi.encodeWithSignature(sig, _override));
    }

    function try_chainlinkOracle_setManualPrice(address oracle, int256 priceFeed) external returns (bool ok) {
        string memory sig = "setManualPrice(int256)";
        (ok,) = oracle.call(abi.encodeWithSignature(sig, priceFeed));
    }

    function try_chainlinkOracle_changeAggregator(address oracle, address aggregator) external returns (bool ok) {
        string memory sig = "changeAggregator(address)";
        (ok,) = oracle.call(abi.encodeWithSignature(sig, aggregator));
    }
}

contract ChainlinkOracleTest is DSTest {

    ChainlinkOracle        oracle;
    SecurityAdmin   securityAdmin;
    FakeFoo               fakeFoo;

    address constant wethAggregator = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address constant WETH           = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;


    function setUp() public {
        securityAdmin = new SecurityAdmin();
        oracle        = new ChainlinkOracle(wethAggregator, WETH, address(securityAdmin));
        fakeFoo       = new FakeFoo();
    }

    function test_getLatestPrice() public {
        // Assert initial state
        assertTrue( oracle.getLatestPrice() > int256(1));
        assertTrue(!oracle.manualOverride());
        assertEq(   oracle.manualPrice(), int256(0));

        // Try to set manual price before setting the manual override.
        assertTrue(!securityAdmin.try_chainlinkOracle_setManualPrice(address(oracle), int256(45000)));

        // Enable oracle manual override
        assertTrue(     !fakeFoo.try_chainlinkOracle_setManualOverride(address(oracle), true));
        assertTrue(securityAdmin.try_chainlinkOracle_setManualOverride(address(oracle), true));
        assertTrue(       oracle.manualOverride());

        // Set price manually
        assertTrue(     !fakeFoo.try_chainlinkOracle_setManualPrice(address(oracle), int256(45000)));
        assertTrue(securityAdmin.try_chainlinkOracle_setManualPrice(address(oracle), int256(45000)));
        assertEq(    oracle.manualPrice(),    int256(45000));
        assertEq(    oracle.getLatestPrice(), int256(45000));

        // Change aggregator
        assertTrue(     !fakeFoo.try_chainlinkOracle_changeAggregator(address(oracle), 0xb022E2970b3501d8d83eD07912330d178543C1eB));
        assertTrue(securityAdmin.try_chainlinkOracle_changeAggregator(address(oracle), 0xb022E2970b3501d8d83eD07912330d178543C1eB));
        assertEq(address(oracle.priceFeed()),                          0xb022E2970b3501d8d83eD07912330d178543C1eB);
    }

}
