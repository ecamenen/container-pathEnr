#!/bin/bash
#
#Script used to perform unitary tests on pathway enrichment tool
#
#Author: E. Camenen
#
#Copyright: PhenoMeNal/INRA Toulouse 2017

#Settings files
INFILE="sacurine_workflow_output.tsv"
SBML="recon2.02_without_compartment.xml"
OUTFILE1="mapping.tsv"
OUTFILE2="pathwayEnrichment.tsv"
OUTFILE3="information.txt"

#Settings warnings
WARN_MAP=" By default, it was set on the SBML identifiers at the 2nd column of your dataset. Other mapping available: ChEBI, InChI, InChIKey, SMILES, CSID, PubChem, isotopic mass and HMDB (check -help).\n"
MSG_MAP='[WARNING] No mapping parameters has been chosen.'$WARN_MAP
MSG_NEG_MAP='[WARNING] All your mapping parameters have negative column.'$WARN_MAP
WARN_NAME='; by default it was set to the 1rst column.'
MSG_NAME='[WARNING] No column number has been chosen for the name of the chemicals'$WARN_NAME
MSG_DEF=$MSG_MAP'$MSG_NAME'

#Initialization
ERRORS=""
NBFAIL=0
NBTEST=0
PARAMETER=0
TESTS=('')
echo '' > resultRuns.log

testError(){
    local BOOLEAN_ERR="false"
    local MSG=""
    local OUTFILES=($OUTFILE1 $OUTFILE2 $OUTFILE3)
    local ACTUAL_NB_LINE_MAP=$( wc $OUTFILE1 | awk '{print $1}')
    local ACTUAL_NB_LINE_ENR=$( wc $OUTFILE2 | awk '{print $1}')

    [ $3 -ne 0 ] && {
        MSG=$MSG"Program exited with error.\n"
        BOOLEAN_ERR="true"
    }

    [[ ( ! -f $OUTFILE1 ) ||  ( ! -f $OUTFILE2) ||  ( ! -f $OUTFILE3) ]] && {
        for i in ${OUTFILES[@]}; do
		testFileExist $i
	done
        MSG=$MSG"not created.\n"
        BOOLEAN_ERR="true"
    }

    [ $ACTUAL_NB_LINE_MAP -ne $1 ] && {
        MSG=$MSG"Expected $1 lines in $OUTFILE1, Actual=$ACTUAL_NB_LINE_MAP lines.\n"
        BOOLEAN_ERR="true"
    }

    [ $ACTUAL_NB_LINE_ENR -ne $2 ] && {
        MSG=$MSG"Expected $1 lines in $OUTFILE2, Actual=$ACTUAL_NB_LINE_ENR lines.\n"
        BOOLEAN_ERR="true"
    }

    #rm $OUTFILE1 $OUTFILE2 $OUTFILE3
    [ $BOOLEAN_ERR == "true" ] && {
	echo $MSG
	    ERRORS=$ERRORS"\n***************\n##Test \"${TESTS[$4]}\": \n$MSG"
	    return 1
    }
    return 0
}


testFileExist(){
    [ ! -f $1 ] && MSG=$MSG"$1 "
}

printError(){
    testError $@
    if [ $? -ne 0 ]; then
        echo -n "E"
        let NBFAIL+=1
    else echo -n "."
    fi
}

run(){
	printf "\n\n$NBTEST. ${TESTS[$PARAMETER]}\n" >> resultRuns.log 2>&1
    #java -jar pathwayEnrichment.jar -gal $@
    java -jar pathwayEnrichment.jar -gal $OUTFILE3 $@ >> resultRuns.log 2>&1
    let NBTEST+=1
    let PAR+=1
}

test(){
    for i in `seq 0 $((${#TESTS[@]} -1))`; do
        run "-i data/$INFILE -s data/$SBML ${TESTS[i]}"
        EXIT=$?
        printError $NB_LINE_MAP $NB_LINE_ENR $EXIT $i
        #printError ${NB_LINE_MAP[i]} ${NB_LINE_ENR[i]} $EXIT $i
    done
}

testsDefault(){
    PARAMETER=0
    NAME='TEST_DEFAULT'
    TESTS=('-t 1' '-header')
    #TESTS=('' '-t 1' '-tEnr 3' '-s data/recon2.02_without_compartment.xml' '-header' '-sep \t' '-sepID ;')
    MSG=$MSG_DEF
    NB_LINE_MAP='111'
    NB_LINE_ENR='40'
    test
}

testsFail(){
    TESTS=('-t 0' '-t 10' 'l xmlkfmrvgj' '-inchi 5' '-smiles 11 -name -1')
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
testsDefault
#rm -r temp/
printf "\n$NBTEST tests, $NBFAIL failed.$ERRORS\n"
getElapsedTime $START_TIME
[[ -z $ERRORS ]] || exit 1
exit 0
