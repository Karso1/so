// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

//构造函数
contract Constructor
{
    address public owner;
    uint public x;
    Constructor(uint _x)
    {
        owner = msg.sender;
        x = _x;
    }
    
}