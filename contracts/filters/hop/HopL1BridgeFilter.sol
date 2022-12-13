// contracts/HopL1BridgeFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../BaseFilter.sol";

/// @title A simple implementation of filter for Hop Exchange's L1->L2 Bridge
/// @author Teahouse Finance
contract HopL1BridgeFilter is BaseFilter {

    // send to L2
    function sendToL2(
        uint256 /*chainId*/,
        address recipient,
        uint256 /*amount*/,
        uint256 /*amountOutMin*/,
        uint256 /*deadline*/,
        address relayer,
        uint256 relayerFee
    ) external view returns (bytes4) {
        if (recipient != msg.sender) {
            revert("Outside recipient not allowed");
        }

        if (relayer != address(0)) {
            revert("Relayer not allowed");
        }

        if (relayerFee != 0) {
            revert("Relayer not allowed");
        }

        return MAGICVALUE;
    }
}
