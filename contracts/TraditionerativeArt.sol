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
    using Strings for uint256;

    event NewTgaMinted(uint tgaId);
    event Withdrawn(address _address, uint amount);
    
    // track token ID
    Counters.Counter private _tokenId;

    // Loanch (when true its loanched)
    bool private launch;

    // base URI
    string private baseURIcid;

    constructor() ERC721("Traditionerative Art", "TGA") { }


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
        _address.transfer(address(this).balance);
        emit Withdrawn(_address, address(this).balance);
    }

    /**
     * @dev this function should be called after *all the art is generated* and uploaded to IPFS.
     * @notice calling this function enables minting!! So don't call it unless you are sure.
     * @notice RECOMMENDED NOT TO CALL THIS FUNCTION UNTILL ALL THE ART IS UPLOADED TO IPFS!!
     */
    function setBaseURIcid(string memory cid) public onlyOwner {
        baseURIcid = cid;
    }

    /**
     * @dev overriding this to return ipfs URI with a set CID
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return bytes(baseURIcid).length > 0 ? string(abi.encodePacked("ipfs://", baseURIcid, "/", tokenId.toString(), ".json")) : "";
    }

    /**
     * @dev 20 tokens
     */
    function ownerMintAndLaunch() public onlyOwner {
        require(bytes(baseURIcid).length > 0, "TraditionerativeArt: No IPFS CID set. Minting will be enabled once setBaseURIcid(cid) will be called");
        require(launch == false, "TraditionerativeArt: Already Loanched");
    
        for (uint i=0; i < _tokenCount; i++) {
            require(_tokenId.current() <= 19, "TraditionerativeArt: No more tokens avalible");

            _safeMint(msg.sender, _tokenId.current());

            emit NewTgaMinted(_tokenId.current());
            _tokenId.increment();
        }
        loanch = false;
    }
    }
    
    /**
     * @dev 100 tokens
     */
    function preMint() public {
        
    }

    /**
     * @dev miniting the token
     * @dev makes sure that no more than 10K tokens are minted
     * @dev makes sure that at least 0.01 ether is paid before minting
     * @dev makes sure that no more than 20 tokens are minted at once
     * @param _tokenCount the ammount of tokens to mint
     */
    function safeMintTga(uint _tokenCount) public payable {
        require(launch, "TraditionerativeArt: Minting has not yet started");
        require(_tokenCount <= 20, "TraditionerativeArt: Can't mint more than 20 tokens at a time");
        require(_tokenCount != 0, "TraditionerativeArt: You have to mint at least 1 token");
        require(msg.value >= 10000000000000000*_tokenCount, "TraditionerativeArt: Ether value sent is not correct"); // price for 1: 0.01 eth

        for (uint i=0; i < _tokenCount; i++) {
            require(_tokenId.current() <= 9879, "TraditionerativeArt: No more tokens avalible");

            _safeMint(msg.sender, _tokenId.current());

            emit NewTgaMinted(_tokenId.current());
            _tokenId.increment();
        }
    }
    

    /**
     * @dev Royalty info for the exchange to read (using EIP-2981 royalty standard)
     * @dev This is to provide the NFTs utility. NFT that burns ether and as a result makes its value increase.
     * @param tokenId the token Id 
     * @param salePrice the price the NFT was sold for
     * @dev return: send 5% royalty to the zero address
     * @notice this function is to be called by exchanges to get the royalty information.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
        require(_exists(tokenId), "ERC2981RoyaltyStandard: Royalty info for nonexistent token");
        return (address(0), salePrice * 500 /*percentage in basis points (5%)*/ / 10000);
    }


    /**
     * @dev get if the caller owns an NFT
     */
    function isTokenHolder() external view returns(bool) {
        /*
        // This is where we will store the result:
        bool result;
        // Loop through all the NFTs to check if the function caller holds any tokens:
        for (uint i = 0; i <= _tokenId.current();) {
            if (msg.sender == ownerOf(i)) {
                result = true;
                // Update "i" to be higher than the current supply to exit the loop
                i = _tokenId.current() + 1;
            } else {
                result = false;
                i++;
            }
        }
        return result;
        */
        /*
        if (balanceOf(msg.sender) > 0) {
            return true;
        } else {
            return false;
        }
        */
        return (balanceOf(msg.sender) > 0) ? true : false;

        // lmao dont laugh at me.. I was writing this function when I was half asleep
    }

}
