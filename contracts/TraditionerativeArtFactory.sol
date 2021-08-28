// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @author Roi Di Segni (aka Sheeeev66)
 * @dev tga - Tradition(al Gen)erative Art
 */

contract TraditionerativeArtFactory is Ownable, ERC721, IERC2981 {

    using Counters for Counters.Counter;
    using SafeMath for uint256;
    event NewTgaMinted(uint tgaId, uint dna, bytes32 _ipfsHash);
    event withdrawn(address _address, uint amount);

    uint dnaDigits = 8;
    uint dnaModulus = 10 ** dnaDigits;
    // percentage for rotalties:
    uint public bp = 500; // 5% in basis points (parts per 10,000)
    
    Counters.Counter private _tokenId;

    constructor() ERC721("TraditionerativeArt", "TGA") { }
    
    /**
     * @dev Makes sure that no more than 10K tokens are created
     */
    modifier enforceSupply() {
        require(_tokenId.current() <= 9999);
        _;
    }

    function withdraw(address payable _address) public onlyOwner {
        uint contractBal = address(this).balance;
        _address.transfer(contractBal);
        emit withdrawn(_address, contractBal);
    }

    function tokenURI(uint256 tokenId, bytes32 _ipfsHash) public view virtual returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _ipfsHash)) : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "ipfs://";
    }

    /**
     * @param _to address to mint to
     * @param _ipfsHash IPFS hash for metadata
     */
    function safeMintTga(address _to, bytes32 _ipfsHash) public payable enforceSupply onlyOwner {
        _safeMint(_to, _tokenId.current());
        emit NewTgaMinted(_tokenId.current(), _generateRandomDna(_to), _ipfsHash);
        _tokenId.increment();
    }
    
    /**
     * @param _address the address of the person who minted.
     * @dev Generates random number for the DNA by using the timestamp, block difficulty, block number, coinbase and the adress of the person who minted.
     */
    function _generateRandomDna(address _address) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(block.coinbase, block.difficulty, block.number, block.timestamp, _address)));
        return rand % dnaModulus;
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
        require(tokenId <= 9999);
        return (address(0), salePrice * bp / 10000);
    }
    


}