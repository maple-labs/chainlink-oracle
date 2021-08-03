// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.6.11;

import { IChainlinkOracle } from "../../interfaces/IChainlinkOracle.sol";

contract SecurityAdmin {

    function setManualPrice(address target, int256 price) external { 
        IChainlinkOracle(target).setManualPrice(price); 
    }

    function setManualOverride(address target, bool _override) external {
        IChainlinkOracle(target).setManualOverride(_override); 
    }

    function changeAggregator(address target, address aggregator) external {
        IChainlinkOracle(target).changeAggregator(aggregator); 
    }

    function try_chainlinkOracle_setManualPrice(address oracle, int256 priceFeed) external returns (bool ok) {
        string memory sig = "setManualPrice(int256)";
        (ok,) = oracle.call(abi.encodeWithSignature(sig, priceFeed));
    }

    function try_chainlinkOracle_setManualOverride(address oracle, bool _override) external returns (bool ok) {
        string memory sig = "setManualOverride(bool)";
        (ok,) = oracle.call(abi.encodeWithSignature(sig, _override));
    }

    function try_chainlinkOracle_changeAggregator(address oracle, address aggregator) external returns (bool ok) {
        string memory sig = "changeAggregator(address)";
        (ok,) = oracle.call(abi.encodeWithSignature(sig, aggregator));
    }

}
