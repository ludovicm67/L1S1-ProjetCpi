#!/bin/sh

DELETEARCHIVE=false   # Supprime l'archive une fois l'archive extraite (si=true)
DESTNAME=""           # Répertoire de destination

# Analyse des différentes options
OPTS=`getopt --options hxd: --long help,delete-archive,dest: \
        -n "$MAKEFILE_SCRIPTNAME" -- "$@"`
eval set -- "$OPTS"
while true; do
  case "$1" in
    -h | --help)
        echo "usage: $0 [OPTIONS] directory\n\nOPTIONS:\n \
        -h, --help     Display this message and exit\n \
        -x, --delete-archive\n \
                       Delete archives when extracted\n \
        -d, --dest     Destination folder (extraction folder)\n\n";
        exit 0;
        shift
      ;;
    -x | --delete-archive)  DELETEARCHIVE=true; shift;;
    -d | --dest)
        # On vérifie l'existance du répertoire de destination
        if [ -d "$2" ]; then
          DESTNAME="$2";
        else
          echo "'$2' is not a directory." >&2
          exit 1
        fi
        shift; shift;;
    -- )  shift; break;;
    *)    break
  esac
done

# On vérifie qu'un argument a bien été passé
if [ $# -ne 1 ]; then
  echo "usage: $0 [OPTIONS] directory" >&2
  exit 1
fi

# On privilégie des noms de variables explicites ;)
DIRECTORY="$1"

# On vérifie que le dossier existe bien
if [ ! -d "$DIRECTORY" ]; then
  echo "'$DIRECTORY' is not a directory." >&2
  exit 1
fi

# On liste les archives zip en provenance de Jamendo :
ls "$DIRECTORY" | grep " - [[:digit:]]* --- Jamendo - MP3\.zip$" | \
  while read ARCHIVENAME; do
    # Nom "nettoyé", qui servira a créer le dossier, etc...
    CLEANNAME="`echo "$ARCHIVENAME" | sed s/" - [[:digit:]]* --- Jamendo - MP3\.zip$"//`"

    # Aucun répertoire de destination n'a été passé en paramètr=>on extrait ici
    if [ -z "$DESTNAME" ]; then
      FINALDESTNAME="$DIRECTORY/$CLEANNAME"
    else
      FINALDESTNAME="$DESTNAME/$CLEANNAME"
    fi

    # On passe unzip en silencieux et on ne remplace pas les fichiers existants
    echo "Extracting '$ARCHIVENAME' in '$FINALDESTNAME'..."
    unzip -qq -n "$DIRECTORY/$ARCHIVENAME" -d "$FINALDESTNAME"

    # On modifie les droits (de manière récursive, en mode silencieux)
    # (lecture+écriture pour le propriétaire, lecture pour le groupe, rien pour les autres)
    chmod -fR 640 "$FINALDESTNAME"/*

    # On supprime l'archive si l'option -x est passé
    if $DELETEARCHIVE; then
      rm -f "$DIRECTORY/$ARCHIVENAME"
    fi

  done

exit 0