// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./Counters.sol";
import "./IERC2981.sol";
import "./ERC721.sol";

/**
 * @author Roi Di Segni (aka @sheeeev66)
 */

contract LazyAst is Ownable, ERC721, IERC2981 {

    // Public address of the royalty reciever:
    address private royaltyReciever;

    using Counters for Counters.Counter;
    using Strings for uint256;

    event NewLaMinted(uint id);
    event Withdrawn(address _address, uint amount);
    
    // track token ID
    Counters.Counter private _tokenId;

    // base URI
    string private baseURIcid;

    // check if the team minted or not
    bool private teamMintAvalible = true;

    constructor() ERC721("Lazy Ast", "LA") { }


    function supportsInterface(bytes4 interfaceId) public view override(ERC721, IERC165) returns (bool) {
        return
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }


    /**
     * @dev withdraw contract balance to a wallet
     * @notice won't execute if it isn't the owner who is executing the command
     * @param _address the address to withdraw to
     */
    function withdraw(address payable _address) public onlyOwner {
        emit Withdrawn(_address, address(this).balance);
        _address.transfer(address(this).balance);
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

        return string(abi.encodePacked("ipfs://", baseURIcid, "/", tokenId.toString(), ".json"));
    }

    /**
     * @dev premint for team
     * @dev 100 will be minted for the team
     * @notice the NFTs will be minted and sent to the callers address
     * @notice only the owner of the contract can call this function
     */
    function teamMint() external onlyOwner {
        require(bytes(baseURIcid).length > 0, "No IPFS CID set. Minting will be enabled once setBaseURIcid(cid) will be called");
        require(teamMintAvalible, "LazyAst: Team Mint Has already happened");
        for (uint i=0; i < 100; i++) {
            _safeMint(msg.sender, _tokenId.current());

            emit NewLaMinted(_tokenId.current());
            _tokenId.increment();
        }
        teamMintAvalible = false;
    }

    /**
     * @dev miniting the token
     * @dev makes sure that no more than 10K tokens are minted
     * @dev makes sure that at least 0.05 ether is paid before minting
     * @dev makes sure that no more than 20 tokens are minted at once
     * @param _tokenCount the ammount of tokens to mint
     */
    function safeMintLa(uint _tokenCount) public payable {
        require(bytes(baseURIcid).length > 0, "LazyAst: No IPFS CID set. Minting will be enabled once setBaseURIcid(cid) will be called");
        require(_tokenCount <= 20, "LazyAst: Can not mint more than 20 tokens at a time");
        require(_tokenCount != 0, "LazyAst: You have to mint at least 1 token");
        require(_tokenId.current() + _tokenCount <= 9899, "LazyAst: Purchace will exeed max supply of tokens");
        require(msg.value >= 50000000000000000*_tokenCount, "LazyAst: Ether value sent is not correct"); // price for 1: 0.05 eth

        for (uint i=0; i < _tokenCount; i++) {
            _safeMint(msg.sender, _tokenId.current());

            emit NewLaMinted(_tokenId.current());
            _tokenId.increment();
        }
    }

    /**
     * @dev Royalty info for the exchange to read (using EIP-2981 royalty standard)
     * @param tokenId the token Id 
     * @param salePrice the price the NFT was sold for
     * @dev returns: send a percent of the sale price to the royalty recievers address
     * @notice this function is to be called by exchanges to get the royalty information
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
        require(_exists(tokenId), "ERC2981RoyaltyStandard: Royalty info for nonexistent token");
        return (royaltyReciever, (salePrice * 300) / 10000);
    }
    
    /**
     * @dev Sets the royalty recieving address to:
     * @param _address the address the royalties are sent to
     * @notice Setting the recieving address to the zero address will result in an error
     */
    function setRoyaltyRecieverTo(address _address) public onlyOwner {
        require(_address != address(0), "LazyAst: Can not send royalties to the zero address");
        royaltyReciever = _address;
    }


}
