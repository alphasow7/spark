# Procédure pour créer un container spark

## Démarrer le container

```bash
docker run -d --rm -p 8080:8080 -v $PWD/app:/root/app --name spark -h spark swal4u/spark:2.3
```

La commande démarre le container et monte le répertoire app que vous pourrez utiliser pour votre application.
A noter l'option --rm pour détruire le container une fois qu'il est terminé.
Le service master et le service slave sont lancés automatiquement.

## Utiliser le spark-shell

```bash
docker exec -it spark spark-shell --master spark://spark:7077 --executor-memory 2G
```

Permet de se connecter à notre container et de lancer le shell.

