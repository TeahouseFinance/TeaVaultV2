// contracts/PerpCurieClearingHouseFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../AllowedTokensFilter.sol";

/// @title A simple implementation of filters for PerpCurie's ClearingHouse smart contract
/// @author Teahouse Finance
contract PerpCurieClearingHouseFilter is AllowedTokensFilter {

    struct AddLiquidityParams {
        address baseToken;
        uint256 base;
        uint256 quote;
        int24 lowerTick;
        int24 upperTick;
        uint256 minBase;
        uint256 minQuote;
        bool useTakerBalance;
        uint256 deadline;
    }

    // requires baseToken to be in the allowed tokens list
    function addLiquidity(AddLiquidityParams calldata params) external view returns (bytes4) {
        if (!tokenAllowed(params.baseToken)) {
            revert("Token not allowed");
        }

        return MAGICVALUE;
    }

    struct RemoveLiquidityParams {
        address baseToken;
        int24 lowerTick;
        int24 upperTick;
        uint128 liquidity;
        uint256 minBase;
        uint256 minQuote;
        uint256 deadline;
    }

    // requires baseToken to be in the allowed tokens list
    function removeLiquidity(RemoveLiquidityParams calldata params) external view returns (bytes4) {
        if (!tokenAllowed(params.baseToken)) {
            revert("Token not allowed");
        }

        return MAGICVALUE;
    }

    function settleAllFunding(address /*trader*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }

    struct OpenPositionParams {
        address baseToken;
        bool isBaseToQuote;
        bool isExactInput;
        uint256 amount;
        uint256 oppositeAmountBound;
        uint256 deadline;
        uint160 sqrtPriceLimitX96;
        bytes32 referralCode;
    }

    function openPosition(OpenPositionParams memory params) external view returns (bytes4) {
        if (!tokenAllowed(params.baseToken)) {
            revert("Token not allowed");
        }

        return MAGICVALUE;
    }

    struct ClosePositionParams {
        address baseToken;
        uint160 sqrtPriceLimitX96;
        uint256 oppositeAmountBound;
        uint256 deadline;
        bytes32 referralCode;
    }

    function closePosition(ClosePositionParams calldata params) external view returns (bytes4) {
        if (!tokenAllowed(params.baseToken)) {
            revert("Token not allowed");
        }

        return MAGICVALUE;
    }
}
