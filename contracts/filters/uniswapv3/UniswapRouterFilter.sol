// contracts/UniswapRouterFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../AllowedTokensFilter.sol";

/// @title A simple implementation of filters for Uniswap's SwapRouter02 contract
/// @author Teahouse Finance
contract UniswapRouterFilter is AllowedTokensFilter {

    // support for multicall and multicall extended
    function multicall(bytes[] calldata data) public returns (bytes4) {
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory returndata) = address(this).delegatecall(data[i]);
            if (!success) {
                _forwardRevert(returndata);       // forward revert string
            }
            if(abi.decode(returndata, (bytes4)) != 0x59faaa03) revert("Invalid filter return value");
        }

        return MAGICVALUE;
    }

    function multicall(uint256, bytes[] calldata data) external returns (bytes4) {
        return multicall(data);
    }

    function multicall(bytes32, bytes[] calldata data) external returns (bytes4) {
        return multicall(data);
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

    // ---------------
    // V3SwapRouter
    // ---------------

    /// @dev Used as a flag for identifying msg.sender, saves gas by sending more 0 bytes
    address internal constant MSG_SENDER = address(1);

    /// @dev Used as a flag for identifying address(this), saves gas by sending more 0 bytes
    address internal constant ADDRESS_THIS = address(2);    

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    // requires recipient to be msg.sender
    // requires tokenIn and tokenOur are both in allowed tokens list
    function exactInputSingle(ExactInputSingleParams calldata params) external view returns (bytes4) {
        if (!tokenAllowed(params.tokenIn) || !tokenAllowed(params.tokenOut)) {
            revert("Token not allowed");
        }

        if (params.recipient != msg.sender && params.recipient != MSG_SENDER && params.recipient != ADDRESS_THIS) {
            revert("Outside recipient not allowed");
        }
        
        return MAGICVALUE;
    }

    // requires recipient to be msg.sender
    // requires all tokens in the path to be in allowed tokens list
    function exactInput(ExactInputParams calldata params) external view returns (bytes4) {
        if (params.recipient != msg.sender && params.recipient != MSG_SENDER && params.recipient != ADDRESS_THIS) {
            revert("Outside recipient not allowed");
        }

        if (!checkTokensInV3Path(params.path)) {
            revert("Token not allowed");
        }

        return MAGICVALUE;
    }

    // requires recipient to be msg.sender
    // requires tokenIn and tokenOur are both in allowed tokens list
    function exactOutputSingle(ExactOutputSingleParams calldata params) external view returns (bytes4) {
        if (!tokenAllowed(params.tokenIn) || !tokenAllowed(params.tokenOut)) {
            revert("Token not allowed");
        }

        if (params.recipient != msg.sender && params.recipient != MSG_SENDER && params.recipient != ADDRESS_THIS) {
            revert("Outside recipient not allowed");
        }
        
        return MAGICVALUE;
    }

    // requires recipient to be msg.sender
    // requires all tokens in the path to be in allowed tokens list
    function exactOutput(ExactOutputParams calldata params) external view returns (bytes4) {
        if (params.recipient != msg.sender && params.recipient != MSG_SENDER && params.recipient != ADDRESS_THIS) {
            revert("Outside recipient not allowed");
        }

        if (!checkTokensInV3Path(params.path)) {
            revert("Token not allowed");
        }

        return MAGICVALUE;
    }

    // check all tokens in _path are in allowed token list
    function checkTokensInV3Path(bytes memory _path) internal view returns (bool) {
        uint256 i;
        for (i = 0; i < _path.length; i += 23) {
            address token = toAddress(_path, i);
            if (!tokenAllowed(token)) {
                return false;
            }
        }

        return true;
    }

    // from BytesLib by Gonçalo Sá <goncalo.sa@consensys.net>
    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_start + 20 >= _start, "toAddress_overflow");
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    // ---------------
    // V2SwapRouter
    // ---------------
    
    // requires to to be msg.sender
    // requires all tokens in the path to be in allowed tokens list
    function swapExactTokensForTokens(
        uint256,
        uint256,
        address[] calldata path,
        address to
    ) external view returns (bytes4) {
        if (to != msg.sender && to != MSG_SENDER && to != ADDRESS_THIS) {
            revert("Outside recipient not allowed");
        }

        if (!checkTokensInV2Path(path)) {
            revert("Token not allowed");
        }

        return MAGICVALUE;
    }

    // requires recipient to be msg.sender
    // requires all tokens in the path to be in allowed tokens list
    function swapTokensForExactTokens(
        uint256,
        uint256,
        address[] calldata path,
        address to
    ) external view returns (bytes4) {
        if (to != msg.sender && to != MSG_SENDER && to != ADDRESS_THIS) {
            revert("Outside recipient not allowed");
        }

        if (!checkTokensInV2Path(path)) {
            revert("Token not allowed");
        }

        return MAGICVALUE;        
    }

    // check all tokens in _path are in allowed token list
    function checkTokensInV2Path(address[] calldata _path) internal view returns (bool) {
        uint256 i;
        for (i = 0; i < _path.length; i ++) {
            if (!tokenAllowed(_path[i])) {
                return false;
            }
        }

        return true;
    }

    // ---------------
    // WETH9 functions
    // ---------------

    // requires recipient to be msg.sender
    function unwrapWETH9(uint256, address recipient) external view returns (bytes4) {
        if (recipient != msg.sender) {
            revert("Outside recipient not allowed");
        }

        return MAGICVALUE;
    }

    // this function always send to msg.sender
    function unwrapWETH9(uint256) external pure returns (bytes4) {
        return MAGICVALUE;
    }
}
