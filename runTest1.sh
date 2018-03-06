#!/bin/bash
#
#Script used to perform unitary tests on pathway enrichment tool
#
#Author: E. Camenen
#
#Copyright: PhenoMeNal/INRA Toulouse 2017

INFILE="data/sacurine_workflow_output.tsv"
OUTFILE1="mapping.tsv"
OUTFILE2="pathwayEnrichment.tsv"
OUTFILE3="information.txt"
ERRORS=""
NBFAIL=0
NBTEST=0
TESTS=('' '-t 1' '-f 13' 'idSBML 2' '-inchi 4' '-inchi 4 -l c,h,p' '-inchi 4 -l p,h,c' '-l c,h,p' '-inchi 4 -l' '-l' '-chebi 3' '-inchikey 5' '-kegg 6' '-hmdb 8' '-csid 9' '-name -1' '-name -1 -inchi 4' '-s data/recon2.02.xml' '--header' '-sep \t')
NAME_TESTS=('by default' 'with reactions' 'filtered column' 'id SBML mapping' 'inchi mapping' 'including p layer in mapping' 'with shuffled layer parameters' 'including p layer in mapping without inchi column' 'mapping on formula only' 'mapping on formula only without inchi column' 'ChEBI' 'InChIKey' 'KEGG' 'HMDB' 'CSID' 'without name mapping' 'without name mapping but with another mapping' 'with another SBML' 'without header' 'with separator argument')
echo '' > resultRuns.log

testError(){
    local BOOLEAN_ERR="false"
    local MSG=""
    local OUTFILES=($OUTFILE1 $OUTFILE2 $OUTFILE3)

    [ $1 -ne 0 ] && {
        MSG=$MSG"Program exited with error.\n"
        BOOLEAN_ERR="true"
    }

    [[ ( ! -f $OUTFILE1 ) ||  ( ! -f $OUTFILE2) ||  ( ! -f $OUTFILE3) ]] && {
        for i in ${OUTFILES[@]}; do
		testFileExist $i
	done
        MSG=$MSG"not created. \n"
        BOOLEAN_ERR="true"
    }

    [[ ( -n $(cmp temp/$OUTFILE1$2 $OUTFILE1) ) || ( -n $(cmp temp/$OUTFILE2$2 $OUTFILE2) ) || ( -n $(cmp temp/$OUTFILE3$2 $OUTFILE3) ) ]] && {
    	for i in ${OUTFILES[@]}; do
		compareFile $i $2
    	done
        BOOLEAN_ERR="true"
    }

    #rm $OUTFILE1 $OUTFILE2 $OUTFILE3
    [ $BOOLEAN_ERR == "true" ] && {
	echo $MSG
	    ERRORS=$ERRORS"\n***************\n##Test \"${NAME_TESTS[$2]}\": \n$MSG"
	    return 1
    }
    return 0
}

compareFile(){
    [[ -n $(cmp temp/$1"$2" $1) ]] && MSG=$MSG"Expected and actual $1 files are not identicals. \n"
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
    #java -jar pathwayEnrichment.jar -gal $@
    java -jar pathwayEnrichment.jar -gal $OUTFILE3 $@ >> resultRuns.log 2>&1
}

tests(){
    #local GIT_PATH="https://raw.githubusercontent.com/phnmnl/container-pathwayEnrichment/master/testData"
    for i in `seq 0 $((${#TESTS[@]} -1))`; do
        #wget -q -P temp/ $GIT_PATH/mapping.tsv"${i}" $GIT_PATH/pathwayEnrichment.tsv"${i}" $GIT_PATH/info.txt"${i}"
        run "-i $INFILE ${TESTS[i]}"
        EXIT=$?
        printError $EXIT $i
    done
}

testsFail(){
    TESTS=('-t 0' '-t 10' 'l xmlkfmrvgj' '-inchi 5' '-pubchem 7 -name -1' '-smiles 11 -name -1')
    NAME_TESTS=('Wrong BioType' 'Wrong BioType bis' 'Wrong layers' 'Wrong column number: 0 mapping' 'PubChem' 'SMILES')
    for i in `seq 0 $((${#TESTS[@]} -1))`; do
        run "-i $INFILE ${TESTS[i]}"
        EXIT=$?
        let NBTEST+=1
        if [ $EXIT -ne 1 ]; then
            echo -n "E"
            let NBFAIL+=1
            ERRORS=$ERRORS"\n***************\n##Test \"${NAME_TESTS[$i]}\": \nError not caught!\n"
        else echo -n "."
        fi
    done
}

getElapsedTime(){
    END_TIME=$(date -u -d $(date +"%H:%M:%S") +"%s")
    ELAPSED_TIME=$(date -u -d "0 $END_TIME sec - $1 sec" +"%H:%M:%S")
    echo "Time to run the process ${ELAPSED_TIME:3:2}min ${ELAPSED_TIME:6:2}s"
}


START_TIME=$(date -u -d $(date +"%H:%M:%S") +"%s")
printf "Tests in progress, could take a few minutes...\n"
#mkdir temp
tests
testsFail
#rm -r temp/
printf "\n$NBTEST tests, $NBFAIL failed.$ERRORS\n"
getElapsedTime $START_TIME
[[ -z $ERRORS ]] || exit 1
exit 0
