// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract Escrow{
    address public nftAddress;
    address public seller;
    address public inspector;
    address public lender;

    modifier onlyBuyer(uint256 _tokenId) {
        require(msg.sender == buyer[_tokenId], "Only buyer can call this method");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this method");
        _;
    }

    modifier onlyInspector() {
        require(msg.sender == inspector, "Only inspector can call this method");
        _;
    }

    mapping(uint=>bool) public isListed;
    mapping(uint=>uint) public purchasePrice;
    mapping(uint=>uint) public escrowAmt;
    mapping(uint=>address) public buyer;
    mapping(uint256 => bool) public inspectionPassed;
    mapping(uint256 => mapping(address => bool)) public approval;

    constructor(address _nftAddress,address _seller,address _inspector,address _lender){
        nftAddress=_nftAddress;
        seller=_seller;
        inspector=_inspector;
        lender=_lender;
    }

    //the 1st purpose of Escrow is to transfer your stuff --> contract, when you want to list {idhar list karne waala guy, is like the property seller}
    function list(uint _tokenId,address _buyer,uint _purchasePrice,uint _escrowAmt) external{ //escrowAmt is the partial price, purchasePrice is the real one 
        IERC721(nftAddress).transferFrom(msg.sender,address(this),_tokenId);
        isListed[_tokenId]=true;
        purchasePrice[_tokenId]=_purchasePrice;
        escrowAmt[_tokenId]=_escrowAmt;
        buyer[_tokenId]=_buyer;  //this is a private property selling Dapp, not a marketplace; Hence we take buyer as an input

        //basically we already know the buyer, buyer can deposit funds (nichhe dekh bkl ) sort of like downpayment
        //full downpayment hoga--> you get property
    } 

      function depositEarnest(uint256 _tokenId) public payable onlyBuyer(_tokenId) {
        require(msg.value >= escrowAmt[_tokenId]); // this is basically good faith money, that the buyer deposits to show he is serious about buying this property
    }

     function updateInspectionStatus(uint256 _tokenID, bool _passed) public onlyInspector{
        inspectionPassed[_tokenID] = _passed;
    }  //this is done by the property inspector, an irl person who will check if the property is free of damage and can be sold.

    receive() external payable { } //anyone can send money to contract, it isnt rejected (This does the work for lender)

    function approveSale(uint256 _tokenID) public {
        approval[_tokenID][msg.sender] = true;
    } //approving the sale, this needs to be called by all- buyer , seller, lender (except inspector, he has already done that)

    function finalizeSale(uint256 _tokenID) public {
        //to finalize the sale, we check all the approvals
        require(inspectionPassed[_tokenID]);
        require(approval[_tokenID][buyer[_tokenID]]);
        require(approval[_tokenID][seller]);
        require(approval[_tokenID][lender]);
        //escrow != purchase, the lender(banks etc) needs to chip in the remaining
        require(address(this).balance >= purchasePrice[_tokenID]);

        isListed[_tokenID] = false; //delists the nft

        (bool success, ) = payable(seller).call{value: address(this).balance}("");
        require(success); //transfers all the amt held by contract to the seller
 
        IERC721(nftAddress).transferFrom(address(this), buyer[_tokenID], _tokenID); //transfer
    }

      function cancelSale(uint256 _nftID) public {
        if (inspectionPassed[_nftID] == false) {
            payable(buyer[_nftID]).transfer(address(this).balance);
        } else {
            payable(seller).transfer(address(this).balance);
        }
    }


    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
