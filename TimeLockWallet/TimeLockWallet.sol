// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import './ERC20.sol';
import './SafeMath.sol';

// On 1st Pre-sale, tokens will be given which will gets time locked for 6 months in the wallets.

contract TimeLockWallet is ERC20{
    using SafeMath for uint256;
    
    string private name;
    uint256 private decimal;
    uint256 private _totalSupply;
    address private owner;
    mapping (address => uint256) private balances;
    mapping (address => uint256) private lockTime;

    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() public{
        name = "TimeLockWallet";
        decimal = 18;
        _totalSupply = 1000000000 * 10 ** decimal;
        owner=msg.sender;
        balances[owner] = _totalSupply;
    }

    modifier onlyOwner(address _address) {
        require(_address == owner,'Not owner');
        _;
    }
    
    modifier periodOver(address _address) {
        require(now >= lockTime[_address], 'You are not allowed to withdraw/transfer before completion of locking period.');
        _;
    }

    function totalSupply() public view override returns(uint256){
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256){
        return balances[account];
    }

    function giveTokens(address recipient, uint256 amount) public onlyOwner(msg.sender) returns (bool){

        uint256 allowedTransfer = (10 * _totalSupply) / 100;

        require(balances[msg.sender] >= amount, 'Not enough balance');
        require(amount <= allowedTransfer, "Not allowed to give more than 10%");
        _transfer(msg.sender,recipient,amount);
        lockTime[recipient] = now + (60 * 60 * 24 * 30 * 6);
    }

    function transfer(address recipient, uint256 amount) public override periodOver(msg.sender) returns (bool){
        _transfer(msg.sender,recipient,amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override periodOver(sender) returns (bool){
        require(balances[sender] >= amount, 'Not enough balance');
        require(_allowances[sender][recipient] >= amount, 'Not enough allowance');
        _approve(sender, msg.sender, _allowances[sender][recipient] - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual{
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        require(balances[sender] >= amount,"You don't have funds");

        balances[sender] = balances[sender] - amount;
        balances[recipient] = balances[recipient] + amount;

        emit Transfer(sender, recipient, amount);
    }
    function allowance(address _owner, address spender) public override view returns (uint256){
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function _approve(
        address _owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(_owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }
}