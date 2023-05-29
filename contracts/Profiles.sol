// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IIndex} from "./Interfaces/IIndex.sol";
import {IBundles} from "./Interfaces/IBundles.sol";
import {IPartners} from "./Interfaces/IPartners.sol";

contract Profiles {
    IIndex public index;
    IBundles public bundles;
    IPartners public partners;

    uint256 public nextProfileId;

    struct Profile {
        uint128 bundleId;
        string name;
        bool active;
    }

    mapping(address => Profile) public profiles;

    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    modifier onlyBundleAdmin(uint128 _bundleId) {
        _checkBundleAdmin(_bundleId);
        _;
    }

    constructor(address _index) {
        index = IIndex(_index);
        bundles = IBundles(index.bundles());
        partners = IPartners(index.partners());
        nextProfileId = 1;
    }

    function newProfile(
        uint128 _bundleId,
        address _profileAddress,
        string memory _name
    ) external onlyBundleAdmin(_bundleId) {
        require(
            bundles.getPartnerId(_bundleId) != 0,
            "Bundle must exist to create a profile"
        );
        require(
            profiles[_profileAddress].bundleId == 0,
            "Profile already exists for this address"
        );
        profiles[_profileAddress] = Profile(_bundleId, _name, true);
    }

    function revokeProfile(
        address _profileAddress
    ) external onlyBundleAdmin(profiles[_profileAddress].bundleId) {
        require(
            profiles[_profileAddress].bundleId != 0,
            "Profile does not exist for this address"
        );
        profiles[_profileAddress].active = false;
    }

    ///@notice check :
    ///if profile is active
    ///if partner is trusted
    ///if bundle is still in partner's bundle list
    ///run this function before any transaction deployment from factory
    function checkProfile(address _profileAddress) external view {
        require(profiles[_profileAddress].active, "Profile is not active");
        uint128 _bundleId = profiles[_profileAddress].bundleId;
        uint16 _partnerId = bundles.getPartnerId(_bundleId);
        require(partners.isTrusted(_partnerId), "Partner is not trusted");
        require(
            partners.getBundleBySlot(bundles.getSlot(_bundleId), _partnerId) ==
                _bundleId,
            "Bundle is not valid"
        );
    }

    function getBundleId(
        address _profileAddress
    ) external view returns (uint128) {
        return profiles[_profileAddress].bundleId;
    }

    function getProfile(
        address _profileAddress
    ) external view returns (uint128, string memory, bool) {
        return (
            profiles[_profileAddress].bundleId,
            profiles[_profileAddress].name,
            profiles[_profileAddress].active
        );
    }

    function fetchIndex() external onlyOwner {
        partners = IPartners(index.partners());
        bundles = IBundles(index.bundles());
    }

    function _checkBundleAdmin(uint128 _bundleId) internal view {
        require(bundles.getAdminAddress(_bundleId) == msg.sender);
    }

    function _checkOwner() internal view {
        require(
            index.owner() == msg.sender,
            "Only owner can call this function"
        );
    }
}
