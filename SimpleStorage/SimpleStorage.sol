// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract SimpleStorage{
    uint256 number;
    mapping (address => uint256) public people;

    function setNumber(uint256 _number) public{
        number=_number; 
        people[msg.sender]=_number;
    }

    function getNumber() public view returns(uint256){
        return number;  //returns the value of the variable number.
    }

    function getNumberOfWallet(address _address) public view returns(uint256){
        return people[_address]; //returns the value of the variable number for a specific wallet.
    }
}