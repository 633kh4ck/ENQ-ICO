ENQ ICO Smart Contracts
===================
ENQ ICO is based on the ERC20 token, [OpenZeppelin framework](https://github.com/OpenZeppelin/openzeppelin-solidity), [MultiSig Wallet (by Gnosis)](https://github.com/gnosis/MultiSigWallet) and some utilitarian contracts. All contracts use the latest stable version of the Solidity language (except dependencies, which we can't control) and have passed internal tests and audits.

![ENQ](https://raw.githubusercontent.com/633kh4ck/ENQ-ICO/master/docs/diagram.png)

## Install

``` bash
# resolve git submodules
$ git submodule update --init --recursive

# resolve multisig-wallet-gnosis dependency
$ npm i --save gnosis/MultiSigWallet # Or fix it manually by placing code in the ../MultiSigWallet directory

# install dependencies
$ npm install # Or yarn install
```

## Deploy

``` bash
# configure your infura api key & ( mnemonic || ledger )
$ cp env.example .env
$ nano .env

# configure your args (each network has separate config file)
# all args are placed in order like constructors params
$ cp config.example.json config.development.json # Or config.ropsten.json etc

# compile project
$ npm run compile # Or truffle compile (if truffle installed globally)

# deploy contracts
$ npm run migrate -- --network development # Or truffle migrate --network development (specify network)
```

## Security

All code is secure and well tested, but I take no responsibility for your implementation decisions and any security problem you might experience. All contracts are WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

## Deployed instances

- Ropsten
  - Wallet [0x5c168e6b8abe603c81884738b2584769ca791e67](https://ropsten.etherscan.io/address/0x5c168e6b8abe603c81884738b2584769ca791e67)
  - Token [0xa477e8ab83043bbee9b19d80f9b3b7cfccc2e6be](https://ropsten.etherscan.io/address/0xa477e8ab83043bbee9b19d80f9b3b7cfccc2e6be)
  - ICO [0xdb729378806b3108d72e1f3cc05e4ae45c137332](https://ropsten.etherscan.io/address/0xdb729378806b3108d72e1f3cc05e4ae45c137332)

## License

Code released under the [AGPL v3](LICENSE).
