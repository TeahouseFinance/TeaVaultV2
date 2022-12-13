// contracts/PerpCurieVaultFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../AllowedTokensFilter.sol";

/// @title A simple implementation of filters for PerpCurie's Vault smart contract
/// @author Teahouse Finance
contract PerpCurieVaultFilter is AllowedTokensFilter {

    // requires token to be in allowed tokens list
    function deposit(address token, uint256 /*amount*/) external view returns (bytes4) {
        if (!tokenAllowed(token)) {
            revert("Token not allowed");
        }

        return MAGICVALUE;
    }

    // requires recipient to be msg.sender
    // requires token to be in allowed tokens list
    function depositFor(
        address to,
        address token,
        uint256 /*amount*/
    ) external view returns (bytes4) {
        if (to != msg.sender) {
            revert("Outside recipient not allowed");
        }

        if (!tokenAllowed(token)) {
            revert("Token not allowed");
        }

        return MAGICVALUE;
    }

    function depositEther() external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // requires recipient to be msg.sender
    function depositEtherFor(address to) external view returns (bytes4) {
        if (to != msg.sender) {
            revert("Outside recipient not allowed");
        }

        return MAGICVALUE;
    }

    // requires token to be in allowed tokens list
    function withdraw(address token, uint256 /*amount*/) external view returns (bytes4) {
        if (!tokenAllowed(token)) {
            revert("Token not allowed");
        }

        return MAGICVALUE;
    }

    function withdrawEther(uint256 /*amount*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }
}
