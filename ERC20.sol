/*
    Basic  ERC20 Token Template,
    For Ethereum or any other EVM compatible blockchain
    -
    Developed by James Galbraith, https://Decentralised.Tech/
*/

pragma solidity ^0.5.11;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Owned {
    address public owner;
    address public newOwner;
    modifier onlyOwner {
        require(msg.sender == owner, 'Address not contract owner');
        _;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner, 'Address not contract owner');
        owner = newOwner;
    }
}

contract ERC20TokenTemplate is Owned {
    using SafeMath for uint256;

    constructor() public {
        owner = msg.sender;
        // Send owner inital tokens
        uint256 initalAmount = uint256(10000).mul(10^decimals);
        balance[owner] = initalAmount;
        supply = initalAmount;
        emit Transfer(address(0), msg.sender, initalAmount);
    }

    // Owner can mint new tokens
    function mint(address to, uint256 amount) public onlyOwner {
        supply = supply.add(amount);
        balance[to] = balance[to].add(amount);
        emit Transfer(address(0), to, amount);
    }

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Main Variables
    uint256 public constant decimals = 2; // Amount of decimal places
    string public constant name = "Token Name (eg. US Dollar)";
    string public constant symbol = "Token Symbol (eg. USD)";

    bool public transfersPaused;

    function pauseTransfers(bool state) public onlyOwner {
        transfersPaused = state;
    }

    // Balance Mapping
    mapping(address => uint256) public balance;
    mapping(address => mapping(address => uint256)) public allowanceMapping;
    uint256 public supply = 0;

    function totalSupply() public view returns (uint256) {
        return supply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balance[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(transfersPaused == false, 'Transfers have been paused');
        require(balanceOf(msg.sender) >= amount, 'Sender does not have enough balance');
        balance[msg.sender] = balance[msg.sender].sub(amount);
        balance[recipient] = balance[recipient].add(amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowanceMapping[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowanceMapping[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(transfersPaused == false, 'Transfers have been paused');
        require(allowanceMapping[sender][recipient] >= amount, 'Sender has not authorised this transaction');
        require(balanceOf(sender) >= amount, 'Sender does not have enough balance');
        balance[sender] = balance[sender].sub(amount);
        balance[recipient] = balance[recipient].add(amount);
        allowanceMapping[sender][recipient] = allowanceMapping[sender][recipient].sub(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
}
