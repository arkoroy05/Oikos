// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract RealEstate is ERC721URIStorage {
    uint256 public ID;

    constructor() ERC721("RealEstate", "REAL"){ //collection ka naam
    }
   
    function mint(string memory tokenURI) external returns(uint256){
        ID++; //increment the ID directly
        _safeMint(msg.sender, ID);  //basic NFT minting
        _setTokenURI(ID, tokenURI); //sets the tokenURI for the particular ID
        return(ID);
    }

    function totalSupply() external view returns (uint256) {
        return ID;
    }
}
