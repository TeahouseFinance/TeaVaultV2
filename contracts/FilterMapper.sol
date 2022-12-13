// contracts/FilterMapper.sol
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./IFilterMapper.sol";

error InvalidContractAddress();
error InvalidFilterAddress();

/// @title A simple implementation of IFilterMapper
/// @author Teahouse Finance
contract FilterMapper is IFilterMapper, Ownable {

    mapping(address => address) private filterMappings;

    event FilterMappingUpdated(address indexed sender, address indexed contractAddr, address filter);

    function assignFilterMapping(address _contract, address _filter) external onlyOwner {
        if (!Address.isContract(_contract)) revert InvalidContractAddress();
        if (_filter != address(0) && !Address.isContract(_filter)) revert InvalidFilterAddress();

        filterMappings[_contract] = _filter;

        emit FilterMappingUpdated(msg.sender, _contract, _filter);
    }

    function mapFilter(address _contract) external override view returns(address) {
        return filterMappings[_contract];
    }
}
