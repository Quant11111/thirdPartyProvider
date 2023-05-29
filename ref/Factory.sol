// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Transaction.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface Index{
    function factory() public view returns(address);
}

contract Factory {
    using SafeERC20 for IERC20;

    Index public index;

    modifier onlyFactory(){
        require(address(msg.sender) == protocolIdex.transactionFactory());
        _;
    }
    modifier onlyTransaction(){
        require(isTransaction[address(msg.sender)]);
        _;
    }

    struct Transaction{
        address addr;
        bool status;
    }

    mapping(address => uint256[]) public deployedTransactions;  //link a userWallet to the transaction Ids he created
    //mapping(address => uint256[]) public transactionsToManage;  //link a 3rdP address to the transaction Ids he can manage
    mapping(uint256 => Transaction) public idToTransactions;       //link a transaction Id to the transaction address
    mapping(address => bool) public isTransaction;
    mapping(address => uint256) public addressToId;
    constructor(address _protocolIndex) {
        index = Index(_protocolIndex);
    }

    function newTransaction(uint256 _transacId, address _thirdParty, address _addr) public onlyFactory{
        idToTransactions(_transacId) = new Transaction(_addr, false)
        //transactionsToManage[_thirdParty].push(_transacId);
        deployedTransactions[tx.origin].push(_transacId);
        addressToId[_addr]=_transacId; 
        isTransaction[_addr] = true; 
    }

    function endTransaction() public onlyTransaction{
        idToTransactions[addressToId[msg.sender]].status = false;
    }
}