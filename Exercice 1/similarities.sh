#!/bin/bash

DISPLAY_SIMILARITIES=false

# Analyse des différentes options
OPTS=`getopt --options v --long view \
        -n "similarities" -- "$@"`
eval set -- "$OPTS"
while true; do
  case "$1" in
    -v | --view)  DISPLAY_SIMILARITIES=true; shift;;
    -- )  shift; break;;
    *)    break
  esac
done


# On vérifie que l'on a bien deux fichiers passés en argument
if [ $# -ne 2 ] || [ ! -f "$1" ] || [ ! -f "$2" ]; then
    echo "utilisation: $0 fichier1 fichier2" >&2
    exit 1
fi

FILE1="$1"
FILE2="$2"

# On récupère la taille du second fichier
FILE2_SIZE=`stat -c %s "$FILE2"`

version_naive () {

    SIMILARITIES=""

    # On va parcourir le fichier ligne par ligne
    # et on vérifier si cette ligne est égale ou non à une ligne
    # de l'autre fichier (on va lire le second fichier ligne par
    # ligne, pour chaque ligne du premier fichier).
    while read LINE; do

        while read LINE2; do
            # On vérifie si la ligne du fichier 2 corrrespond à la ligne
            # du fichier 1 en cours... S'il y a correspondence, on l'ajoute
            # à la variable SIMILARITIES.
            if [ "$LINE" = "$LINE2" ]; then
                SIMILARITIES="`echo "$SIMILARITIES"$'\n'"$LINE"`"
            fi
        done < "$FILE2"

    done < "$FILE1"

    # On va enlever les lignes vides et supprimer les doublons
    SIMILARITIES="`echo "$SIMILARITIES" | sort -u | grep -v '^ *$'`"

}

version_optimisee () {

    SIMILARITIES=""

    # On génère les noms pour les fichiers temporaires que l'on utilisera juste après
    FILE1_TMP="/tmp/similaritiesFile1.$$"
    FILE2_TMP="/tmp/similaritiesFile2.$$"

    # On supprime les fichiers temporaires automatiquement à la fin du script
    # ou s'il est quitté, par l'utilisateur par exemple
    trap 'rm -f "$FILE1_TMP" "$FILE2_TMP"' EXIT

    # On génère des fichiers temporaires où l'on va trier et enlever les doublons des lignes
    sort -u "$FILE1" | grep -v '^ *$' > "$FILE1_TMP"
    sort -u "$FILE2" | grep -v '^ *$' > "$FILE2_TMP"

    # On parcours le premier fichier ligne par ligne
    while read LINE; do
        # On regarde si la ligne est présente dans le second fichier
        if [ `fgrep -cx "$LINE" "$FILE2_TMP"` -ne 0 ]; then
            SIMILARITIES="`echo "$SIMILARITIES"$'\n'"$LINE"`"
        fi
    done < "$FILE1_TMP"

    # On va enlever les lignes vides (car la première est toujours vide)
    SIMILARITIES="`echo "$SIMILARITIES" | grep -v '^ *$'`"

}

# On lance les deux fonctions, et on récupère le temps d'éxécution
TIME_NAIF=`(time -p version_naive) 2>&1 | grep "^real" | sed s/"^real "//`
TIME_OPTI=`(time -p version_optimisee) 2>&1 | grep "^real" | sed s/"^real "//`

# On affiche la ligne correspondante pour pouvoir ensuite tracer le graphique
LINE_FOR_GRAPH="$FILE2_SIZE $TIME_NAIF $TIME_OPTI"
echo "$LINE_FOR_GRAPH"

# On insère la ligne dans un fichier "datas.txt" qui contiendra tous nos résultats
echo "$LINE_FOR_GRAPH" >> datas.txt

# On affiche les lignes similaires trouvées si l'option -v est passé
if $DISPLAY_SIMILARITIES; then
    echo "Voici les lignes similaires :"
    echo "$SIMILARITIES"
fi

# On trie le fichier datas.txt et on trace le graphe
sort -n datas.txt -o datas.txt
./graphe.sh datas.txt &>/dev/null

exit 0
