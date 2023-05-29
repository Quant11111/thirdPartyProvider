// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ITransactions {
    function isTransaction(address _txnAddress) external view returns (bool);

    function newTransaction(
        address _txnAddress,
        address _buyer,
        address _seller,
        address _profile,
        uint256 _amount,
        address _token,
        string calldata _data
    ) external;

    function nextId() external view returns (uint256);
}
