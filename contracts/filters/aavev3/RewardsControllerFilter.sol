// contracts/RewardControllerFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../BaseFilter.sol";

/// @title A simple implementation of filters for AAVE V3 OP reward contract
/// @author Teahouse Finance
contract RewardControllerFilter is BaseFilter {

    // requires to to be msg.sender
    function claimRewards(
        address[] calldata /*assets*/,
        uint256 /*amount*/,
        address to,
        address /*reward*/
    ) external view returns (bytes4) {
        if (to != msg.sender) {
            revert("Outside to not allowed");
        }

        return MAGICVALUE;
  }
}