// contracts/StethDepositHelperFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../ERC20Filter.sol";

/// @title A simple implementation of filters for Ribbon's stETH deposit helper contract
/// @author Teahouse Finance
contract StethDepositHelperFilter is BaseFilter {

    // no specific restrictions
    function deposit(uint256 /*minSTETHAmount*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }
}