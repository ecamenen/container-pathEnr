#!/bin/bash
#
#Script used to perform unitary tests on pathway enrichment tool
#
#Author: E. CAMENEN
#
#Copyright: PhenoMeNal/INRA Toulouse 2018

#Settings files
INFILE="sacurine_workflow_output.tsv"
SBML="recon2.02_without_compartment.xml"
OUTFILE1="mapping.tsv"
OUTFILE2="pathwayEnrichment.tsv"
OUTFILE3="information.txt"

#Settings warnings
WARN_MAP=" By default, it was set on the SBML identifiers at the 2nd column of your dataset. Other mapping available: ChEBI, InChI, InChIKey, SMILES, CSID, PubChem, isotopic mass and HMDB (check -help)."
MSG_MAP='[WARNING] No mapping parameters has been chosen.'$WARN_MAP
MSG_NEG_MAP='[WARNING] All your mapping parameters have negative column.'$WARN_MAP
WARN_NAME='; by default it was set to the 1rst column.'
MSG_NAME='[WARNING] No column number has been chosen for the name of the chemicals'$WARN_NAME
MSG_DEF=$MSG_MAP" $MSG_NAME"
MSG_DOUBL=" [WARNING] Please, check the corresponding lines in the mapping output file.\n[WARNING] These duplicates will be discarded from the pathway analysis."
MSG_CHECK="All your databases identifiers seem valid."

#Initialization
ERRORS=""
NBFAIL=0
NBTEST=0
PARAMETER=0
EXIT=0
TESTS=()
echo '' > resultRuns.log


########### ERRORS CATCH ###########
testError(){
    local BOOLEAN_ERR="false"
    local MSG=""
    local OUTFILES=($OUTFILE1 $OUTFILE2 $OUTFILE3)
    local ACTUAL_NB_LINE_MAP=$( wc $OUTFILE1 | awk '{print $1}')
    local ACTUAL_NB_LINE_ENR=$( wc $OUTFILE2 | awk '{print $1}')

    [ $3 -ne $EXIT ] && {
        MSG=$MSG"Program exited with bad error code: $3.\n"
        BOOLEAN_ERR="true"
    }

    [[ ( ! -f $OUTFILE1 ) ||  ( ! -f $OUTFILE2) ||  ( ! -f $OUTFILE3) ]] && {
        for i in ${OUTFILES[@]}; do
		testFileExist $i
	done
        MSG=$MSG"not created.\n"
        BOOLEAN_ERR="true"
    }

    ACTUAL_OUTPUT=$(cat $OUTFILE3 | tr '\n' ' ' )
    if [[ $ACTUAL_OUTPUT != *"$WARN"* ]]; then
        MSG=$MSG"Expected warnings not found.\n"
        echo "$WARN"
        echo "$ACTUAL_OUTPUT"
        BOOLEAN_ERR="true"
    fi

    if [[ $ACTUAL_OUTPUT != *"$OUTPUT"* ]]; then
        MSG=$MSG"Expected output not found.\n"
        echo "$OUTPUT"
        echo "$ACTUAL_OUTPUT"
        BOOLEAN_ERR="true"
    fi

    [ $ACTUAL_NB_LINE_MAP -ne $1 ] && {
        MSG=$MSG"Expected $1 lines in $OUTFILE1. Actual have $ACTUAL_NB_LINE_MAP lines.\n"
        BOOLEAN_ERR="true"
    }

    [ $ACTUAL_NB_LINE_ENR -ne $2 ] && {
        MSG=$MSG"Expected $2 lines in $OUTFILE2. Actual have $ACTUAL_NB_LINE_ENR lines.\n"
        BOOLEAN_ERR="true"
    }

    #rm $OUTFILE1 $OUTFILE2 $OUTFILE3
    [ $BOOLEAN_ERR == "true" ] && {
	    #echo $MSG
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


########### LOG WRITING ###########
setMapLog(){
    OUTPUT+=" "$1" "$2" have been mapped on "$3" in the fingerprint dataset ("$4"%) and on "$5" in the network ("$6"%)."
}

setMapLogDefault(){
    setMapLog $1 "metabolites" "110" $2 "2592" $3
}

setEnrLog(){
    OUTPUT+=" "$1" "$2" are concerned among the network (on "$3" in the network; "$4"%)."
}

setEnrLogDefault(){
    setEnrLog $1 "pathways" "97" $2
}

setDoubletsLog(){
    OUTPUT+=" [WARNING] There are $1 possible matches for $2."
}


########### RUN PROCESS ###########
run(){
	printf "\n\n$NBTEST. ${TESTS[$PARAMETER]}\n" >> resultRuns.log 2>&1
    #java -jar pathwayEnrichment.jar -gal $@
    let NBTEST+=1
    let PARAMETER+=1
    java -jar pathwayEnrichment.jar -gal $OUTFILE3 $@ >> resultRuns.log 2>&1
}

getElapsedTime(){
    END_TIME=$(date -u -d $(date +"%H:%M:%S") +"%s")
    ELAPSED_TIME=$(date -u -d "0 $END_TIME sec - $1 sec" +"%H:%M:%S")
    echo "Time to run the process ${ELAPSED_TIME:3:2}min ${ELAPSED_TIME:6:2}s"
}

test(){
    for i in `seq 0 $((${#TESTS[@]} -1))`; do
        run "-i data/$INFILE -s data/$SBML ${TESTS[i]}"
        ACTUAL_EXIT=$?
        if [ -z $1 ]; then
            printError $NB_LINE_MAP $NB_LINE_ENR $ACTUAL_EXIT $i
        else
            OUTPUT=${OUTPUTS[i]}
            printError ${NB_LINE_MAP[i]} ${NB_LINE_ENR[i]} $ACTUAL_EXIT $i
        fi
    done
}


########### TESTS ###########
testsDefault(){
    PARAMETER=0
    NAME='TEST_DEFAULT'

    TESTS=('-t 1')
    #TESTS=('' '-t 1' '-tEnr 3' '-s data/recon2.02_without_compartment.xml' '-sep \t' '-sepID ;')
    NB_LINE_MAP='111'
    NB_LINE_ENR='40'

    WARN=$MSG_DEF
    OUTPUT=""
    #OUTPUT="$WARN "$MSG_CHECK
    setMapLogDefault "33" "30.0" "1.27"
    setEnrLogDefault "39" "40.21"
    #printf "$OUTPUT"

    test
}

testsMappingDB(){
    PARAMETER=0

    TESTS=('-chebi 3' '-inchi 4')
    #TESTS=('-chebi 3' '-inchi 4' '-inchi 4 -l c,h,t' '-inchi 4 -l t,h,c' '-inchi 4 -l' '-inchikey 5' '-kegg 6' '-pubchem 7' '-hmdb 8' '-csid 9')
    NB_LINE_MAP=('178' '116' '1' '1' '1' '1' '1' '1' '1' '1')
    NB_LINE_ENR=('15' '39' '1' '1' '1' '1' '1' '1' '1' '1')
    OUTPUTS=()
    MAP_PAR=('14 12.73 0.54' '33 30.0 1.27' '4 3.64 0.15' '4 3.64 0.15' '45 40.91 1.74' '14 12.73 0.54' '12 10.91 0.46' '14 12.73 0.54' '13 11.82 0.5' '9 8.18 0.35')
    ENR_PAR=('14 14.43' '38 39.18' '3 3.09' '3 3.09' '30 30.93' '15 15.46' '13 13.4' '14 14.43' '14 14.43' '10 10.31')

    WARN=$MSG_NAME

    for i in `seq 0 $((${#TESTS[@]} -1))`; do
        OUTPUT=""
        setMapLogDefault ${MAP_PAR[i]}
        #echo "$OUTPUT"
        setEnrLogDefault ${ENR_PAR[i]}
        OUTPUTS[i]="$OUTPUT"
    done

    test "multiple"
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


########### MAIN ###########

START_TIME=$(date -u -d $(date +"%H:%M:%S") +"%s")
printf "Tests in progress, could take a few minutes...\n"
#mkdir temp

#testsDefault
testsMappingDB

#rm -r temp/
printf "\n$NBTEST tests, $NBFAIL failed.$ERRORS\n"
getElapsedTime $START_TIME
[[ -z $ERRORS ]] || exit 1
exit 0