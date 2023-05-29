// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

///@todo DONE

import {IIndex} from "./Interfaces/IIndex.sol";

contract Transactions {
    IIndex public index;

    uint256 public nextId;

    event NewTransaction(
        address indexed _buyer,
        address indexed _seller,
        address indexed _profile,
        uint256 _txnId,
        address _txnAddress,
        uint256 _amount,
        address _token,
        string _data
    );

    mapping(uint256 => address) public transactions;
    mapping(address => bool) public isTransaction;

    modifier onlyFactory() {
        _checkFactory();
        _;
    }

    constructor(address _index) {
        index = IIndex(_index);
        nextId = 1;
    }

    function newTransaction(
        address _txnAddress,
        address _buyer,
        address _seller,
        address _profile,
        uint256 _amount,
        address _token,
        string calldata _data
    ) external onlyFactory {
        transactions[nextId] = _txnAddress;
        isTransaction[_txnAddress] = true;

        emit NewTransaction(
            _buyer,
            _seller,
            _profile,
            nextId,
            _txnAddress,
            _amount,
            _token,
            _data
        );

        nextId++;
    }

    function _checkFactory() internal view {
        require(
            msg.sender == index.factory(),
            "Only the factory can call this function"
        );
    }
}
