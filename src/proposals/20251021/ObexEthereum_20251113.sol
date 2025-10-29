// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.25;

import { Ethereum, ObexPayloadEthereum } from "src/libraries/ObexPayloadEthereum.sol";

import { MainnetControllerInit, ControllerInstance } from "lib/obex-alm-controller/deploy/MainnetControllerInit.sol";

import { MainnetController } from "lib/obex-alm-controller/src/MainnetController.sol";

/**
 * @title    November 13, 2025 Obex Ethereum Proposal
 * @notice Activate Obex Liquidity Layer - initiate ALM system, set rate limits, onboard SyrupUSDC
 * @author Obex Labs
 //TODO: Update forum post and vote link
 */
contract ObexEthereum_20251113 is ObexPayloadEthereum {

    address public constant SYRUP_USDC_VAULT  = 0x80ac24aA929eaF5013f6436cdA2a7ba190f5Cc0b;
    address public constant OZONE_OEA_RELAYER = 0x2b1D60B11B7015fB83361a219BE01B7564436054;

    uint256 internal constant INITIAL_USDS_MINT_MAX   = 250_000_000e18;
    uint256 internal constant INITIAL_USDS_MINT_SLOPE = 50_000_000e18 / uint256(1 days);

    uint256 internal constant INITIAL_USDS_TO_USDC_MAX   = 250_000_000e6;
    uint256 internal constant INITIAL_USDS_TO_USDC_SLOPE = 50_000_000e6 / uint256(1 days);

    uint256 internal constant INITIAL_SYRUP_USDC_DEPOSIT_MAX   = 250_000_000e6;
    uint256 internal constant INITIAL_SYRUP_USDC_DEPOSIT_SLOPE = 50_000_000e6 / uint256(1 days);

    uint256 internal constant INITIAL_SYRUP_USDC_REDEEM_MAX = type(uint256).max;


    function _execute() internal override {
        _initiateAlmSystem();
        _setupBasicRateLimits();
        _onboardSyrupUSDC();
    }

    function _initiateAlmSystem() private {
        MainnetControllerInit.MintRecipient[] memory mintRecipients = new MainnetControllerInit.MintRecipient[](0);
        MainnetControllerInit.LayerZeroRecipient[] memory layerZeroRecipients = new MainnetControllerInit.LayerZeroRecipient[](0);
        MainnetControllerInit.CentrifugeRecipient[] memory centrifugeRecipients = new MainnetControllerInit.CentrifugeRecipient[](0);
        address[] memory relayers = new address[](2);
        relayers[0] = Ethereum.ALM_RELAYER;
        relayers[1] = OZONE_OEA_RELAYER;

        MainnetControllerInit.initAlmSystem({
            vault: Ethereum.ALLOCATOR_VAULT,
            usds: Ethereum.USDS,
            controllerInst: ControllerInstance({
                almProxy   : Ethereum.ALM_PROXY,
                controller : Ethereum.ALM_CONTROLLER,
                rateLimits : Ethereum.ALM_RATE_LIMITS
            }),
            configAddresses: MainnetControllerInit.ConfigAddressParams({
                freezer       : Ethereum.ALM_FREEZER, 
                relayers      : relayers, 
                oldController : address(0)
            }),
            checkAddresses: MainnetControllerInit.CheckAddressParams({
                admin      : Ethereum.OBEX_PROXY,
                proxy      : Ethereum.ALM_PROXY,
                rateLimits : Ethereum.ALM_RATE_LIMITS,
                vault      : Ethereum.ALLOCATOR_VAULT,
                psm        : Ethereum.PSM,
                daiUsds    : Ethereum.DAI_USDS,
                cctp       : Ethereum.CCTP_TOKEN_MESSENGER
            }),
            mintRecipients: mintRecipients,
            layerZeroRecipients: layerZeroRecipients,
            centrifugeRecipients: centrifugeRecipients
        });
    }

    function _setupBasicRateLimits() private {
        _setUSDSMintRateLimit(
            INITIAL_USDS_MINT_MAX,
            INITIAL_USDS_MINT_SLOPE
        );
        _setUSDSToUSDCRateLimit(
            INITIAL_USDS_TO_USDC_MAX,
            INITIAL_USDS_TO_USDC_SLOPE
        );
    }
    function _onboardSyrupUSDC() private {
         _onboardSyrupUSDC({
            syrupUSDCVault: SYRUP_USDC_VAULT,
            depositMax:     INITIAL_SYRUP_USDC_DEPOSIT_MAX,
            depositSlope:   INITIAL_SYRUP_USDC_DEPOSIT_SLOPE,
            redeemMax:      INITIAL_SYRUP_USDC_REDEEM_MAX,
            redeemSlope:    0 
         });
    }

}
