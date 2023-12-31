// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;


//定义一个智能合约
contract Counter
{
    uint public count;

    function inc() external 
    {
        //因为已经有external外部可视，所以不能有view或者pure
        count +=1;
    }
    function dec() external 
    {
        count -= 1;
    }
}