// contracts/ERC20Filter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./BaseFilter.sol";

error InvalidSpenderAddress();
error InconsistentParamsLengths();

/// @title A simple implementation of filters for ERC20 tokens
/// @author Teahouse Finance
contract ERC20Filter is BaseFilter, Ownable {

    mapping(address => bool) public allowedApprovals;

    event AllowedSpenderUpdated(address indexed sender, address indexed spender, bool status);

    /// @notice Enable/disable allowed spender
    /// @notice Only owner can call this
    /// @param _spender address of the spender
    /// @param _allow true to enable, false to disable
    function assignAllowedSpender(address _spender, bool _allow) external onlyOwner {
        if (_spender != address(0) && !Address.isContract(_spender)) revert InvalidSpenderAddress();

        allowedApprovals[_spender] = _allow;

        emit AllowedSpenderUpdated(msg.sender, _spender, _allow);
    }

    /// @notice Enable/disable multiple allowed spenders
    /// @notice Only owner can call this
    /// @param _spenders array of addresses of the spenders
    /// @param _allows allowed settings for each spender, true to enable, false to disable
    function assignAllowSpenders(address[] memory _spenders, bool[] memory _allows) external onlyOwner {
        if (_spenders.length != _allows.length) revert InconsistentParamsLengths();

        uint256 i;
        for(i = 0; i < _spenders.length; i++) {
            if (_spenders[i] != address(0) && !Address.isContract(_spenders[i])) revert InvalidSpenderAddress();
            allowedApprovals[_spenders[i]] = _allows[i];

            emit AllowedSpenderUpdated(msg.sender, _spenders[i], _allows[i]);
        }
    }

    // Check spender is in allowed list
    function approve(address _spender, uint256) external view returns (bytes4) {
        if (allowedApprovals[_spender]) {
            return MAGICVALUE;
        }
        
        revert("Spender not approved");
    }
}
