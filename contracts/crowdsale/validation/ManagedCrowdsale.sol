pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "../../access/Manager.sol";


/**
 * @title ManagedCrowdsale
 * @dev Crowdsale in which only managers from list can perform some actions.
 */
// solium-disable-next-line max-len, no-empty-blocks
contract ManagedCrowdsale is Manager, Crowdsale { // solhint-disable-line no-empty-blocks, max-line-length

}