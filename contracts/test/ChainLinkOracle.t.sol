// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.6.11;

import { DSTest } from "../../modules/ds-test/src/test.sol";

import { ChainlinkOracle } from "../ChainlinkOracle.sol";

import { ChainlinkOracleOwner } from "./accounts/ChainlinkOracleOwner.sol";

contract ChainlinkAggregatorMock {

    function latestRoundData()
    external
    pure
    returns (
        uint80  roundId,
        int256  answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80  answeredInRound
    ) {
        return (uint80(1), int256(2000), 1231, 1231, uint80(12));
    }

}

contract ChainlinkOracleTest is DSTest {

    ChainlinkOracle          oracle;
    ChainlinkOracleOwner     realOracleOwner;
    ChainlinkOracleOwner     fakeOracleOwner;
    ChainlinkAggregatorMock  wethAggregator;

    function setUp() public {
        realOracleOwner = new ChainlinkOracleOwner();
        fakeOracleOwner = new ChainlinkOracleOwner();
        wethAggregator  = new ChainlinkAggregatorMock();
        oracle          = new ChainlinkOracle(address(wethAggregator), address(1), address(realOracleOwner));
    }

    function test_getLatestPrice() public {
        // Assert initial state
        assertTrue( oracle.getLatestPrice() > int256(1));
        assertTrue(!oracle.manualOverride());

        assertEq(oracle.manualPrice(), int256(0));

        // Try to set manual price before setting the manual override.
        assertTrue(!realOracleOwner.try_chainlinkOracle_setManualPrice(address(oracle), int256(45000)));

        // Enable oracle manual override
        assertTrue(!fakeOracleOwner.try_chainlinkOracle_setManualOverride(address(oracle), true));
        assertTrue( realOracleOwner.try_chainlinkOracle_setManualOverride(address(oracle), true));
        assertTrue(oracle.manualOverride());

        // Set price manually
        assertTrue(!fakeOracleOwner.try_chainlinkOracle_setManualPrice(address(oracle), int256(45000)));
        assertTrue( realOracleOwner.try_chainlinkOracle_setManualPrice(address(oracle), int256(45000)));
        
        assertEq(oracle.manualPrice(),    int256(45000));
        assertEq(oracle.getLatestPrice(), int256(45000));

        // Change aggregator
        assertTrue(!fakeOracleOwner.try_chainlinkOracle_changeAggregator(address(oracle), 0xb022E2970b3501d8d83eD07912330d178543C1eB));
        assertTrue( realOracleOwner.try_chainlinkOracle_changeAggregator(address(oracle), 0xb022E2970b3501d8d83eD07912330d178543C1eB));
        
        assertEq(address(oracle.priceFeed()), 0xb022E2970b3501d8d83eD07912330d178543C1eB);
    }

}
