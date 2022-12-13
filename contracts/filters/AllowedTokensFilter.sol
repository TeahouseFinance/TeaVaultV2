// contracts/AllowedTokensFilter.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./BaseFilter.sol";

error InvalidTokenAddress();
error InconsistentParamsLengths();


/// @title Base filter with an allowed token list
/// @author Teahouse Finance
contract AllowedTokensFilter is BaseFilter, Ownable {

    mapping(address => bool) public allowedTokens;
    bool public allowAllTokens;

    event AllowedTokenChanged(address indexed sender, address indexed token, bool status);
    event AllowAllTokensChanged(address indexed sender, bool status);

    /// @notice Enable/disable allowed token
    /// @notice Only owner can call this
    /// @param _token address of the token
    /// @param _allow true to enable, false to disable
    function assignAllowedToken(address _token, bool _allow) external onlyOwner {
        if (_token != address(0) && !Address.isContract(_token)) revert InvalidTokenAddress();

        allowedTokens[_token] = _allow;

        emit AllowedTokenChanged(msg.sender, _token, _allow);
    }

    /// @notice Enable/disable multiple allowed tokens
    /// @notice Only owner can call this
    /// @param _tokens array of addresses of the tokens
    /// @param _allows allowed settings for each token, true to enable, false to disable
    function assignAllowedTokens(address[] memory _tokens, bool[] memory _allows) external onlyOwner {
        if (_tokens.length != _allows.length) revert InconsistentParamsLengths();

        uint256 i;
        for(i = 0; i < _tokens.length; i++) {
            if (_tokens[i] != address(0) && !Address.isContract(_tokens[i])) revert InvalidTokenAddress();
            allowedTokens[_tokens[i]] = _allows[i];

            emit AllowedTokenChanged(msg.sender, _tokens[i], _allows[i]);
        }
    }

    /// @notice Enable/disable allowing all tokens
    /// @notice Only owner can call this
    /// @param _allowAllTokens true to allow all tokens, false to allow only tokens in the list
    function setAllowAllTokens(bool _allowAllTokens) external onlyOwner {
        allowAllTokens = _allowAllTokens;

        emit AllowAllTokensChanged(msg.sender, _allowAllTokens);
    }

    /// @notice check if a token is in the list
    /// @param _token address of the token
    /// @return allowed true if allowed, false if not
    function tokenAllowed(address _token) public view returns (bool allowed) {
        return allowAllTokens || allowedTokens[_token];
    }
}
