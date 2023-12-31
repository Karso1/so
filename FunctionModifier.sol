// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;
contract FunctionModifier
{
    bool public paused;
    uint public count;

    function setPause(bool _paused) external
    {
        paused = _paused;
    }

    modifier whenNotPaused()
    {
        require(!paused,"paused");
        _;
    }

    function inc() external whenNotPaused{
        count += 1;
    }
    function dec()external {
        count -= 1;
    }
}