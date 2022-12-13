// contracts/L2PoolFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../BaseFilter.sol";

/// @title A simple implementation of filters for AAVE V3 L2Pool contract
/// @author Teahouse Finance
contract L2PoolFilter is BaseFilter {

    // no specific restrictions
    function supply(bytes32 /*args*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // no specific restrictions
    function withdraw(bytes32 /*args*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }
}