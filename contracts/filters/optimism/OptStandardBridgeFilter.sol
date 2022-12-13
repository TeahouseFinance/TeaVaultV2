// contracts/OptStandardBridgeFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../BaseFilter.sol";

/// @title A simple implementation of filters Optimism's L2->L1 Bridge
/// @author Teahouse Finance
contract OptStandardBridgeFilter is BaseFilter {

    // withdraw
    function withdraw(
        address /*_l2Token*/,
        uint256 /*_amount*/,
        uint32 /*_l1Gas*/,
        bytes calldata /*_data*/
    ) external pure returns (bytes4) {
        return MAGICVALUE;
    }

    // withdrawTo
    function withdrawTo(
        address /*_l2Token*/,
        address _to,
        uint256 /*_amount*/,
        uint32 /*_l1Gas*/,
        bytes calldata /*_data*/
    ) external view returns (bytes4) {
        if (_to != msg.sender) {
            revert("Outside recipient not allowed");
        }

        return MAGICVALUE;
    }
}
