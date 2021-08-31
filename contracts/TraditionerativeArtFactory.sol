// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @author Roi Di Segni (aka Sheeeev66)
 * @dev tga - Tradition(al Gen)erative Art
 */

contract TraditionerativeArtFactory is Ownable, ERC721, IERC2981 {

    using Counters for Counters.Counter;

    event NewTgaMinted(uint tgaId, uint dna, bytes32 _ipfsHash);
    event withdrawn(address _address, uint amount);

    // DNA modulus: 10 in the power of "dna digits"
    uint32 dnaModulus = 10 ** 8;
    
    // track token ID
    Counters.Counter private _tokenId;

    constructor() ERC721("TraditionerativeArt", "TGA") { }


    /**
     * @dev withdraw contract balance to a wallet
     * @dev wouldn't execute if it isn't the owner who is executing the command
     * @param _address the address to withdraw to
     */
    function withdraw(address payable _address) public onlyOwner {
        uint contractBal = address(this).balance;
        _address.transfer(contractBal);
        emit withdrawn(_address, contractBal);
    }

    /**
     * @dev adding the IPFS hash where the metadata is stored to the base URI
     * @param tokenId The token ID
     * @param _ipfsHash the hash to where the metadata is stored on IPFS
     * @return token URI
     */
    function tokenURI(uint256 tokenId, bytes32 _ipfsHash) public view virtual returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _ipfsHash)) : "";
    }

    /**
     * @dev setting base URI
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return "ipfs://";
    }

    /**
     * @dev miniting the token
     * @dev makes sure that no more than 10K tokens are minted
    m* @param _to address to mint to
     * @param _ipfsHash IPFS hash for metadata
     */
    function safeMintTga(address _to, bytes32 _ipfsHash) public payable {
        require(_tokenId.current() <= 9999);
        _safeMint(_to, _tokenId.current());
        emit NewTgaMinted(_tokenId.current(), _generateRandomDna(_to), _ipfsHash);
        _tokenId.increment();
    }
    
    /**
     * @dev Generates random number for the DNA by using the timestamp, block difficulty, block number, coinbase and the adress of the person who minted.
     * @param _address the address of the person who minted.
     * @return random DNA
     */
    function _generateRandomDna(address _address) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(block.coinbase, block.difficulty, block.number, block.timestamp, _address)));
        return rand % dnaModulus;
    }

    /**
     * @dev Royalty info for the exchange to read (using EIP-2981 royalty standard)
     * @dev This is to provide the NFTs utility. NFT that burns ether and as a result makes its value increase.
     * @param tokenId the token Id 
     * @param salePrice the price the NFT was sold for
     * @dev return: send 5% royalty to address 0SS
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
        require(_exists(tokenId), "ERC2981RoyaltyStandard: Royalty info for nonexistent token");
        return (address(0), salePrice * 500 /*percentage in basis points (5%)*/ / 10000);
    }
    


}