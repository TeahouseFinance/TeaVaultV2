// contracts/UniswapNFTFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../AllowedTokensFilter.sol";

/// @title A simple implementation of filters for Uniswap's NonFungibleManager contract
/// @author Teahouse Finance
contract UniswapNFTFilter is AllowedTokensFilter {

    // support for multicall
    function multicall(bytes[] calldata data) external returns (bytes4) {
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory returndata) = address(this).delegatecall(data[i]);
            if (!success) {
                _forwardRevert(returndata);       // forward revert string
            }
            if(abi.decode(returndata, (bytes4)) != 0x59faaa03) revert("Invalid filter return value");
        }

        return MAGICVALUE;
    }

    function _forwardRevert(bytes memory result) internal pure {
        // forward revert from filter
        // from OpenZeppelin's Address.sol
        // works with both revert string and custom error
        if (result.length == 0) revert();
        assembly {
            revert(add(32, result), mload(result))
        }
    }      

    // -----------------------------
    // INonfungiblePositionManager
    // -----------------------------

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    // requires token0 and token1 are in allowed list
    // also requires recipient to be sender
    function mint(MintParams calldata params) external view returns (bytes4) {
        if (!tokenAllowed(params.token0) || !tokenAllowed(params.token1)) {
            revert("Token not allowed");
        }

        if (params.recipient != msg.sender) {
            revert("Outside recipient not allowed");
        }

        return MAGICVALUE;
    }

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    // no specific restrictions
    function increaseLiquidity(IncreaseLiquidityParams calldata /*params*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    // no specific restrictions
    function decreaseLiquidity(DecreaseLiquidityParams calldata /*params*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    // requires recipient to be sender or address(0)
    function collect(CollectParams calldata params) external view returns (bytes4) {
        if (params.recipient != msg.sender && params.recipient != address(0)) {
            revert("Outside recipient not allowed");
        }

        return MAGICVALUE;
    }

    // no specific restrictions
    function burn(uint256 /*tokenId*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // ------------------
    // IPeripheryPayments
    // ------------------

    // requires recipient to be sender
    function unwrapWETH9(uint256 /*amountMinimum*/, address recipient) external view returns (bytes4) {
        if (recipient != msg.sender) {
            revert("Outside recipient not allowed");
        }

        return MAGICVALUE;
    }

    // no specific restrictions
    function refundETH() external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // requires recipient to be sender
    function sweepToken(
        address /*token*/,
        uint256 /*amountMinimum*/,
        address recipient
    ) external view returns (bytes4) {
        if (recipient != msg.sender) {
            revert("Outside recipient not allowed");
        }

        return MAGICVALUE;
    }
}
