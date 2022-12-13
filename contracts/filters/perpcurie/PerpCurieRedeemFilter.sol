// contracts/PerpCurieRedeemFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../BaseFilter.sol";

/// @title A simple implementation of filters for PerpCurie's mining reward smart contracts
/// @author Teahouse Finance
contract PerpCurieRedeemFilter is BaseFilter {

    function claimWeek(
        address _liquidityProvider,
        uint256 /*_week*/,
        uint256 /*_claimedBalance*/,
        bytes32[] calldata /*_merkleProof*/
    ) public view returns (bytes4) {
        if (_liquidityProvider != msg.sender) {
            revert("Can't redeem outsider address");
        }

        return MAGICVALUE;
    }

    struct Claim {
        uint256 week;
        uint256 balance;
        bytes32[] merkleProof;
    }

    function claimWeeks(address _liquidityProvider, Claim[] calldata /*claims*/) public view returns (bytes4) {
        if (_liquidityProvider != msg.sender) {
            revert("Can't redeem outsider address");
        }

        return MAGICVALUE;
    }
}
