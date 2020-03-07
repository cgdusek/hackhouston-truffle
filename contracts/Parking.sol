pragma solidity ^0.6.3;

// import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

interface ERC20Token {
  function allowance(address, address) external returns (uint256);
  function balanceOf(address) external returns (uint256);
  function transferFrom(address, address, uint) external returns (bool);
}

contract Parking is Ownable {

    ERC20Token pc; // Parxos contract (pc)
    
    constructor(address parxosContAddr) public {
        pc = ERC20Token(parxosContAddr);
    }
     
    struct reservationStruct {
        address customer; // used address that the space is reserved to
        uint256[2] timestamps; // [beggining, ending]  All reservation and opening times are indicated by these types of pairs
    }

    struct openingStruct {
        uint256[2] timestamps; // [beginTsHash, endTsHash]
        uint256[2] spaceLinks; // [headId, tailId] Linked List of space openings head and tail (0 if head and/or tail)

    }

    mapping (uint256 => uint256[2]) space; // spaceId (uint256) to Opening Linked List [head, tail]
    mapping (uint256 => openingStruct) opening; // opening (uint256) to opening struct
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

    function addOpening(uint256 _begTimestamp, 
                        uint256 _endTimestamp,
                        uint256 _openingHead,
                        uint256 _openingTail,
                        uint256 _spaceId,
                        uint256 _openingId,
                        ) public returns(bool success) {
        
        require(owner(_spaceId) == msg.sender, 'Space not owned by msg.sender');
        if(space[_spaceId][0] == 0 && _openingHead == uint256(0) && _openingTail == uint256(0)) {
            space[_spaceId] = [_openingId, _openingId];
            opening[_openingId].timestamps = [_begTimestamp, _endTimestamp];
            return true;
        }
        
        if(_openingHead == uint256(0)) {
            require(space[_openingTail].timestamps[0] > _endTimestamp, 'Opening is not before all others')
            space[_spaceId][0] = _openingId
            opening[_openingId].timestamps = [_begTimestamp, _endTimestamp];
            opening[_openingId].spaceLinks[1] = _openingTail;
            return true;
        }

        if(_openingTail == uint256(0)) {
            require(space[_openingHead].timestamps[1] < _begTimestamp, 'Opening is not before all others')
            space[_spaceId][1] = _openingId
            opening[_openingId].timestamps = [_begTimestamp, _endTimestamp];
            opening[_openingId].spaceLinks[0] = _openingHead;
            return true;
        }

        require(space[_openingHead]._openingTail == space[_openingTail]._openingHead), 'Opening is not between head and tail')
        require(space[_openingHead].timestamps[1] < _begTimestamp, 'Opening is not after head')
        require(space[_openingTail].timestamps[0] > _endTimestamp, 'Opening is not before tail')
        opening[_openingId].timestamps = [_begTimestamp, _endTimestamp];
        opening[_openingId].spaceLinks = [_openingHead, _openingTail];
        return true;
    }