// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

//权限管理合约

contract Ownable
{
    address public owner;

    constructor()
    {
        owner = msg.sender;
    }

    modifier onlyOwner()
    {
        require(msg.sender == owner,"not owner");
        _;//_ 表示函数中其他代码在下划线出开始运行

    }

    function setOwner(address _newOwner) external onlyOwner{
        require(_newOwner != address(0),"invalid address");
        owner = _newOwner;
    }

}