// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IIndex} from "./Interfaces/IIndex.sol";

///@dev TODO? emit event when pool admin or backup is changed

contract Partners {
    IIndex index;

    uint16 private nextPartnerId;

    struct Partner {
        string name;
        uint128[10] bundleList;
        bool isTrusted;
        address pool; ///@notice address where the partner fees are sent
        address admin;
        address backup;
        uint256 joiningDate;
    }

    mapping(uint16 => Partner) public partners; // partner id => partner struct
    mapping(string => uint16) public partnerIds; // partner name => partner id

    event NewPartner(
        string indexed name,
        uint16 indexed id,
        uint256 joiningDate,
        address admin,
        address backup,
        address pool
    );

    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    modifier onlyBundles() {
        _checkBundles();
        _;
    }
    modifier uniqueName(string memory _name) {
        _checkUniqueName(_name);
        _;
    }

    constructor(address _index) {
        index = IIndex(_index);
        nextPartnerId = 1;
    }

    ///@notice Admin functions
    function newPartner(
        string memory _name,
        address _admin,
        address _backup,
        address _pool
    ) external onlyOwner uniqueName(_name) {
        require(partnerIds[_name] == 0, "Partner name already exists");
        partners[nextPartnerId].name = _name;
        partners[nextPartnerId].isTrusted = true;
        partners[nextPartnerId].joiningDate = block.timestamp;
        partnerIds[_name] = nextPartnerId;
        partners[nextPartnerId].admin = _admin;
        partners[nextPartnerId].backup = _backup;
        partners[nextPartnerId].pool = _pool;
        emit NewPartner(
            _name,
            nextPartnerId,
            block.timestamp,
            _admin,
            _backup,
            _pool
        );
        nextPartnerId++;
    }

    function updateAdmin(uint16 _id) external {
        require(msg.sender == partners[_id].backup, "Only backup can update");
        partners[_id].admin = msg.sender;
    }

    function setBackup(uint16 _id, address _newBackup) external {
        require(msg.sender == partners[_id].admin, "Only admin can update");
        partners[_id].backup = _newBackup;
    }

    function setIsTrusted(uint16 _id) external onlyOwner {
        partners[_id].isTrusted = !(partners[_id].isTrusted);
    }

    function isTrusted(uint16 _partnerId) external view returns (bool) {
        return partners[_partnerId].isTrusted;
    }

    function getPartnerId(string memory _name) external view returns (uint16) {
        return partnerIds[_name];
    }

    function getPool(uint16 _id) external view returns (address) {
        return partners[_id].pool;
    }

    function getPartner(
        uint16 _id
    )
        external
        view
        returns (string memory, uint128[10] memory, bool, address, uint256)
    {
        return (
            partners[_id].name,
            partners[_id].bundleList,
            partners[_id].isTrusted,
            partners[_id].pool,
            partners[_id].joiningDate
        );
    }

    function setBundleId(
        uint16 _partnerId,
        uint128 _bundleId,
        uint8 _bundleSlot
    ) external onlyBundles {
        require(_bundleSlot < 10, "Bundle slot must be between 0 and 9");
        partners[_partnerId].bundleList[_bundleSlot] = _bundleId;
    }

    function getBundleFromSlot(
        uint8 _slot,
        uint16 _partnerId
    ) external view returns (uint128) {
        require(_slot < 10, "Bundle slot must be between 0 and 9");
        return partners[_partnerId].bundleList[_slot];
    }

    function _checkOwner() internal view {
        require(
            index.owner() == msg.sender,
            "Ownable: caller is not the owner"
        );
    }

    function _checkBundles() internal view {
        require(
            index.bundles() == msg.sender,
            "Ownable: caller is not the bundle contract"
        );
    }

    function _checkUniqueName(string memory _name) internal view {
        require(partnerIds[_name] == 0, "Partner name already exists");
    }
}
