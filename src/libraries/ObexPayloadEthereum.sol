// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import { Ethereum }  from "lib/obex-address-registry/src/Ethereum.sol";

import { IExecutor } from "lib/obex-gov-relay/src/interfaces/IExecutor.sol";

import { ObexLiquidityLayerHelpers } from "./ObexLiquidityLayerHelpers.sol";

/**
 * @dev Base smart contract for Ethereum.
 * @author Obex Labs
 * @author Forked from Steakhouse Financial
 */
abstract contract ObexPayloadEthereum {


    function execute() external {
        _execute();
    }

    function _execute() internal virtual;

    function _encodePayloadQueue(address _payload) internal pure returns (bytes memory) {
        address[] memory targets        = new address[](1);
        uint256[] memory values         = new uint256[](1);
        string[] memory signatures      = new string[](1);
        bytes[] memory calldatas        = new bytes[](1);
        bool[] memory withDelegatecalls = new bool[](1);

        targets[0]           = _payload;
        values[0]            = 0;
        signatures[0]        = 'execute()';
        calldatas[0]         = '';
        withDelegatecalls[0] = true;

        return abi.encodeCall(IExecutor.queue, (
            targets,
            values,
            signatures,
            calldatas,
            withDelegatecalls
        ));
    }

    function _onboardERC4626Vault(address vault, uint256 depositMax, uint256 depositSlope) internal {
        ObexLiquidityLayerHelpers.onboardERC4626Vault(
            Ethereum.ALM_RATE_LIMITS,
            vault,
            depositMax,
            depositSlope
        );
    }


    function _onboardSyrupUSDC(
        address syrupUSDCVault,
        uint256 depositMax,
        uint256 depositSlope,
        uint256 redeemMax,
        uint256 redeemSlope) internal {
        ObexLiquidityLayerHelpers.onboardSyrupUSDC({
            rateLimits:     Ethereum.ALM_RATE_LIMITS,
            syrupUSDCVault: syrupUSDCVault,
            depositMax:     depositMax,
            depositSlope:   depositSlope,
            redeemMax:      redeemMax,
            redeemSlope:    redeemSlope
        });
    }


    function _setUSDSMintRateLimit(uint256 maxAmount, uint256 slope) internal {
        ObexLiquidityLayerHelpers.setUSDSMintRateLimit(
            Ethereum.ALM_RATE_LIMITS,
            maxAmount,
            slope
        );
    }

    function _setUSDSToUSDCRateLimit(uint256 maxAmount, uint256 slope) internal {
        ObexLiquidityLayerHelpers.setUSDSToUSDCRateLimit(
            Ethereum.ALM_RATE_LIMITS,
            maxAmount,
            slope
        );
    }



}
