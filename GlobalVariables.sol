// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

contract GlobalVariables
{
    //全局变量,不需要定义就能使用
    function globalVars() external view returns (address,uint,uint)
    {
        //第一个全局变量，展示账户内容
        address sender = msg.sender;//msg.sender是全局变量，表示调用这个函数的地址是什么，所以定义一个地址接收她
        uint timestamp = block.timestamp;//这个全局变量表示这个区块的时间戳，是一个只读变量，是uint类型,所以定义一个接受
        uint blockNum = block.number;//区块编号，也是uint类型，所以顶一个一个uint接受她
        return (sender,timestamp,blockNum);
    }
}