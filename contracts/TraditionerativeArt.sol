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

contract TraditionerativeArt is Ownable, ERC721, IERC2981 {

    using Counters for Counters.Counter;

    event NewTgaMinted(uint tgaId, uint dna);
    event withdrawn(address _address, uint amount);

    // DNA modulus: 10 in the power of "dna digits" (in this case: 8)
    uint32 dnaModulus = 10 ** 8;
    
    // track token ID
    Counters.Counter private _tokenId;

    // mapping from token ID to DNA
    mapping(uint32 => uint32) idToDna;

    constructor() ERC721("TraditionerativeArt", "TGA") { }


    function supportsInterface(bytes4 interfaceId) public view override(ERC721, IERC165) returns (bool) {
        return
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }


    /**
     * @dev withdraw contract balance to a wallet
     * @dev won't execute if it isn't the owner who is executing the command
     * @param _address the address to withdraw to
     */
    function withdraw(address payable _address) public onlyOwner {
        uint contractBal = address(this).balance;
        _address.transfer(contractBal);
        emit withdrawn(_address, contractBal);
    }

    /**
     * @dev setting base URI
     */
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmQ4JMu5ePj89AxhSznsMyknZHoWchVyLTZTp18TbUUa4x/metadata/";
    }

    /**
     * @dev miniting the token
     * @dev makes sure that no more than 10K tokens are minted
    m* @param _to address to mint to
     */
    function safeMintTga(address _to) public payable {
        require(_tokenId.current() <= 9999, "No more tokens avalible");
        require(msg.value >= 0.01 ether, "Ether value sent is not correct");

        uint32 randDna = _generateRandomDna(_to);
        uint32 id = uint32(_tokenId.current());

        _safeMint(_to, id);

        // set the id to dna
        idToDna[id] = randDna;

        emit NewTgaMinted(id, randDna);
        _tokenId.increment();
    }
    
    /**
     * @dev Generates random number for the DNA by using the timestamp, block difficulty, block number and the adress of the person who minted.
     * @param _address the address of the person who minted.
     * @return random DNA
     */
    function _generateRandomDna(address _address) private view returns (uint32) {
        uint rand = uint(keccak256(abi.encodePacked(block.difficulty, block.number, block.timestamp, _address)));
        return uint32(rand % dnaModulus);
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
