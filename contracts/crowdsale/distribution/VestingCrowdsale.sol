pragma solidity 0.4.24;

/* solhint-disable max-line-length */
import "openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "openzeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol"; // solium-disable-line max-len
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/TokenVesting.sol";
import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
/* solhint-enable max-line-length */


/**
 * @title Vesting Crowdsale Smart Contract
 * @author GeekHack t.me/GeekHack
 */
contract VestingCrowdsale is Ownable, Crowdsale, MintedCrowdsale {
	uint256 public vestingStart;
	uint256 public vestingCliff;
	uint256 public vestingDuration;
	bool public vestingRevocable;
	mapping(address=>address) public vestingWallets;

	event VestingWalletCreated(address beneficiary, address wallet);

	/* constructor(
		uint256 _start,
		uint256 _cliff,
		uint256 _duration,						//--######################################
		bool _revocable							//	##									##
	)											//	##		original implementation		##
	public										//	##		  refactoring due to		##
	{ // solhint-disable-line bracket-align		//	##	CompilerError: Stack too deep	##
		_setVestingStart(_start);				//	##									##
		_setVestingCliff(_cliff);				//--######################################
		_setVestingDuration(_duration);
		if (_revocable) {
			_setVestingRevocable(_revocable);
		}
	} */

	/**
	 * @dev external setter for vesting start
	 * @param _start time (as Unix time) at which point vesting starts
	 */
	function setVestingStart(uint256 _start) external onlyOwner {
		_setVestingStart(_start);
	}

	/**
	 * @dev external setter for vesting cliff
	 * @param _cliff duration in seconds in which tokens will begin to vest
	 */
	function setVestingCliff(uint256 _cliff) external onlyOwner {
		_setVestingCliff(_cliff);
	}

	/**
	 * @dev external setter for vesting duration
	 * @param _duration in seconds of the period in which the tokens will vest
	 */
	function setVestingDuration(uint256 _duration) external onlyOwner {
		_setVestingDuration(_duration);
	}

	/**
	 * @dev external setter for vesting revocable
	 * @param _revocable whether the vesting is revocable or not
	 */
	function setVestingRevocable(bool _revocable) external onlyOwner {
		_setVestingRevocable(_revocable);
	}

	/**
	 * @dev external setter for vesting wallet
	 * @param _beneficiary token purchaser
	 * @param _vesting     vesting wallet
	 */
	// solium-disable-next-line max-len
	function setVestingWallet(address _beneficiary, address _vesting) external onlyOwner { // solhint-disable-line max-line-length
		_setVestingWallet(_beneficiary, _vesting);
	}

	/**
	 * @dev getter for vesting wallet
	 * @param  _beneficiary token purchaser
	 * @return              vesting wallet
	 */
	// solium-disable-next-line max-len
	function getVestingWallet(address _beneficiary) public view returns (address) { // solhint-disable-line max-line-length
		return vestingWallets[_beneficiary];
	}

	/**
	 * @dev check if vesting wallet exists
	 * @param  _beneficiary token purchaser
	 * @return true if vesting wallet exists
	 */
	// solium-disable-next-line max-len
	function hasVestingWallet(address _beneficiary) public view returns (bool) { // solhint-disable-line max-line-length
		return getVestingWallet(_beneficiary) != address(0);
	}

	/**
	 * @dev internal setter for vesting start
	 * @param _start time (as Unix time) at which point vesting starts
	 */
	function _setVestingStart(uint256 _start) internal {
		require(_start > 0);
		if (vestingStart == _start) revert();
		vestingStart = _start;
	}

	/**
	 * @dev internal setter for vesting cliff
	 * @param _cliff duration in seconds in which tokens will begin to vest
	 */
	function _setVestingCliff(uint256 _cliff) internal {
		require(_cliff > 0);
		if (vestingCliff == _cliff) revert();
		vestingCliff = _cliff;
	}

	/**
	 * @dev internal setter for vesting duration
	 * @param _duration in seconds of the period in which the tokens will vest
	 */
	function _setVestingDuration(uint256 _duration) internal {
		require(_duration > 0);
		if (vestingDuration == _duration) revert();
		vestingDuration = _duration;
	}

	/**
	 * @dev internal setter for vesting revocable
	 * @param _revocable whether the vesting is revocable or not
	 */
	function _setVestingRevocable(bool _revocable) internal {
		if (vestingRevocable == _revocable) revert();
		vestingRevocable = _revocable;
	}

	/**
	 * @dev internal setter for vesting wallet
	 * @param _beneficiary token purchaser
	 * @param _vesting     vesting wallet
	 */
	// solium-disable-next-line max-len
	function _setVestingWallet(address _beneficiary, address _vesting) internal { // solhint-disable-line max-line-length
		require(_beneficiary != address(0));
		require(_vesting != address(0));
		require(!hasVestingWallet(_beneficiary));
		
		vestingWallets[_beneficiary] = _vesting;
	}

	/**
	* @dev Overrides default behaviour to modify the way in which
	* the crowdsale ultimately sends its tokens upon purchase.
	* @param _beneficiary Address performing the token purchase
	* @param _tokenAmount Number of tokens to be minted
	*/
	function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
		address vestingWallet_ = getVestingWallet(_beneficiary);
		if (vestingWallet_ == address(0)) {
			// solium-disable-next-line max-len
			vestingWallet_ = new TokenVesting(_beneficiary, vestingStart, vestingCliff, vestingDuration, vestingRevocable); // solhint-disable-line max-line-length
			_setVestingWallet(_beneficiary, vestingWallet_);
			emit VestingWalletCreated(_beneficiary, vestingWallet_);
		}
		// Potentially dangerous assumption about the type of the token.
		MintableToken(address(token)).mint(vestingWallet_, _tokenAmount);
	}
}