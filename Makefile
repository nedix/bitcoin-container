setup:
	@test -e .env || cp .env.example .env
	@docker build --progress=plain -f Containerfile -t bitcoin .

up: PORT = 8332
up:
	@docker run --rm --name bitcoin \
        --env-file .env \
        -p 127.0.0.1:$(PORT):8332 \
        bitcoin

down:
	-@docker stop bitcoin

shell:
	@docker exec -it bitcoin /bin/sh
