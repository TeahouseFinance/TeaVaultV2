// contracts/LendingPoolFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../BaseFilter.sol";

/// @title A simple implementation of filters for AAVE Lending Pool contract
/// @author Teahouse Finance
contract LendingPoolFilter is BaseFilter {

    // requires onBehalfOf to be msg.sender
    function deposit(address /*asset*/, uint256 /*amount*/, address onBehalfOf, uint16 /*referralCode*/) external view returns (bytes4) {
        if (onBehalfOf != msg.sender) {
            revert("Outside onBehalfOf not allowed");
        }

        return MAGICVALUE;
    }

    // requires to to be msg.sender
    function withdraw(address /*asset*/, uint256 /*amount*/, address to) external view returns (bytes4) {
        if (to != msg.sender) {
            revert("Outside to not allowed");
        }

        return MAGICVALUE;
    }

    // requires onBehalfOf to be msg.sender
    function borrow(address /*asset*/, uint256 /*amount*/, uint256 /*interestRateMode*/, uint16 /*referralCode*/, address onBehalfOf) external view returns (bytes4) {
        if (onBehalfOf != msg.sender) {
            revert("Outside onBehalfOf not allowed");
        }

        return MAGICVALUE;
    }

    // requires onBehalfOf to be msg.sender
    function repay(address /*asset*/, uint256 /*amount*/, uint256 /*rateMode*/, address onBehalfOf) external view returns (bytes4) {
        if (onBehalfOf != msg.sender) {
            revert("Outside onBehalfOf not allowed");
        }

        return MAGICVALUE;
    }

    // no specific restrictions
    function swapBorrowRateMode(address /*asset*/, uint256 /*rateMode*/) external pure returns (bytes4) {
        return MAGICVALUE;
    }
}