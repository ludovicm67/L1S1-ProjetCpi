# Projet de CPI - L1S1
Projet de CPI pour l'université, pour la fin du Semestre 1 de la première année de licence.

## Exercice 1 : Recherche de similarités
_Work in progress..._

### Génération des fichiers de test
Pour effectuer des tests, il faut utiliser des fichiers avec une certaines taille. On peut en générer très facilement avec la commande `fallocate -l SIZE FILENAME`, où `SIZE` est la taille du fichier que l'on souhaite générer (ex: pour un fichier de 1 Mo environs, saisir 1M, pour un fichier de 10 Mo environs, saisir 10M), et `FILENAME` est le nom du fichier que l'on souhaite creer. Cependant cette méthode va juste créer un fichier et le remplir avec des `0` tout le long. Donc avec un simple `sort -u` (ou `sort | uniq`), on se retrouve avec deux fichiers d'une seule ligne, et ayant le même contenu.

J'ai donc fait le choix d'utiliser la commande suivante pour mes tests : `base64 /dev/urandom | head -c $((1000000*SIZE)) > FILENAME`, où `SIZE` est la taille du fichier que l'on souhaite générer (ex: 1 pour un fichier de 1 Mo, 10 pour un fichier de 10 Mo environs), et `FILENAME` est le nom du fichier que l'on souhaite creer. Du coup le fichier sera rempli avec des caractères aléatoires. Pour vérifier que le script cherchant dex similarités fonctionne bien, on peut ainsi copier quelques lignes d'un fichier et les coller dans l'autre fichier à la place d'autres lignes.

J'ai donc fait le choix de ne pas alourdir ce dépôt avec mes fichiers de test, mais j'ai expliqué comment les générer de manière très simple ci-dessus. De plus générer ces fichiers ne faisaient pas spécialement partie du sujet du projet.


## Exercice 2 : La musique c'est bien !

### Utilisation
Il suffit d'appeler le script en passant en argument le répertoire dans lequel se trouve des archives de musiques en provenance de Jamendo, que l'on souhaitera extraire. Pour cela, il faut procéder de la façon suivante : `./Exercice 2/music.sh unRepertoireOuSeTrouveDesArchivesDAlbumsJamendo`.

### Options
De plus, il est possible de passer des options, qui sont les suivantes :
 * `-h` ou `--help` pour afficher les options disponibles.
 * `-x` ou `--delete-archive` pour supprimer automatiquement les archives une fois le contenu extrait.
 * `-d` ou `--dest` pour spécifier un autre répertoire de sortie pour les extractions.
