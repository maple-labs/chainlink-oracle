// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.7;

import { Ownable } from "../../Ownable.sol";

import { IChainlinkOracle } from "../../interfaces/IChainlinkOracle.sol";

contract Owner {

    /************************/
    /*** Direct Functions ***/
    /************************/

    function chainlinkOracle_changeAggregator(address oracle, address aggregator) external {
        IChainlinkOracle(oracle).changeAggregator(aggregator); 
    }

    function chainlinkOracle_setManualPrice(address oracle, int256 price) external { 
        IChainlinkOracle(oracle).setManualPrice(price); 
    }

    function chainlinkOracle_setManualOverride(address oracle, bool _override) external {
        IChainlinkOracle(oracle).setManualOverride(_override); 
    }

    function chainlinkOracle_renounceOwnership(address oracle) external {
        Ownable(oracle).renounceOwnership(); 
    }

    function chainlinkOracle_transferOwnership(address oracle, address newOwner) external {
        Ownable(oracle).transferOwnership(newOwner); 
    }

    /*********************/
    /*** Try Functions ***/
    /*********************/

    function try_chainlinkOracle_changeAggregator(address oracle, address aggregator) external returns (bool ok) {
        (ok,) = oracle.call(abi.encodeWithSelector(IChainlinkOracle.changeAggregator.selector, aggregator));
    }

    function try_chainlinkOracle_setManualPrice(address oracle, int256 priceFeed) external returns (bool ok) {
        (ok,) = oracle.call(abi.encodeWithSelector(IChainlinkOracle.setManualPrice.selector, priceFeed));
    }

    function try_chainlinkOracle_setManualOverride(address oracle, bool _override) external returns (bool ok) {
        (ok,) = oracle.call(abi.encodeWithSelector(IChainlinkOracle.setManualOverride.selector, _override));
    }

    function try_chainlinkOracle_renounceOwnership(address oracle) external returns (bool ok) {
        (ok,) = oracle.call(abi.encodeWithSelector(Ownable.renounceOwnership.selector));
    }

    function try_chainlinkOracle_transferOwnership(address oracle, address newOwner) external returns (bool ok) {
        (ok,) = oracle.call(abi.encodeWithSelector(Ownable.transferOwnership.selector, newOwner));
    }

}
