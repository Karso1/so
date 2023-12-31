//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

contract FunctionIntro
{

    //external表示只能在外部读取的函数
    //pure表示纯函数，表示这个函数只能有局部变量，不对链上进行任何读写操作
    function add(uint x,uint y) external pure returns(uint)
    {
        return x+y;
    } 
    function sub(uint x,uint y) external pure returns (uint)
    {
        return x-y;
    }
    
}