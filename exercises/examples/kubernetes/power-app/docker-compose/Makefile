run:
	docker-compose up -d --build

build:
	docker-compose build

push: build
	docker push sighup/powerapp-frontend
	docker push sighup/powerapp-backend
