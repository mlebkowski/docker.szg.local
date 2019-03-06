all:
	cp -n .env{-dist,} || :
	./bin/configure-domain
	docker-compose up -d
	sleep 3
	./bin/add-trusted-root
	docker-compose ps
