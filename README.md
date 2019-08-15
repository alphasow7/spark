# How to work with the container Spark

## Start the container

```bash
docker run -d --rm --net sparkCluster -p 4040:4040 -p 8080:8080 -p 8081:8081 -v $PWD:/root/ --name spark -h spark swal4u/spark:version-2.3.0.4
```

The master service and the slave service are started automatically.
The command mounts the app directory that you can use for your application.
Note the --rm option to destroy the container once it is finished.

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

## Add a new worker

If you want, it's possible to add more slaves.
To avoid problem, you have to choose another name and port for the container !

```bash
docker run -d --rm --net sparkCluster -p 8082:8081 -v $PWD:/root/ --name slave2 -h slave2 swal4u/spark:version-2.3.0.4 /etc/slave.sh -d 2G 1
```

I choose to add a function in my .bash_profile (OSX).

```bash
function slave-start () { docker run -d --rm --net sparkCluster -p "$2":8081 -v $PWD:/root/ --name "$1" -h "$1" swal4u/spark:version-2.3.0.4 /etc/slave.sh -d 2G 1 ; }
```

## Monitoring

It's possible to monitor the cluster on [http://127.0.0.1:8080](http://127.0.0.1:8080)
It's possible to monitor the slave on [http://127.0.0.1:8081](http://127.0.0.1:8081)
And monitor jobs on [http://127.0.0.1:4040](http://127.0.0.1:4040)

## Stop the containers

```bash
docker stop slave2 (if you started this container before)
docker stop spark
```

## Bonus

The root folder contains two interesting files.
The **.bash_history** save the bash commands on master or slave.
The **.scala_history** save the commands in spark-shell.

## Publish a new version in docker hub (for the maintainer)

```bash
git tag -a vX.Y.Z.T
git push --tags
```

Docker Hub detects a new version and build the container automatically.
