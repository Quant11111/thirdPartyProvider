// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IIndex} from "./Interfaces/IIndex.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Transaction {
    using SafeERC20 for IERC20;

    address public buyer;
    address public seller;
    address public thirdParty;
    IERC20 public token;
    uint256 public amont;
    string public linkToData;

    modifier onlyThirdParty() {
        require(
            msg.sender == thirdParty,
            "Only third party can call this function"
        );
        _;
    }
    modifier checkFunds(uint _amont) {
        require(_amont <= amont, "Not enough funds");
        _;
    }

    constructor(
        address _buyer,
        address _seller,
        address _thirdParty,
        IERC20 _token,
        uint256 _amont
    ) {
        // constructor
        buyer = _buyer;
        seller = _seller;
        thirdParty = _thirdParty;
        token = _token;
        amont = _amont;
    }

    function pay(uint _amont) public onlyThirdParty checkFunds(_amont) {
        amont -= _amont;
        token.safeTransferFrom(thirdParty, seller, _amont);

        ///@dev todo calculate and send commision
    }

    function refund(uint _amont) public onlyThirdParty checkFunds(_amont) {
        amont -= _amont;
        token.safeTransferFrom(thirdParty, buyer, _amont);

        ///@dev todo calculate and send commision
    }

    function payAll() public onlyThirdParty {
        ///pay all and close the transaction
    }
}
