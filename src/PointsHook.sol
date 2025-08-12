// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import {ERC1155} from "solmate/src/tokens/ERC1155.sol";

import {Currency} from "v4-core/types/Currency.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId} from "v4-core/types/PoolId.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {SwapParams, ModifyLiquidityParams} from "v4-core/types/PoolOperation.sol";

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";

import {Hooks} from "v4-core/libraries/Hooks.sol";

contract PointsHook is BaseHook, ERC1155 {
    constructor(IPoolManager _manager) BaseHook(_manager) {}

    // Set up hook permissions to return `true`
    // for the two hook functions we are using
    function getHookPermissions()
        public
        pure
        override
        returns (Hooks.Permissions memory)
    {
        return
            Hooks.Permissions({
                beforeInitialize: false,
                afterInitialize: false,
                beforeAddLiquidity: false,
                beforeRemoveLiquidity: false,
                afterAddLiquidity: false,
                afterRemoveLiquidity: false,
                beforeSwap: false,
                afterSwap: true,
                beforeDonate: false,
                afterDonate: false,
                beforeSwapReturnDelta: false,
                afterSwapReturnDelta: false,
                afterAddLiquidityReturnDelta: false,
                afterRemoveLiquidityReturnDelta: false
            });
    }

    // Implement the ERC1155 `uri` function
    function uri(uint256) public view virtual override returns (string memory) {
        return "https://api.example.com/token/{id}";
    }

    mapping(address => uint256) private _swapsPerUser;
    uint256[] private _levelOfReward = [20, 10, 5, 4, 2];

    function _assignPoints(
        PoolId poolId,
        bytes calldata hookData,
        uint256 points
    ) internal {
        // If no hook data is passed in, no points will be assigned to anyone
        if (hookData.length == 0) return;

        // Extract user address from hookData
        address user = abi.decode(hookData, (address));

        // If there is hookData but not in the format we're expecting and user address is zero
        // nobody gets any points
        if (user == address(0)) return;

        // Mint points to the user
        uint256 poolIdUint = uint256(PoolId.unwrap(poolId));
        _mint(user, poolIdUint, points, "");
    }

    function calculatePoints(
        bytes calldata hookData,
        uint256 ethAmount
    ) public view returns (uint256) {
        // Extract user address from hookData
        address user = abi.decode(hookData, (address));
        uint256 userSwaps = _swapsPerUser[user];

        if (userSwaps < 1) {
            return ethAmount / (100 / _levelOfReward[4]);
        } else if (userSwaps >= 1 && userSwaps < 5) {
            return ethAmount / (100 / _levelOfReward[3]);
        } else if (userSwaps >= 5 && userSwaps < 10) {
            return ethAmount / (100 / _levelOfReward[2]);
        } else if (userSwaps >= 10 && userSwaps < 15) {
            return ethAmount / (100 / _levelOfReward[1]);
        } else if (userSwaps >= 15) {
            return ethAmount / (100 / _levelOfReward[0]);
        }
    }

    // Stub implementation of `afterSwap`
    function _afterSwap(
        address,
        PoolKey calldata key,
        SwapParams calldata swapParams,
        BalanceDelta delta,
        bytes calldata hookData
    ) internal override returns (bytes4, int128) {
        // If this is not an ETH-Token pool with this hook attached, ignore
        if (!key.currency0.isAddressZero()) return (this.afterSwap.selector, 0);

        // We only mint points if user is buying TOKEN with ETH
        if (!swapParams.zeroForOne) return (this.afterSwap.selector, 0);

        // Mint points equal to 20% of the amount of ETH they spent
        // Since its a zeroForOne swap:
        // if amountSpecified < 0:
        //  this is an "exact input for output" swap
        //  amount of ETH they spent is equal to |amountSpecified|
        // if amountSpecified > 0:
        //  this is an "exact output for input" swap
        //  amount of ETH they spent is equal to BalanceDelta.amount0()

        uint256 ethSpendAmount = uint256(int256(-delta.amount0()));
        uint256 pointsForSwap = calculatePoints(hookData, ethSpendAmount);

        // Mint the points
        _assignPoints(key.toId(), hookData, pointsForSwap);

        address user = abi.decode(hookData, (address));
        _swapsPerUser[user] += 1;

        return (this.afterSwap.selector, 0);
    }
}
