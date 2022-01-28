// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.7;

import { DSTest } from "../../modules/ds-test/src/test.sol";

import { ChainlinkOracle } from "../ChainlinkOracle.sol";

import { Owner } from "./accounts/Owner.sol";

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
        )
    {
        return (uint80(1), int256(2000), 1231, 1231, uint80(12));
    }

}

contract ChainlinkOracleTest is DSTest {

    ChainlinkAggregatorMock wethAggregator;
    ChainlinkOracle         oracle;
    Owner                   notOwner;
    Owner                   owner;

    function setUp() public {
        notOwner       = new Owner();
        owner          = new Owner();
        wethAggregator = new ChainlinkAggregatorMock();

        oracle = new ChainlinkOracle(address(wethAggregator), address(1), address(owner));
    }

    function test_getLatestPrice() public {
        // Assert initial state
        assertTrue( oracle.getLatestPrice() > int256(1));
        assertTrue(!oracle.manualOverride());

        assertEq(oracle.manualPrice(), int256(0));

        // Try to set manual price before setting the manual override.
        assertTrue(!owner.try_chainlinkOracle_setManualPrice(address(oracle), int256(45000)));

        // Enable oracle manual override
        assertTrue(!notOwner.try_chainlinkOracle_setManualOverride(address(oracle), true));
        assertTrue(    owner.try_chainlinkOracle_setManualOverride(address(oracle), true));
        assertTrue(oracle.manualOverride());

        // Set price manually
        assertTrue(!notOwner.try_chainlinkOracle_setManualPrice(address(oracle), int256(45000)));
        assertTrue(    owner.try_chainlinkOracle_setManualPrice(address(oracle), int256(45000)));
        
        assertEq(oracle.manualPrice(),    int256(45000));
        assertEq(oracle.getLatestPrice(), int256(45000));

        // Change aggregator
        assertTrue(!notOwner.try_chainlinkOracle_changeAggregator(address(oracle), address(2)));
        assertTrue(    owner.try_chainlinkOracle_changeAggregator(address(oracle), address(2)));
        
        assertEq(address(oracle.priceFeed()), address(2));
    }

}
