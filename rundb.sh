podman run --name ghost-mysql \
	--rm \
	-e MYSQL_ROOT_PASSWORD=my-secret-pw \
	-p 3306:3306 \
	-d mysql:5
