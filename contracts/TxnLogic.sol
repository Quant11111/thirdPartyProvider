// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IIndex} from "./Interfaces/IIndex.sol";
import {IBundles} from "./Interfaces/IBundles.sol";
import {IProfiles} from "./Interfaces/IProfiles.sol";
import {IFactory} from "./Interfaces/IFactory.sol";
import {IPartners} from "./Interfaces/IPartners.sol";

contract TxnLogic {
    using SafeERC20 for IERC20;

    IIndex public index;
    IBundles public bundles;
    IProfiles public profiles;
    IERC20 public token;
    IPartners public partners;

    struct Fees {
        uint256 partner;
        uint256 protocol;
    }

    Fees public fees;

    uint256 public txnId;
    uint256 public amount;
    uint256 public timeStamp;

    address public buyer;
    address public seller;
    address public profile;

    modifier onlyProfile() {
        _checkProfile();
        _;
    }
    modifier enoughFunds(uint256 _amount) {
        require(amount >= _amount, "Not enough funds");
        _;
    }
    modifier notEmpty() {
        require(amount > 0, "No funds to pay");
        _;
    }

    constructor(
        address _index,
        address _token,
        address _buyer,
        address _seller,
        address _profile,
        uint256 _amount,
        uint256 _txnId
    ) {
        index = IIndex(_index);
        token = IERC20(_token);
        bundles = IBundles(index.bundles());
        profiles = IProfiles(index.profiles());
        buyer = _buyer;
        seller = _seller;
        profile = _profile;
        amount = _amount;
        txnId = _txnId;

        fees.partner = bundles.getPartnerFees(profiles.getBundleId(profile));
        fees.protocol = bundles.getProtocolFees(profiles.getBundleId(profile));
    }

    function payAll() external onlyProfile notEmpty {
        _transfer(seller, amount);
        _emitPayment(amount);
        amount = 0;
    }

    function refundAll() external onlyProfile notEmpty {
        _transfer(buyer, amount);
        _emitRefund(amount);
        amount = 0;
    }

    function pay(uint256 _amount) external onlyProfile enoughFunds(_amount) {
        amount -= _amount;
        _transfer(seller, _amount);
        _emitPayment(_amount);
    }

    function refund(uint256 _amount) external onlyProfile enoughFunds(_amount) {
        amount -= _amount;
        _transfer(buyer, _amount);
        _emitRefund(_amount);
    }

    function _transfer(address _to, uint256 _amount) internal {
        amount -= _amount;
        uint256 protocolFees = (_amount * fees.protocol) / 100;
        uint256 partnerFees = (_amount * fees.partner) / 100;
        token.safeTransfer(_to, _amount - protocolFees - partnerFees);
        token.safeTransfer(index.protocolWallet(), protocolFees);
        token.safeTransfer(
            partners.getPool(
                bundles.getPartnerId(profiles.getBundleId(profile))
            ),
            partnerFees
        ); ///@dev maybe storing the pool address here better
    }

    function _emitRefund(uint256 _amount) internal {
        IFactory factory = IFactory(index.factory());
        factory.emitRefund(
            txnId,
            buyer,
            seller,
            profile,
            _amount,
            address(token)
        );
    }

    function _emitPayment(uint256 _amount) internal {
        IFactory factory = IFactory(index.factory());
        factory.emitPayment(
            txnId,
            buyer,
            seller,
            profile,
            _amount,
            address(token)
        );
    }

    function _checkProfile() internal view {
        require(
            msg.sender == profile ||
                msg.sender ==
                bundles.getAdminAddress(profiles.getBundleId(profile)),
            "Only the profile or his admin can call this function"
        );
    }
}
