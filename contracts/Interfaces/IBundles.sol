// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IBundles {
    function getPartnerId(uint128 _bundleId) external view returns (uint16);

    function getAdminAddress(uint128 _bundleId) external view returns (address);

    function getSlot(uint128 _bundleId) external view returns (uint8);

    function getPartnerFees(uint128 _bundleId) external view returns (uint8);

    function getProtocolFees(uint128 _bundleId) external view returns (uint8);
}
