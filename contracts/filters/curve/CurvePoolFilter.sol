// contracts/CurvePoolFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../BaseFilter.sol";

/// @title A simple implementation of filters for Curve.fi's liquidity farming pool contract
/// @author Teahouse Finance
contract CurvePoolFilter is BaseFilter {

    // no specific restrictions
    function add_liquidity(uint256[2] memory /*amounts*/, uint256 /*min_mint_amount*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // no specific restrictions
    function exchange(int128 /*i*/, int128 /*j*/, uint256 /*dx*/, uint256 /*min_dy*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // no specific restrictions
    function remove_liquidity(uint256 /*_amount*/, uint256[2] memory /*_min_amounts*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // no specific restrictions
    function remove_liquidity_imbalance(uint256[2] memory /*_amounts*/, uint256 /*_max_burn_amount*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // no specific restrictions
    function remove_liquidity_one_coin(uint256 /*_token_amount*/, int128 /*i*/, uint256 /*_min_amount*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }
}