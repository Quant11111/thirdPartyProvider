// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./TxnLogic.sol";
import {IIndex} from "./Interfaces/IIndex.sol";
import {ITransactions} from "./Interfaces/ITransactions.sol";
//import {IERC20} from "./Library/openzeppelin/contracts/token/ERC20/IERC20.sol";
//import {SafeERC20} from "./Library/openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Factory {
    using SafeERC20 for IERC20;

    IIndex public index;
    ITransactions public transactions;

    event NewPayment(
        uint256 indexed _txnId,
        address indexed _buyer,
        address indexed _seller,
        address _profile,
        uint256 _amount,
        address _token,
        uint256 _timeStamp
    );
    event NewRefund(
        uint256 indexed _txnId,
        address indexed _buyer,
        address indexed _seller,
        address _profile,
        uint256 _amount,
        address _token,
        uint256 _timeStamp
    );

    modifier onlyTransactions(address _txnAddress) {
        _checkTransactions(_txnAddress);
        _;
    }

    constructor(address _index) {
        index = IIndex(_index);
        transactions = ITransactions(index.transactions());
    }

    function deployTxnLogic(
        address _token,
        address _buyer,
        address _seller,
        address _profile,
        uint256 _amount,
        string memory _data
    ) external {
        IERC20 token = IERC20(_token);
        token.safeTransferFrom(_buyer, address(this), _amount);
        TxnLogic txn = new TxnLogic(
            address(index),
            _token,
            _buyer,
            _seller,
            _profile,
            _amount,
            transactions.nextId()
        );
        transactions.newTransaction(
            address(txn),
            _buyer,
            _seller,
            _profile,
            _amount,
            _token,
            _data
        );
    }

    function emitPayment(
        uint256 _txnId,
        address _buyer,
        address _seller,
        address _profile,
        uint256 _amount,
        address _token
    ) external onlyTransactions(msg.sender) {
        emit NewPayment(
            _txnId,
            _buyer,
            _seller,
            _profile,
            _amount,
            _token,
            block.timestamp
        );
    }

    function emitRefund(
        uint256 _txnId,
        address _buyer,
        address _seller,
        address _profile,
        uint256 _amount,
        address _token
    ) external onlyTransactions(msg.sender) {
        emit NewRefund(
            _txnId,
            _buyer,
            _seller,
            _profile,
            _amount,
            _token,
            block.timestamp
        );
    }

    function _checkTransactions(address _txnAddress) internal view {
        require(transactions.isTransaction(_txnAddress));
    }
}
