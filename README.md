# How to work with the container Spark

## Start the container

```bash
docker run -d --rm -p 8080:8080 -v $PWD/app:/root/app --name spark -h spark swal4u/spark:2.3
```

The command starts the container and mounts the app directory that you can use for your application. Note the --rm option to destroy the container once it is finished. The master service and the slave service are started automatically.

## Work with spark-shell

```bash
docker exec -it spark spark-shell --master spark://spark:7077 --executor-memory 2G
```

Connect to the container and launch the shell.

