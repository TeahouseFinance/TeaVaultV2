// contracts/CurveExchangeFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../AllowedTokensFilter.sol";

/// @title A simple implementation of filters for Curve.fi's exchange contract
/// @author Teahouse Finance
contract CurveExchangeFilter is AllowedTokensFilter {

    /// @dev Used to allow zero address in _route while performing exchange
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    /// @dev Used to allow ether in _route while performing exchange
    address constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // requires all tokens/pools in the path to be in allowed list
    function exchange(uint256 /*_amount*/, address[6] memory _route, uint256[8] memory /*_indices*/, uint256 /*_min_received*/) external view returns (bytes4) {
        if (!checkRoute(_route)) {
            revert("Token not allowed");
        }

        return MAGICVALUE;
    }

    // requires _receiver to be msg.sender
    // requires all tokens/pools in the path to be in allowed list
    function exchange(uint256 /*_amount*/, address[6] memory _route, uint256[8] memory /*_indices*/, uint256 /*_min_received*/, address _receiver) external view returns (bytes4) {
        if (!checkRoute(_route)) {
            revert("Token not allowed");
        }

        if (_receiver != msg.sender) {
            revert("Outside recipient not allowed");
        }

        return MAGICVALUE;
    }


    // check all tokens in _route are in allowed token list
    function checkRoute(address[6] memory _route) internal view returns (bool) {
        uint256 i;
        for (i = 0; i < _route.length; i += 1) {
            address token = _route[i];
            // zero address and ether are allowed
            if (token == ZERO || token == ETH) {
                continue;
            }

            if (!tokenAllowed(token)) {
                return false;
            }
        }

        return true;
    }
}