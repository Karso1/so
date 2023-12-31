// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

contract ViewAndPureFunctions
{
    uint public num;
    function viewFunc()external view returns (uint)//读取了链上信息，就必须用view这个关键词
    {
        return num;
    }
    function pureFunc() external pure returns (uint)
    //pure函数不会读取链上信息，只有局部变量或者什么变量都没有
    {
        return 1;
    }

    function addToNum(uint x) external view  returns(uint)
    //读取了num这个状态变量，所以是view
    {
        return num+x;
    }
    function add(uint x,uint y) external pure returns(uint)
    //只把参数进行相加，并返回，并没有读取状态变量，纯函数
    {
        return x+y;
    }
}