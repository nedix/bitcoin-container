setup:
	@test -e .env || cp .env.example .env
	@docker build --progress=plain -f Containerfile -t bitcoin .

destroy:
	-@docker rm -fv bitcoin

up: RPC_MAINNET_PORT          = "8332"
up: RPC_TESTNET_PORT          = "18332"
up: RPC_REGNET_PORT           = "18443"
up: P2P_MAINNET_PORT          = "8333"
up: P2P_TESTNET_PORT          = "18333"
up: P2P_REGNET_PORT           = "18444"
up: ZMQ_RAW_TRANSACTION_PORT  = "28332"
up: ZMQ_RAW_BLOCK_PORT        = "28333"
up: ZMQ_TRANSACTION_HASH_PORT = "28334"
up: ZMQ_BLOCK_HASH_PORT       = "28335"
up: ZMQ_MEMPOOL_SEQUENCE_PORT = "28336"
up:
	@docker run --rm -d --name bitcoin \
        --env-file .env \
        -p 127.0.0.1:$(RPC_MAINNET_PORT):8332 \
        -p 127.0.0.1:$(RPC_TESTNET_PORT):18332 \
        -p 127.0.0.1:$(RPC_REGNET_PORT):18443 \
        -p 127.0.0.1:$(P2P_MAINNET_PORT):8333 \
        -p 127.0.0.1:$(P2P_TESTNET_PORT):18333 \
        -p 127.0.0.1:$(P2P_REGNET_PORT):18444 \
        -p 127.0.0.1:$(ZMQ_RAW_TRANSACTION_PORT):28332 \
        -p 127.0.0.1:$(ZMQ_RAW_BLOCK_PORT):28333 \
        -p 127.0.0.1:$(ZMQ_TRANSACTION_HASH_PORT):28334 \
        -p 127.0.0.1:$(ZMQ_BLOCK_HASH_PORT):28335 \
        -p 127.0.0.1:$(ZMQ_MEMPOOL_SEQUENCE_PORT):28336 \
        bitcoin
	@docker logs -f bitcoin

down:
	-@docker stop bitcoin

shell:
	@docker exec -it bitcoin /bin/sh

test:
	@$(CURDIR)/tests/index.sh
