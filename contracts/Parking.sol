pragma solidity ^0.6.3;

// import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

interface ERC20Token {
  function allowance(address, address) external returns (uint256);
  function balanceOf(address) external returns (uint256);
  function transferFrom(address, address, uint) external returns (bool);
}

contract Parking is Ownable {

    AcctCont ac; // Haven Account Contract (ac)
    ERC20Token kc; // Kudos contract (kc)
    uint256 contKudosBal; // Kudos held by contract
    
    // The address of the Natural Rights Server
    address public naturalRightsAddress;

    // The address of the Account Contract
    address public accountContractAddress;
    
    // The address of the Kudos Contract
    address public kudosContractAddress;

    // The address of the Document Contract
    address public documentContractAddress;
    
    constructor(address acctContAddr, address kudosContAddr) public {
        ac = AcctCont(acctContAddr);
        kc = ERC20Token(kudosContAddr);
    }

    // @dev Access modifier for NR-only functionality
    modifier onlyNR() {
        require(msg.sender == naturalRightsAddress, "not the NR Server");
        _;
    }

    // @dev Access modifier for NR-only functionality
    modifier onlyDocuments() {
        require(msg.sender == documentContractAddress, "not the Document Server");
        _;
    }

    struct walletStruct {
        uint256 kudosBalance; // Kudos balance
    }

    mapping (address => walletStruct) wallet; // natural rights Haven ID hash to public identifiers

    // Only contract owner may change Natural Rights Server
    function setNaturalRightsServer(address _newNaturalRights) public onlyOwner returns(bool success) {
        require(_newNaturalRights != address(0), "address must not equal 0");
        naturalRightsAddress = _newNaturalRights;
        return true;
    }

    // Only contract owner may change Account Contract Address
    function setAccountContract(address _newAcctContAddr) public onlyOwner returns(bool success) {
        require(_newAcctContAddr != address(0), "address must not equal 0");
        ac = AcctCont(_newAcctContAddr);
        return true;
    }
    
    // Only contract owner may change Kudos Contract Address
    function setKudosContract(address _newKudosContAddr) public onlyOwner returns(bool success) {
        require(_newKudosContAddr != address(0), "address must not equal 0");
        kc = ERC20Token(_newKudosContAddr);
        return true;
    }

    // Only contract owner may change Document Contract Address
    function setDocContract(address _newDocContAddr) public onlyOwner returns(bool success) {
        require(_newDocContAddr != address(0), "address must not equal 0");
        documentContractAddress = _newDocContAddr;
        return true;
    }

    // Is msg.sender authorized to sign for the account?
    function isDevAuthorized(address _acctAddr) public returns(bool isIndeed) {
        return ac.isDevAuthorized(_acctAddr, msg.sender);
    }

    // Check allowance from address to contract
    function contAllowance(address _acctAddr) public returns(uint256 value) {
        return kc.allowance(_acctAddr, address(this));
    }
    
    // Add kudos from account
    function depositKudos(address _acctAddr, uint256 value) public returns(bool success) {
        require(isDevAuthorized(_acctAddr), "msg.sender not authorized for account");
        require(kc.balanceOf(_acctAddr) >= value, "not enough tokens in sender's balance");
        require(kc.allowance(_acctAddr, address(this)) >= value, "sender has not enough allowance");
        kc.transferFrom(_acctAddr, address(this), value);
        wallet[_acctAddr].kudosBalance += value;
        contKudosBal += value;
        return true;
    }