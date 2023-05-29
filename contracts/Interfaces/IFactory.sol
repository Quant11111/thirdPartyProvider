// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IFactory {
    function emitPayment(
        uint256 _txnId, //
        address _buyer,
        address _seller,
        address _profile,
        uint256 _amount,
        address _token
    ) external;

    function emitRefund(
        uint256 _txnId,
        address _buyer,
        address _seller,
        address _profile,
        uint256 _amount,
        address _token
    ) external;
}
