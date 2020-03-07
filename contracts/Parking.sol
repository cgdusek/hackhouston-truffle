pragma solidity ^0.6.3;

// import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

interface ERC721Token {
    function safeTransferFrom(address, address, uint256) // (from, to, tokenId)
    function approve(address, uint256) // )approved NFT controller, tokenId)
}

interface ERC20Token {
  function allowance(address, address) external returns (uint256);
  function balanceOf(address) external returns (uint256);
  function transferFrom(address, address, uint) external returns (bool);
}

contract Parking is Ownable {

    ERC20Token pc; // Parxos contract (pc)
    
    constructor(address parxosContAddr, address spaxosContAddr) public {
        pc = ERC20Token(parxosContAddr);
        sc = ERC721Token(spaxosContAddr);
    }
     
    struct reservationStruct {
        address customer; // used address that the space is reserved to
        uint256[2] timestamps; // [beggining, ending]  All reservation and opening times are indicated by these types of pairs
    }

    mapping (uint256 => uint256[]) space; // spaceId (uint256) to openings
    mapping (uint256 => reservationStruct) reservation; // reservationId (uint256) to reservation struct
    mapping (address => uint256[]) reservations; // customer reservations
    mapping (uint256 => address) owner; // owner of parking space
    mapping (address => uint256[]) owned; // spaces owned by user address
       
    // transfer Parxos
    function transferParxos(address _fromAddr, address _toAddr) public returns(bool success) {
        require(pc.balanceOf(_acctAddr) >= value, "not enough tokens in sender's balance");
        require(pc.allowance(_acctAddr, address(this)) >= value, "sender has not enough allowance");
        pc.transferFrom(_fromAddr, _toAddr, value);
        return true;
    }