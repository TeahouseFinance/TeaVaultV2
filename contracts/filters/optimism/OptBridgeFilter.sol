// contracts/OptBridgeFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../BaseFilter.sol";

/// @title A simple implementation of filters Optimism's L1->L2 Bridge
/// @author Teahouse Finance
contract OptBridgeFilter is BaseFilter {

    // deposit ETH
    function depositETHTo(
        address _to,
        uint32 /*_l2Gas*/,
        bytes calldata /*_data*/
    ) external view returns (bytes4) {
        if (_to != msg.sender) {
            revert("Outside recipient not allowed");
        }

        return MAGICVALUE;
    }

    // deposit ERC20
    function depositERC20To(
        address /*_l1Token*/,
        address /*_l2Token*/,
        address _to,
        uint256 /*_amount*/,
        uint32 /*_l2Gas*/,
        bytes calldata /*_data*/
    ) external view returns (bytes4) {
        if (_to != msg.sender) {
            revert("Outside recipient not allowed");
        }

        return MAGICVALUE;
    }
}
