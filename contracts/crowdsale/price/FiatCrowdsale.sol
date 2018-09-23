pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "../../utils/oraclize/oraclizeAPI.sol";


/**
 * @title Fiat Crowdsale Smart Contract
 * @author GeekHack t.me/GeekHack
 */
contract FiatCrowdsale is Ownable, Crowdsale, usingOraclize {
	string public fiatOraclizeQueryURL;
	uint public fiatScale;
	uint public fiatOraclizeQueryDelay;
	uint256 public fiatPrice;
	uint internal fiatOraclizeQueryGasLimit;
	mapping(bytes32=>bool) internal fiatOraclizeQueryValidIds;

	event FiatOraclizeQuery(uint code);
	event FiatPriceTicker(uint price, bytes proof);

	constructor(								//--######################################
		/* string _url,							//	##									##
		uint _scale,							//	##		original implementation		##
		uint _delay,							//	##		  refactoring due to		##
		uint _gasPrice,							//	##	CompilerError: Stack too deep	##
		uint _gasLimit */						//	##									##
	)											//--######################################
	public
	payable
	{ // solhint-disable-line bracket-align
		oraclize_setNetwork();
		if (keccak256(oraclize_getNetworkName()) != keccak256("")) {	
			oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
		}
		/* _setFiatOraclizeQueryURL(_url);
		if (_scale > 0) {
			_setFiatScale(_scale);
		}
		if (_delay > 0) {
			_setFiatOraclizeQueryDelay(_delay);
		}
		if (_gasPrice > 0) {
			_setFiatOraclizeQueryGasPrice(_gasPrice);
		}
		if (_gasLimit > 0) {
			_setFiatOraclizeQueryGasLimit(_gasLimit);
		}
		_updateFiatPrice(0); */
	}

	/**
	 * @dev external setter for oraclize query url
	 * @param _url oraclize query url in oraclize format
	 */
	function setFiatOraclizeQueryURL(string _url) external onlyOwner {
		_setFiatOraclizeQueryURL(_url);
	}

	/**
	 * @dev external setter for fiat scale
	 * @param _scale numbers after decimal point
	 */
	function setFiatScale(uint _scale) external onlyOwner {
		_setFiatScale(_scale);
	}

	/**
	 * @dev external setter for oraclize query delay
	 * @param _delay oraclize query delay in seconds
	 */
	function setFiatOraclizeQueryDelay(uint _delay) external onlyOwner {
		_setFiatOraclizeQueryDelay(_delay);
	}

	/**
	 * @dev external setter for oraclize query gas price
	 * @param _price oraclize query gas price in wei
	 */
	function setFiatOraclizeQueryGasPrice(uint _price) external onlyOwner {
		_setFiatOraclizeQueryGasPrice(_price);
	}

	/**
	 * @dev external setter for oraclize query gas limit
	 * @param _limit oraclize query gas limit
	 */
	function setFiatOraclizeQueryGasLimit(uint _limit) external onlyOwner {
		_setFiatOraclizeQueryGasLimit(_limit);
	}

	/**
	 * @dev fallback for restarting oraclize query loop
	 * if there isn't enough balance
	 */
	function updateFiatPrice() external payable onlyOwner {
		/* solhint-disable max-line-length */
		require(address(this).balance < oraclize_getPrice("URL", fiatOraclizeQueryGasLimit)); // solium-disable-line max-len
		require(msg.value.add(address(this).balance) >= oraclize_getPrice("URL", fiatOraclizeQueryGasLimit)); // solium-disable-line max-len
		/* solhint-enable max-line-length */
		_updateFiatPrice(0);
	}

	/**
	 * @dev fallback for manually setting fiat price
	 * can be overwritten to implement updates via bot
	 * @param _price fiat price in smallest and indivisible units
	 */
	function updateFiatPrice(uint256 _price) external onlyOwner {
		require(_price > 0);
		if (fiatPrice == _price) revert();
		fiatPrice = _price;
	}

	/**
	 * @dev fallback to deposit ether for oraclize queries
	 */
	function addFiatOraclizeQueryBalance() external payable {
		require(msg.value > 0);
	}

	/**
	 * @dev getter for fiat price
	 * @return   fiat price in smallest and indivisible units
	 */
	function getFiatPrice() public view returns (uint256) {
		return fiatPrice;
	}

	/**
	 * @dev getter for fiat rate
	 * @return   wei per one smallest and indivisible unit of fiat
	 */
	function getFiatRate() public view returns (uint256) {
		return uint256(10 ** uint256(18)).div(getFiatPrice());
	}

	/**
	 * @dev getter for fiat amount per wei amount via fiat rate
	 * @param _weiAmount in wei
	 * @return   fiat amount
	 */
	function getFiatAmount(uint256 _weiAmount) public view returns (uint256) {
		return _weiAmount.div(getFiatRate());
	}

	/**
	 * @dev getter for token rate
	 * @return   wei per one smallest and indivisible unit of token
	 */
	function getTokenRate() public view returns (uint256) {
		return rate.mul(getFiatRate()).div(10 ** _getTokenDecimals());
	}

	/**
	 * @dev getter for token amount per wei amount via fiat rate
	 * @param _weiAmount in wei
	 * @return   token amount
	 */
	function getTokenAmount(uint256 _weiAmount) public view returns (uint256) {
		return _getTokenAmount(_weiAmount);
	}

	/**
	 * @dev getter for wei amount per token amount via fiat rate
	 * @param _tokenAmount in smallest and indivisible unit of token
	 * @return   wei amount
	 */
	function getWeiAmount(uint256 _tokenAmount) public view returns (uint256) {
		return _tokenAmount.mul(getTokenRate());
	}

	/**
	 * @dev oraclize callback (can be extended to provide another oraclize
	 * query verification, the overriding function should call
	 * super.finalization() to ensure the chain of callbacks is executed
	 * entirely)
	 * @param _queryId      query unique identifier
	 * @param _result       query response
	 * @param _proof        query proof
	 */
	// solium-disable-next-line mixedcase
	function __callback(bytes32 _queryId, string _result, bytes _proof) public {
		if (msg.sender != oraclize_cbAddress()) revert();

		if (fiatOraclizeQueryValidIds[_queryId]) {
			emit FiatOraclizeQuery(200);
			fiatPrice = parseInt(_result, fiatScale);
			emit FiatPriceTicker(fiatPrice, _proof);
			delete fiatOraclizeQueryValidIds[_queryId];
			_updateFiatPrice(fiatOraclizeQueryDelay);
		}
	}

	/**
	* @dev low level token purchase ***DO NOT OVERRIDE***
	* @param _beneficiary Address performing the token purchase
	*/
	function buyTokens(address _beneficiary) public payable {

		uint256 fiatAmount = getFiatAmount(msg.value);
		_preValidatePurchase(_beneficiary, fiatAmount);

		// calculate token amount to be created
		uint256 tokens = _getTokenAmount(msg.value);

		// update state
		weiRaised = weiRaised.add(fiatAmount);

		_processPurchase(_beneficiary, tokens);
		emit TokenPurchase(
			msg.sender,
			_beneficiary,
			fiatAmount,
			tokens
		);

		_updatePurchasingState(_beneficiary, fiatAmount);

		_forwardFunds();
		_postValidatePurchase(_beneficiary, fiatAmount);
	}

	/**
	 * @dev internal setter for oraclize query url
	 * @param _url oraclize query url in oraclize format
	 */
	function _setFiatOraclizeQueryURL(string _url) internal {
		require(keccak256(_url) != keccak256(""));
		if (keccak256(fiatOraclizeQueryURL) == keccak256(_url)) revert();
		fiatOraclizeQueryURL = _url;
	}

	/**
	 * @dev internal setter for fiat scale
	 * @param _scale numbers after decimal point
	 */
	function _setFiatScale(uint _scale) internal {
		if (fiatScale == _scale) revert();
		fiatScale = _scale;
	}

	/**
	 * @dev internal setter for oraclize query delay
	 * @param _delay oraclize query delay in seconds
	 */
	function _setFiatOraclizeQueryDelay(uint _delay) internal {
		require(_delay > 0);
		if (fiatOraclizeQueryDelay == _delay) revert();
		fiatOraclizeQueryDelay = _delay;
	}

	/**
	 * @dev internal setter for oraclize query gas price
	 * @param _price oraclize query gas price in wei
	 */
	function _setFiatOraclizeQueryGasPrice(uint _price) internal {
		require(_price > 0);
		oraclize_setCustomGasPrice(_price);
	}

	/**
	 * @dev internal setter for oraclize query gas limit
	 * @param _limit oraclize query gas limit
	 */
	function _setFiatOraclizeQueryGasLimit(uint _limit) internal {
		require(_limit > 0);
		if (fiatOraclizeQueryGasLimit == _limit) revert();
		fiatOraclizeQueryGasLimit = _limit;
	}

	/**
	 * @dev internal getter for number of token decimals
	 * @return   number of token decimals
	 */
	function _getTokenDecimals() internal view returns (uint256) { // solhint-disable-line max-line-length
		return uint256(DetailedERC20(token).decimals());
	}

	/**
	 * @dev Override default behaviour to modify the way in which fiat is
	 * converted to tokens.
	 * @param _weiAmount to be converted into tokens
	 * @return   token amount
	 */
	// solium-disable-next-line max-len
	function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) { // solhint-disable-line max-line-length
		return _weiAmount.div(getTokenRate());
	}

	/**
	 * @dev initiate oraclize query with delay
	 * @param _delay in seconds
	 */
	function _updateFiatPrice(uint _delay) internal {
		// solium-disable-next-line max-len
		if (oraclize_getPrice("URL", fiatOraclizeQueryGasLimit) > address(this).balance) { // solhint-disable-line max-line-length
			emit FiatOraclizeQuery(509);
		} else {
			bytes32 queryId_ = oraclize_query(
				_delay,
				"URL",
				fiatOraclizeQueryURL,
				fiatOraclizeQueryGasLimit
			);
			fiatOraclizeQueryValidIds[queryId_] = true;
			emit FiatOraclizeQuery(102);
		}
	}
}