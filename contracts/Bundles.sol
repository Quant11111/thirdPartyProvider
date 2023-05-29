// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IIndex} from "./Interfaces/IIndex.sol";
import {IPartners} from "./Interfaces/IPartners.sol";

///@dev TODO emit event when bundle is created / backup address is changed / admin address is changed

contract Bundles {
    IIndex public index;
    IPartners public partners;

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    uint128 public nextBundleId;

    struct Bundle {
        //string name;
        uint8 bundleSlot;
        uint16 partnerId;
        uint8 partnerFees;
        uint8 protocolFees;
        address adminAddress;
        address backupAddr;
    }

    mapping(uint128 => Bundle) public bundles;

    constructor(address _index) {
        index = IIndex(_index);
        partners = IPartners(index.partners());
        nextBundleId = 1;
    }

    function newBundle(
        //string memory _name,
        uint8 _bundleSlot,
        uint16 _partnerId,
        uint8 _partnerFees,
        uint8 _protocolFees,
        address _adminAddress,
        address _backupAddr
    ) external onlyOwner {
        require(_bundleSlot < 10, "Bundle slot must be between 0 and 9");
        require(
            partners.isTrusted(_partnerId),
            "Partner must be trusted to create a bundle"
        );
        bundles[nextBundleId] = Bundle(
            //_name,
            _bundleSlot,
            _partnerId,
            _partnerFees,
            _protocolFees,
            _adminAddress,
            _backupAddr
        );
        partners.setBundleId(_partnerId, nextBundleId, _bundleSlot);
        nextBundleId++;
    }

    function useBackupAddr(uint128 _bundleId) external {
        require(
            bundles[_bundleId].backupAddr == msg.sender,
            "Only backup address can call this"
        );
        bundles[_bundleId].adminAddress = msg.sender;
    }

    function setBackupAddr(uint128 _bundleId, address _backupAddr) external {
        require(
            bundles[_bundleId].adminAddress == msg.sender,
            "Only admin can call this"
        );
        bundles[_bundleId].backupAddr = _backupAddr;
    }

    function getPartnerId(
        uint128 _bundleId
    ) external view returns (uint16 partnerId) {
        return bundles[_bundleId].partnerId;
    }

    function getSlot(
        uint128 _bundleId
    ) external view returns (uint8 bundleSlot) {
        return bundles[_bundleId].bundleSlot;
    }

    function getPartnerFees(
        uint128 _bundleId
    ) external view returns (uint8 partnerFees) {
        return bundles[_bundleId].partnerFees;
    }

    function getProtocolFees(
        uint128 _bundleId
    ) external view returns (uint8 protocolFees) {
        return bundles[_bundleId].protocolFees;
    }

    function getAdminAddress(
        uint128 _bundleId
    ) external view returns (address adminAddress) {
        return bundles[_bundleId].adminAddress;
    }

    function fetchIndex() external onlyOwner {
        partners = IPartners(index.partners());
    }

    function _checkOwner() internal view {
        require(msg.sender == index.owner(), "Only owner can call this");
    }
}
