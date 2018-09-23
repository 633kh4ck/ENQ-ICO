pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";


/**
 * @title Pausable Crowdsale Smart Contract
 * @author GeekHack t.me/GeekHack
 */
contract PausableCrowdsale is Pausable, Crowdsale {
	/**
	* @dev Extend parent behavior requiring to be within not pause period
	* @param _beneficiary Token purchaser
	* @param _weiAmount Amount of wei contributed
	*/
	// solium-disable-next-line max-len
	function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused { // solhint-disable-line max-line-length
		super._preValidatePurchase(_beneficiary, _weiAmount);
	}	
}