// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IProfiles {
    function checkProfile(address _addr) external view;

    function getBundleId(address _addr) external view returns (uint128);
}
