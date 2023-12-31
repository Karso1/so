//SPDX-License-Identifier:MIT
//版权声明

//声明合约文件的版本
pragma solidity ^0.8.7;

//Data types -values and references

contract ValueTypes
{
    bool pubilc b = true;
    uint pubilc u = 123;//uint = uint256 ,0到2的256次方-1
                        //       uint8，0 to 2**8 -1

    int public i = -123;//int = int256 -2**256 to 2**255-1
    int public minInt = type(int).min;
    int public maxInt = type(int).max;
    //地址，16进制数字，address public addr = 0x
    //字节，32位数字bytes32 public b32 = 0x.....
}