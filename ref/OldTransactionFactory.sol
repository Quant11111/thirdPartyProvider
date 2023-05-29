// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Transaction.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TransactionFactory is Ownable {
    using SafeERC20 for IERC20;

    struct ThirdParty {
        uint8 commision;
        bool isTrusted;
    }

    mapping(address => ThirdParty) public thirdParties;
    mapping(address => bool) public validTokens;

    mapping(address => uint256[]) public txIds;

    uint256 public nextId = 0;
    mapping(uint256 => address) private deployedTransactions;

    modifier checkFunds(address _token, uint _amont) {
        require(
            IERC20(_token).balanceOf(msg.sender) >= _amont,
            "Not enough funds"
        );
        _;
    }
    modifier checkThirdParty(address _thirdParty) {
        require(
            thirdParties[_thirdParty].isTrusted,
            "Third party is not trusted"
        );
        _;
    }

    ///@notice The buyer create a new transaction selecting the token, the amount, the third party and the seller
    function createTransaction(
        address _token,
        uint _amont,
        address _thirdParty,
        address _seller
    )
        public
        checkFunds(_token, _amont)
        checkThirdParty(_thirdParty)
        returns (uint256)
    {
        /// @dev Create transaction contract
        uint256 _id = nextId;
        Transaction transaction = new Transaction(
            msg.sender,
            _seller,
            _thirdParty,
            IERC20(_token),
            _amont,
            thirdParties[_thirdParty].commision
        );
        /// @dev Transfer funds to the contract
        IERC20(_token).safeTransferFrom(
            msg.sender,
            address(transaction),
            _amont
        );
        /// @dev Save transaction
        deployedTransactions[_id] = address(transaction);
        txIds[msg.sender].push(_id);
        nextId++;
        return _id;
    }

    ///@notice can get the transaction contract address from its id
    function getTransaction(uint256 id) public view returns (address) {
        return deployedTransactions[id];
    }

    ///@notice The owner can set new Third Parties addresses
    function setTrustedThirdParty(
        address _address,
        bool _set,
        uint8 _commision
    ) public onlyOwner {
        require(_commision <= 100, "Commision must be less than 100"); /// @dev Could even be set to under 30% to avoid abuse
        thirdParties[_address].isTrusted = _set;
        thirdParties[_address].commision = _commision;
    }

    ///@notice The owner can set new tokens to be used
    function setValidToken(address _token, bool _set) public onlyOwner {
        validTokens[_token] = _set;
    }
}
