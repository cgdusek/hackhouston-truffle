pragma solidity ^0.6.3;

// import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract Parxos is ERC20 {
    
    string public name = "Parxos Token";
    string public symbol = "PRX";
    uint8 public decimals = 18;

    // 10 million
    uint256 public constant INITIAL_SUPPLY = 10000000;

    constructor () public {
        uint256 totalSupply = INITIAL_SUPPLY * (10 ** uint256(decimals));
        _mint(msg.sender, totalSupply);
    }
}