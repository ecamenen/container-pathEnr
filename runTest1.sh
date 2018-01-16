#!/bin/bash
#
#Script used to perform unitary tests on pathway enrichment tool
#
#Author: E. Camenen
#
#Copyright: PhenoMeNal/INRA Toulouse 2017

INFILE="data/Galaxy15-[Biosigner_Multivariate_Univariate_Multivariate_variableMetadata.tsv].tabular"
OUTFILE1="mapping.tsv"
OUTFILE2="pathwayEnrichment.tsv"
OUTFILE3="info.txt"
ERRORS=""
NBFAIL=0
NBTEST=0
TESTS=('' '-f 30' '-l c,h,p' '-l p,h,c' '-l' '-chebi 2' '-chebi 2 -inchi -1')
NAME_TESTS=('by default' 'filtered column' 'including p layer in mapping' 'with shuffled layer parameters' 'mapping on formula only' 'CHEBI column activated' 'INCHI column disabled and CHEBI column activated')
'' > resultRuns.log

testError(){
    local BOOLEAN_ERR="false"
    local MSG="$ERRORS\nTest \"${NAME_TESTS[$2]}\": "
    local OUTFILES=($OUTFILE1 $OUTFILE2 $OUTFILE3)

    [ $1 -ne 0 ] && {
        MSG=$MSG"Program exited with error. "
        BOOLEAN_ERR="true"
    }

    [[ ( ! -f $OUTFILE1 ) ||  ( ! -f $OUTFILE2) ||  ( ! -f $OUTFILE3) ]] && {
        for i in ${OUTFILES[@]}; do
		testFileExist $i
	done
        MSG=$MSG"not created. "
        BOOLEAN_ERR="true"
    }

    [[ ( -n $(cmp temp/$OUTFILE1$2 $OUTFILE1) ) || ( -n $(cmp temp/$OUTFILE2$2 $OUTFILE2) ) || ( -n $(cmp temp/$OUTFILE3$2 $OUTFILE3) ) ]] && {
    	for i in ${OUTFILES[@]}; do
		compareFile $i $2
    	done
        BOOLEAN_ERR="true"
    }

    rm $OUTFILE1 $OUTFILE2 $OUTFILE3
    [ $BOOLEAN_ERR == "true" ] && {
	    ERRORS=$ERRORS"$MSG"
	    return 1
    }
    return 0
}

compareFile(){
    [[ -n $(cmp temp/$1"$2" $1) ]] && MSG=$MSG"Expected and actual $1 files are not identicals. "
}

testFileExist(){
    [ ! -f $1 ] && MSG=$MSG"$1 "
}
printError(){
    let NBTEST+=1
    testError $1 $2
    if [ $? -ne 0 ]; then
        echo -n "E"
        let NBFAIL+=1
    else echo -n "."
    fi
}

run(){
    java -jar pathwayEnrichment.jar -o3 info.txt $@
}

tests(){
    local GIT_PATH="https://raw.githubusercontent.com/phnmnl/container-pathwayEnrichment/master/testData"
    for i in `seq 0 $((${#TESTS[@]} -1))`; do
        if [ -z $1 ]; then
            wget -q -P temp/ $GIT_PATH/mapping.tsv"${i}" $GIT_PATH/pathwayEnrichment.tsv"${i}" $GIT_PATH/info.txt"${i}"
        else createdDummyOutput $i
        fi
        run "-i $INFILE ${TESTS[i]}"
        EXIT=$?
        printError $EXIT $i
    done
}

getElapsedTime(){
    END_TIME=$(date -u -d $(date +"%H:%M:%S") +"%s")
    ELAPSED_TIME=$(date -u -d "0 $END_TIME sec - $1 sec" +"%H:%M:%S")
    echo "Time to run the process ${ELAPSED_TIME:3:2}min ${ELAPSED_TIME:6:2}s"
}


START_TIME=$(date -u -d $(date +"%H:%M:%S") +"%s")
printf "Tests in progress, could take a few minutes...\n"
mkdir temp
tests
rm -r temp/
printf "\n$NBTEST tests, $NBFAIL failed.$ERRORS\n"
getElapsedTime $START_TIME
[[ -z $ERRORS ]] || exit 1
exit 0