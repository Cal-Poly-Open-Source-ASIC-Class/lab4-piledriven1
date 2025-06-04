if [ $# != 2 ]
  then
    echo "Usage: ./scripts/cdc.sh [source_clock] [dest_clock]"
    echo "Finds clock domain crossings from source to dest in your most recent openlane run"
    exit
fi

RECENT=$(ls runs | tail -n 1)
STA=$(find ./runs/$RECENT -iname  max.rpt | sort | head -n1)

grep -zoP 'Startpoint.*\n.*'$1'.\n.*\n.*'$2'.\n' $STA | sed -E 's/Start/`Start/g' | tr '`' '\n'
echo