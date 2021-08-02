// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import { DSTest } from "../../modules/ds-test/src/test.sol";
import { SecurityAdmin } from "./accounts/SecurityAdmin.sol";
import { Commoner } from "./accounts/Commoner.sol";
import { ChainlinkOracle } from "../ChainlinkOracle.sol";

contract ChainlinkOracleTest is DSTest {

    ChainlinkOracle   orcl;
    SecurityAdmin   sadmin;
    Commoner           cam;

    address constant wethAggregator = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address constant WETH           = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;


    function setUp() public {
        sadmin = new SecurityAdmin();
        orcl   = new ChainlinkOracle(wethAggregator, WETH, address(sadmin));
        cam    = new Commoner();
    }

    function test_getLatestPrice() public {
        // Assert initial state
        assertTrue( orcl.getLatestPrice() > int256(1));
        assertTrue(!orcl.manualOverride());
        assertEq(   orcl.manualPrice(), int256(0));

        // Try to set manual price before setting the manual override.
        assertTrue(!sadmin.try_setManualPrice(address(orcl), int256(45000)));

        // Enable oracle manual override
        assertTrue(  !cam.try_setManualOverride(address(orcl), true));
        assertTrue(sadmin.try_setManualOverride(address(orcl), true));
        assertTrue(  orcl.manualOverride());

        // Set price manually
        assertTrue(  !cam.try_setManualPrice(address(orcl), int256(45000)));
        assertTrue(sadmin.try_setManualPrice(address(orcl), int256(45000)));
        assertEq(    orcl.manualPrice(),    int256(45000));
        assertEq(    orcl.getLatestPrice(), int256(45000));

        // Change aggregator
        assertTrue(  !cam.try_changeAggregator(address(orcl), 0xb022E2970b3501d8d83eD07912330d178543C1eB));
        assertTrue(sadmin.try_changeAggregator(address(orcl), 0xb022E2970b3501d8d83eD07912330d178543C1eB));
        assertEq(address(orcl.priceFeed()),                          0xb022E2970b3501d8d83eD07912330d178543C1eB);
    }

}
