pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./ChainlinkOracle.sol";

contract ChainlinkOracleTest is DSTest {
    ChainlinkOracle oracle;

    function setUp() public {
        oracle = new ChainlinkOracle();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
