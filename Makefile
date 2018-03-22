# Install docker on Ubuntu systems and set docker group to the current user 
install:
	sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo apt-key fingerprint 0EBFCD88
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	sudo apt-get update
	sudo apt-get install docker-ce
	sudo groupadd docker
	sudo usermod -aG docker $USER

build:
	docker build -t zephyr-base .

run:
	docker run -it --entrypoint /bin/bash zephyr-base

exec:
	docker exec -it 4fbc5b8cee43 bash
 