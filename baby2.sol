//SPDX-License-Identifier: MIT

pragma solidity ^ 0.8.7;

//上下文抽象函数，提供了用于获取消息发送者和消息数据的内部函数
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


//拥有者控制的函数，提供设置，获取，放弃所有权的功能
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
//ERC-20的标准接口，定义了转账，授权，查询余额等基本功能
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
//ERC-20代币的元数据接口，用于获取代币名称，符号，小数位数
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}



/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
 //这些接口定义了与pancakeswap相关的合约，包括，工厂，交易对，路由。
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IPancakeV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}




/**
 * @dev Implementation of the {IERC20} interface.
 */
 //主合约，用于实现上述的抽象合约和接口
contract ERC20_SAFU is Context, Ownable, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address => uint256) private _balances;
    mapping(address  => mapping(address  => uint256)) private _allowances;
    uint256 private _totalSupply;

    //定义了代币的名称和符号
    string private _name = "BABY2";
    string private _symbol = "Ba2";

    //pancakeswap details
    //用于存储薄饼的流动池地址和路由地址
    address public lpPair;
    IPancakeRouter02 public router;

    //taxation details
    //税费的相关设置，包括是否排除某个钱包，营销钱包，买卖手续费，阈值
    mapping(address => bool) private _excludeFromFee;
    address public marketingWallet = 0xb98c8bF051014aFC51e806F568c45BB70CB387D0;
    address public secondMarketingWallet = 0xb98c8bF051014aFC51e806F568c45BB70CB387D0;
    //0x07Bf895f984d3F08aeACc3285f10AF2b17190990
    //0xefd8bb69ab5c0b022b1d33120ddd1dac3a83877e
    uint256 public buyFee = 50;
    uint256 public sellFee = 50;
    uint256 private _denominator = 1000;
    uint256 public swapThreshold;
    bool public activeThreshold = true;
    bool inSwap;

    //在函数执行期间，锁定或者防止重入攻击（攻击者试图多次执行合约以绕过合约逻辑
    //确保在函数执行期间不会被其他函数中断
    modifier lockSwap () {
        inSwap = true;
        _;
        inSwap = false;
    }



    /**
     * @dev Sets the values for {totalSupply} through mint.
     * The value of {_totalSupply} is changeable and can only increase on further mint
     */
     //构造函数，在构造函数中进行一些初始化工作，如设置路由地址，创建流动性池，设置初始总供应量。
    constructor() {
        if (block.chainid == 56) {
            router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        } else if (block.chainid == 97) {
            router = IPancakeRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        } else if (block.chainid == 1 || block.chainid == 4 || block.chainid == 3) {
            router = IPancakeRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else if (block.chainid == 42161) {
            router = IPancakeRouter02(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
        } else if (block.chainid == 5) {
            router = IPancakeRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else {
            revert("Chain not valid");
        }
        lpPair = IPancakeFactory(router.factory()).createPair(router.WETH(), address(this));
        
        _excludeFromFee[_msgSender()] = true;
        _excludeFromFee[address(this)] = true; 
        
        _totalSupply = 420_000_000_000_000 * 10 ** decimals();
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
        
        swapThreshold = _totalSupply / 10_000;
    }


    //以下的函数用于查询代币的基本信息，如名称，简写，小数位数，总供应量，某个地址的余额
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }
    //这些函数实现了 ERC-20 标准的代币转账、授权、授权转账等功能
    function transfer(
        address to, 
        uint256 value
    ) public virtual override returns (bool) {
        address holder = _msgSender();
        _transfer(holder, to, value);
        return true;
    }
    function allowance(
        address holder, 
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[holder][spender];
    }
    function approve(
        address spender, 
        uint256 value
    ) public virtual override returns (bool) {
        address holder = _msgSender();
        _approve(holder, spender, value);
        return true;
    }
    function transferFrom(
        address from, 
        address to, 
        uint256 value
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
    //这些是内部函数，用于实现代币转账时的一些逻辑，包括税费的扣除、授权的处理等
    function _transfer(
        address from, 
        address to, 
        uint256 value
    ) internal {

        uint256 _contractBalance = _balances[address(this)];
        if(
            from != lpPair &&
            _contractBalance >= swapThreshold &&
            !inSwap &&
            activeThreshold
        ) {
            _swapAndSendFee(_contractBalance);
        }

        uint256 fromBalance = _balances[from];

        if (fromBalance < value) {
            revert ERC20InsufficientBalance(from, fromBalance, value);
        }
        unchecked {
            // Overflow not possible: value <= fromBalance <= totalSupply.
            _balances[from] = fromBalance - value;
        }
        
        value = _takeTax(from, to, value);

        unchecked {
            // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
            _balances[to] += value;
        }

        emit Transfer(from, to, value);
    }

    function _approve(
        address holder, 
        address spender, 
        uint256 value
    ) internal {
        _allowances[holder][spender] = value;
        emit Approval(holder, spender, value);
    }

    function _spendAllowance(
        address holder, 
        address spender, 
        uint256 value
    ) internal virtual {
        uint256 currentAllowance = allowance(holder, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(holder, spender, currentAllowance - value);
            }
        }
    }

    function _takeTax(
        address from, 
        address to, 
        uint256 amount
    ) internal returns(uint256){
        if(_excludeFromFee[from] || _excludeFromFee[to]) return amount;

        if(from != lpPair && to != lpPair) return amount;

        uint256 _fee;

        if(from == lpPair) {
            _fee = buyFee;
        }

        if(to == lpPair) {
            _fee = sellFee;
        }

        uint256 _tFee =  (amount * _fee) / _denominator;

        if(_tFee != 0) {
            _balances[address(this)] = _balances[address(this)] + _tFee;
            emit Transfer(from, address(this), _tFee);
        }

        return (amount - _tFee);
    }
    //用于将手续费兑换为 BNB，并将bnb发送到营销钱包
    function _swapBackToBNB(
        uint256 contractBalance
    ) internal {
        //通过定义两个地址，第一个是代币地址，第二个是路由地址中WETH的地址，如WETH,WBNB
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        //授权薄饼路由合约花费代币
        _approve(address(this), address(router), contractBalance);

        //调用薄饼路由合约的swapExactTokensForETHSupportingFeeOnTransferTokens函数
        //将合约中的代币兑换成BNB，包括交易路径，最少输出数量，接收地址和截止时间设定
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractBalance, 
            0, 
            path, 
            address(this), 
            block.timestamp
        );
    }

    function _swapAndSendFee(
        uint256 contractBalance
    ) internal lockSwap {

        _swapBackToBNB(contractBalance);

        uint256 _balance = address(this).balance;
        
        if(_balance != 0) {
            payable(marketingWallet).transfer(_balance/2);
            payable(secondMarketingWallet).transfer(_balance / 2);
        }
    }
    //更新阈值
    event UpdateActiveThreshold(bool _activeThreshold);
    function updateActiveThreshold(
        bool _activeThreshold
    ) external onlyOwner {
        activeThreshold = _activeThreshold;
        emit UpdateActiveThreshold(_activeThreshold);
    }
    //免税
    event ExcludedFromFee(address indexed account, bool _exclude);
    function updateFeeExcluded(
        address account, 
        bool _exclude
    ) external onlyOwner {
        _excludeFromFee[account] = _exclude;
        emit ExcludedFromFee(account, _exclude);
    }


    receive() external payable{}

}