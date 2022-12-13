// contracts/StethCallFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../ERC20Filter.sol";

/// @title A simple implementation of filters for Ribbon's stETH covered call contract
/// @author Teahouse Finance
contract StethCallFilter is ERC20Filter {

    // no specific restrictions
    function depositETH() external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // no specific restrictions
    function depositYieldToken(uint256 /*amount*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // requires creditor to be msg.sender
    function depositYieldTokenFor(uint256 /*amount*/, address creditor) external view returns (bytes4) {
        if (creditor != msg.sender) {
            revert("Outside creditor not allowed");
        }

        return MAGICVALUE;
    }

    // requires creditor to be msg.sender
    function depositFor(address creditor) external view returns (bytes4) {
        if (creditor != msg.sender) {
            revert("Outside creditor not allowed");
        }

        return MAGICVALUE;
    }

    // no specific restrictions
    function redeem(uint256 /*numShares*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // no specific restrictions
    function maxRedeem() external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // no specific restrictions
    function withdrawInstantly(uint256 /*amount*/, uint256) external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // no specific restrictions
    function initiateWithdraw(uint256 /*numShares*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // no specific restrictions
    function completeWithdraw() external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // no specific restrictions
    function stake(uint256 /*numShares*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }
}