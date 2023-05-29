// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IIndex {
    function bundles() external view returns (address);

    function factory() external view returns (address);

    function partners() external view returns (address);

    function profiles() external view returns (address);

    function transactions() external view returns (address);

    function owner() external view returns (address);

    function protocolWallet() external view returns (address);
}
