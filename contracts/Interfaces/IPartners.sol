// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IPartners {
    function isTrusted(uint16 _partnerId) external view returns (bool);

    function setBundleId(
        uint16 _partnerId,
        uint128 _bundleId,
        uint8 _bundleSlot
    ) external;

    function getBundleBySlot(
        uint8 _slot,
        uint16 _partnerId
    ) external view returns (uint128);

    function getPool(uint16 _id) external view returns (address);
}
