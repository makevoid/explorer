# Blockchain Explorer

### (BTC, LTC, DOGE etc. compatible)


Based off the Bitcoin Core JSON RPC API.

It uses bitcoin's default JSON RPC API, meaning that you need `bitcoind` / `bitcoin-qt` running in background with `txindex=1` enabled, the explorer will use the data directly from the index, no extra index is added.


### Prerequisites

- redis
- bitcoin-core (btc, bch, ltc, doge, etc...)


# API

This project includes also an API:

**API_PATH:** http://example.explorer.com/api/

### GET /blocks/:block_number

Retrieves block info including all the following fields: `block, hash, confirmations, size, height, version, versionHex, merkleroot, time, mediantime, nonce, bits, difficulty, chainwork, nextblockhash`

Plus on `tx` you will get an array containing all the transaction hashes of the transactions included in the block

#### Few examples:

Genesis block: http://example.explorer.com/api/blocks/0

Pre-fork block: http://example.explorer.com/api/blocks/556765

### GET /blocks_latest_num

Gets the latest block number, sample response:

```{
  "block_num": 556766
}
```

### GET /txs/:tx_id

Gets all the information contained in a transaction such as: `txid, hash, size, version, locktime` and then all the `inputs` (`vin`) and `outputs` (`vout`).


---


# Local Development Setup


### Install Dependencies

    bundle


### Run

    bundle exec rackup

or

    rackup


## Docker

#### Build locally:

   docker-compose up --build

### or, get it from dockerhub:

URL: https://hub.docker.com/r/makevoid/explorer

```
docker pull makevoid/explorer

docker run -e
```


### Bitcoin Core configuration (bitcoind / bitcoin-qt) (valid for BTC bitcoind, Bitcoin "Core" ABC, Bitcoin "Core" SV)

This is a sample `~/.bitcoin/bitcoin.conf` to make sure this `explorer` can connect and get all the infos from your `bitcoind` / `bitcoin-qt` whatever chain is on.

```
txindex=1
rpcuser=bitcoinrpc
rpcpassword=YOUR_PASSWORD
rpcallowip=YOUR_IP
```

`rpcallowip` is used to whitelist IPs, you can have multiple lines for `rpcallowip` (for example if you have multiple application servers for high/availabilty or horizontal scaling)


Note that for a recent version of BTC bitcoind/bitcoin-qt (bitcoin core) you will need to use `rpcauth` instead of `rpcuser/rcppassword`.
