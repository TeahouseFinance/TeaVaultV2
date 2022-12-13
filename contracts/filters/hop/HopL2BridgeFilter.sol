// contracts/HopL2BridgeFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../BaseFilter.sol";

/// @title A simple implementation of filter for Hop Exchange's L2->L1 Bridge
/// @author Teahouse Finance
contract HopL2BridgeFilter is BaseFilter {

    // swap and send
    function swapAndSend(
        uint256 /*chainId*/,
        address recipient,
        uint256 /*amount*/,
        uint256 /*bonderFee*/,
        uint256 /*amountOutMin*/,
        uint256 /*deadline*/,
        uint256 /*destinationAmountOutMin*/,
        uint256 /*destinationDeadline*/
    ) external view returns (bytes4) {
        if (recipient != msg.sender) {
            revert("Outside recipient not allowed");
        }

        return MAGICVALUE;
    }
}
