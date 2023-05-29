// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

///---DONE---///

import "@openzeppelin/contracts/access/Ownable.sol";

contract Index is Ownable {
    address public bundles;
    address public factory;
    address public partners;
    address public profiles;
    address public transactions;

    address public protocolWallet;

    constructor() {}

    function setBundles(address _addr) external onlyOwner {
        bundles = _addr;
    }

    function setFactory(address _addr) external onlyOwner {
        factory = _addr;
    }

    function setPartners(address _addr) external onlyOwner {
        partners = _addr;
    }

    function setProfiles(address _addr) external onlyOwner {
        profiles = _addr;
    }

    function setTransactions(address _addr) external onlyOwner {
        transactions = _addr;
    }

    function setProtocolWallet(address _addr) external onlyOwner {
        protocolWallet = _addr;
    }
}
