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

    struct openingStruct {
        uint256 spaceId; // Space ID of Opening
        uint256[2] timestamps; // [beginTsHash, endTsHash]
        uint256[2] spaceLinks; // [headId, tailId] Linked List of space openings head and tail (0 if head and/or tail)
        uint256 value; // cost of the opening
    }

    mapping (uint256 => uint256[2]) space; // spaceId (uint256) to Opening Linked List [head, tail]
    mapping (uint256 => openingStruct) opening; // opening (uint256) to opening struct
    mapping (uint256 => address) spaceOwner; // owner of parking space

    function addOwner(uint256 _spaceId, address _owner) public onlyOwner returns(bool success) {
        spaceOwner[_spaceId] = _owner;
        return true;
    }

    function addOpening(uint256 _begTimestamp, 
                        uint256 _endTimestamp,
                        uint256 _openingHead,
                        uint256 _openingTail,
                        uint256 _spaceId,
                        uint256 _openingId,
                        uint256 _value
                        ) public returns(bool success) {
        
        require(spaceOwner[_spaceId] == msg.sender, 'Space not owned by msg.sender');
        if(space[_spaceId][0] == 0 && _openingHead == uint256(0) && _openingTail == uint256(0)) {
            space[_spaceId] = [_openingId, _openingId];
            opening[_openingId].timestamps = [_begTimestamp, _endTimestamp];
            opening[_openingId].value = _value;
            return true;
        }
        
        if(_openingHead == uint256(0)) {
            require(opening[_openingTail].timestamps[0] > _endTimestamp, 'Opening is not before all others');
            space[_spaceId][0] = _openingId;
            opening[_openingId].timestamps = [_begTimestamp, _endTimestamp];
            opening[_openingId].spaceLinks[1] = _openingTail;
            opening[_openingTail].spaceLinks[0] = _openingId;
            opening[_openingId].value = _value;
            return true;
        }

        if(_openingTail == uint256(0)) {
            require(opening[_openingHead].timestamps[1] < _begTimestamp, 'Opening is not before all others');
            space[_spaceId][1] = _openingId;
            opening[_openingId].timestamps = [_begTimestamp, _endTimestamp];
            opening[_openingId].spaceLinks[0] = _openingHead;
            opening[_openingHead].spaceLinks[1] = _openingId;
            opening[_openingId].value = _value;
            return true;
        }

        require(opening[_openingHead].spaceLinks[1] == opening[_openingTail].spaceLinks[0], 'Opening is not between head and tail');
        require(opening[_openingHead].timestamps[1] < _begTimestamp, 'Opening is not after head');
        require(opening[_openingTail].timestamps[0] > _endTimestamp, 'Opening is not before tail');
        opening[_openingId].timestamps = [_begTimestamp, _endTimestamp];
        opening[_openingId].spaceLinks = [_openingHead, _openingTail];
        opening[_openingHead].spaceLinks[1] = _openingId;
        opening[_openingTail].spaceLinks[0] = _openingId;
        opening[_openingId].value = _value;
        return true;
    }

    function buyOpening(uint256 _openingId) public returns(bool) {
        require(pc.balanceOf(msg.sender) >= opening[_openingId].value, "not enough tokens in sender's balance");
        require(pc.allowance(msg.sender, address(this)) >= opening[_openingId].value, "sender has not enough allowance");
        uint256 value = opening[_openingId].value;
        uint256 spaceId = opening[_openingId].spaceId;
        address openingOwner = spaceOwner[spaceId];
        pc.transferFrom(msg.sender, openingOwner, value);
        return true;
    }
}