# How to work with the container Spark

## Start the container

```bash
docker run -d --rm -p 8080:8080 -v $PWD:/root/ --name spark -h spark swal4u/spark:2.3
```

The command starts the container and mounts the app directory that you can use for your application. Note the --rm option to destroy the container once it is finished. The master service and the slave service are started automatically.

## Work with spark-shell

```bash
docker exec -it spark spark-shell --master spark://spark:7077 --executor-memory 2G
```

Connect to the container and launch the shell.

## Work with spark-submit

This is an example with the project hello-spark (default project included in swal4u/sbt image)

```bash
docker exec -it spark spark-submit --master spark://spark:7077 --executor-memory 2G --class fr.stephanewalter.hello.Connexion /app/target/scala-2.11/hello-spark_2.11-0.0.1.jar
```

## Stop the container

```bash
docker stop spark
```

## Publish a new version in docker hub

You have to push a new tag version on master branch.

```bash
git tag -a vX.Y.Z.T
git push --tags
```

Docker Hub detects a new version and build the container automatically.
