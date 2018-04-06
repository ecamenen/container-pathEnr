#!/bin/bash
#
#Script used to perform unitary tests on pathway enrichment tool
#
#Author: E. CAMENEN
#
#Copyright: PhenoMeNal/INRA Toulouse 2018

#Settings files
OUTFILE1="temp/mapping.tsv"
OUTFILE2="temp/pathwayEnrichment.tsv"
OUTFILE3="temp/information.txt"

#Settings warnings
WARN_MAP=" By default, it was set on the SBML identifiers at the 2nd column of your dataset. Other mapping available: ChEBI, InChI, InChIKey, SMILES, CSID, PubChem, isotopic mass and HMDB (check -help)."
MSG_MAP='[WARNING] No mapping parameters has been chosen.'${WARN_MAP}
MSG_NEG_MAP='[WARNING] All your mapping parameters have negative column.'${WARN_MAP}
WARN_NAME='; by default it was set to the 1rst column.'
MSG_NAME='[WARNING] No column number has been chosen for the name of the chemicals'${WARN_NAME}
MSG_DEF="$MSG_MAP $MSG_NAME"
MSG_DOUBL=" [WARNING] Please, check the corresponding lines in the mapping output file.\n[WARNING] These duplicates will be discarded from the pathway analysis."
MSG_CHECK="All your databases identifiers seem valid."
WARN_TYPE=('[FATAL] Type of ' ' entity must be comprise between 1 and 6.')

#Initialization
declare -x INFILE SBML FUNC ERRORS=""
#OUTPUT WARN
declare -i PARAMETER EXIT NB_LINE_MAP NB_LINE_ENR NBFAIL=0 NBTEST=0
declare -a TESTS EXITS NB_LINE_MAPS NB_LINE_ENRS OUTPUTS WARNS MAP_PARS ENR_PARS
echo '' > resultRuns.log

setUp(){
    INFILE="sacurine_workflow_output.tsv"
    SBML="recon2.02_without_compartment.xml"
    PARAMETER=0
    EXIT=0
    FUNC=${FUNCNAME[1]}
    OUTPUT=""

    printf "\n- ${FUNC}: "
}

tearDown(){
  rm -rf temp/
}

########### ERRORS CATCH ###########
testError(){
    local BOOLEAN_ERR="false"
    local MSG=""
    local OUTFILES=(${OUTFILE1} ${OUTFILE2} ${OUTFILE3})
    local ACTUAL_NB_LINE_MAP=$( wc ${OUTFILE1} | awk '{print $1}')
    local ACTUAL_NB_LINE_ENR=$( wc ${OUTFILE2} | awk '{print $1}')
    local ACTUAL_OUTPUT=$(cat $OUTFILE3 | tr '\n' ' ' )

    [ $1 -ne ${EXIT} ] && {
        MSG=${MSG}"Program exited with bad error code: $1.\n"
        BOOLEAN_ERR="true"
    }

    [ ${EXIT} -eq 0 ] && [[ ( ! -f ${OUTFILE1} ) ||  ( ! -f ${OUTFILE2}) ||  ( ! -f ${OUTFILE3}) ]] && {
        for i in ${OUTFILES[@]}; do
		testFileExist ${i}
	done
        MSG=${MSG}"not created.\n"
        BOOLEAN_ERR="true"
    }

    if [[ ${ACTUAL_OUTPUT} != *"$WARN"* ]]; then
        MSG=${MSG}"Expected warnings not found.\n"
        echo "$WARN"
        echo "$ACTUAL_OUTPUT"
        BOOLEAN_ERR="true"
    fi

    if [[ ${ACTUAL_OUTPUT} != *"$OUTPUT"* ]]; then
        MSG=${MSG}"Expected output not found.\n"
        echo "$OUTPUT"
        echo "$ACTUAL_OUTPUT"
        BOOLEAN_ERR="true"
    fi

    testNbLine $3 ${OUTFILE1} ${ACTUAL_NB_LINE_MAP}
    testNbLine $4 ${OUTFILE2} ${ACTUAL_NB_LINE_ENR}

    tearDown

    [ ${BOOLEAN_ERR} == "true" ] && {
	    #echo $MSG
	    ERRORS=${ERRORS}"\n***************\n##Test \"${TESTS[$2]}\" in $FUNC: \n$MSG"
	    return 1
    }
    return 0
}

testFileExist(){
    [ ! -f $1 ] && MSG=${MSG}"$1 "
}

testNbLine(){
    [ -f $2 ] && [ $3 -ne $1 ] && {
        MSG=${MSG}"Expected $1 lines in $2. Actual have $3 lines.\n"
        BOOLEAN_ERR="true"
    }
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

setMultipleOutput(){
    OUTPUTS=()
    local TEMP_OUTPUT="${OUTPUT}"
    for i in `seq 0 $((${#TESTS[@]} -1))`; do
        OUTPUT="${TEMP_OUTPUT}"
        if [ ! -z $1 ]; then
            if [ $1 != "full" ]; then
                IFS=' ' read -r -a PAR <<< "${MAP_PARS[i]}"
                setMapLog ${PAR[0]} "metabolites" ${PAR[1]} ${PAR[2]} "2592" ${PAR[3]}
                setEnrLogDefault ${ENR_PARS[i]}
            else
                setMapLog ${MAP_PARS[i]}
                setEnrLog ${ENR_PARS[i]}
            fi
        else
            setMapLogDefault ${MAP_PARS[i]}
            setEnrLogDefault ${ENR_PARS[i]}
        fi

        OUTPUTS[i]="$OUTPUT"

    done
}

setMappingDefaultParameters(){
    NB_LINE_MAP=111
    NB_LINE_ENR=40
    setMapLogDefault 33 30.0 1.27
    setEnrLogDefault 39 40.21
}

########### RUN PROCESS ###########
run(){
	printf "\n\n$NBTEST. ${TESTS[$PARAMETER]}\n" >> resultRuns.log 2>&1
    #java -jar pathwayEnrichment.jar -gal $@
    let NBTEST+=1
    let PARAMETER+=1
    java -jar pathwayEnrichment.jar -o2 ${OUTFILE1} -o3 ${OUTFILE2} -gal ${OUTFILE3} $@ >> resultRuns.log 2>&1
}

getElapsedTime(){
    local END_TIME=$(date -u -d $(date +"%H:%M:%S") +"%s")
    local ELAPSED_TIME=$(date -u -d "0 $END_TIME sec - $1 sec" +"%H:%M:%S")
    echo "Time to run the process ${ELAPSED_TIME:3:2}min ${ELAPSED_TIME:6:2}s"
}

test(){

    for i in `seq 0 $((${#TESTS[@]} -1))`; do
        run "-i data/$INFILE -s data/$SBML ${TESTS[i]}"
        local ACTUAL_EXIT=$?

    if [ ! -z $1 ]; then
        if [ $1 == "parameters" ]; then
            OUTPUT="${OUTPUTS[i]}"
            NB_LINE_MAP=${NB_LINE_MAPS[i]}
            NB_LINE_ENR=${NB_LINE_ENRS[i]}
        elif [ $1 == "errors" ]; then
            OUTPUT="${OUTPUTS[i]}"
            EXIT=${EXITS[i]}
            WARN="${WARNS[i]}"
        elif [ $1 == "warn" ]; then
            OUTPUT="${OUTPUTS[i]}"
            WARN="${WARNS[i]}"
        elif [ $1 == "warn2" ]; then
            WARN="${WARNS[i]}"
        fi
    fi
        printError ${ACTUAL_EXIT} ${i} ${NB_LINE_MAP} ${NB_LINE_ENR}
    done
}


########### TESTS ###########
testsDefault(){
    setUp

    #TESTS=('-t 1' '-tEnr 3')
    TESTS=('' '-t 1' '-tEnr 3' '-s data/recon2.02_without_compartment.xml' '-sep \t' '-sepID ;')

    WARN="${MSG_DEF}"
    #fullOutput
    OUTPUT="${WARN} ${MSG_CHECK}"
    setMappingDefaultParameters

    test
}



## Parsing ##

testsFileFiltering(){
    setUp

    #TESTS=('-f 13')
    TESTS=('-f 13' '-header')
    NB_LINE_MAPS=('5' '112')
    NB_LINE_ENRS=('19' '40')
    MAP_PARS=('3 4 75.0 0.12' '33 111 29.73 1.27')
    ENR_PARS=('18 18.56' '39 40.21')
    #TODO: check -header nb map lines with default

    WARN="${MSG_DEF}"
    OUTPUT="${WARN} ${MSG_CHECK}"
    setMultipleOutput "fingerprint_length"

    test "parameters"
}

testsCheckingFormat(){
    setUp

    TESTS=('-inchi 4 -l c,h,t -lWarn -noCheck')
    #TESTS=('-inchi 4 -l c,h,t -lWarn' '-inchi 4 -l c,h,t' '-inchi 4 -l c,h,t -noCheck' '-inchi 4 -l c,h,t -lWarn -noCheck')
    IF_CHECKFILE=(1 1 0 0)
    NB_LINE_MAP=111
    NB_LINE_ENR=4

    #HEADER=('X' 'Y')
    WARNS=("$MSG_NAME [WARNING] Checking format option has been disabled. [WARNING] Without checking, layer warnings option will be useless.")
    #WARNS=("$MSG_NAME" "$MSG_NAME" "$MSG_NAME" "$MSG_NAME [WARNING] Checking format option has been disabled. [WARNING] Without checking, layer warnings option will be useless.")
    setMapLogDefault 4 3.64 0.15
    setEnrLogDefault 3 3.09

    test "warn2"
}



## DBMapping ##

testsMappingDB(){
    setUp

    TESTS=('-chebi 3' '-inchi 4' '-inchi 4 -l c,h' '-inchi 4 -l c,h,t' '-inchi 4 -l t,h,c' '-inchi 4 -l' '-inchikey 5' '-kegg 6' '-pubchem 7' '-hmdb 8' '-csid 9')
    NB_LINE_MAPS=('178' '116' '116' '111' '111' '170' '112' '112' '178' '112' '178')
    NB_LINE_ENRS=('15' '39' '39' '4' '4' '31' '16' '14' '15' '15' '11')
    MAP_PARS=('14 12.73 0.54' '33 30.0 1.27' '33 30.0 1.27' '4 3.64 0.15' '4 3.64 0.15' '45 40.91 1.74' '14 12.73 0.54' '12 10.91 0.46' '14 12.73 0.54' '13 11.82 0.5' '9 8.18 0.35')
    ENR_PARS=('14 14.43' '38 39.18' '38 39.18' '3 3.09' '3 3.09' '30 30.93' '15 15.46' '13 13.4' '14 14.43' '14 14.43' '10 10.31')

    WARN="${MSG_NAME}"
    setMultipleOutput

    test "parameters"
}

testsMass(){
    setUp

    #TESTS=('-mass 12 -prec 2' '-mass 12')
    TESTS=('-mass 12 -prec 2' '-mass 12' '-prec 2' '-prec 101' '-prec 0' '-prec -1')
    NB_LINE_MAP='147'
    NB_LINE_ENR='15'
    EXITS=('0' '0' '11' '1' '1' '1')

    local WARN1="[WARNING] Weight precision has been set without specify isotopic mass column in the fingerprint. [WARNING] By default, it has been set to the 2nd column."${MSG_NAME}
    local WARN2="[FATAL] Weight precision must be comprise between 1 and 100."
    WARNS=("${MSG_NAME}" "${MSG_NAME}" "${WARN1}" "${WARN2}" "${WARN2}" "${WARN2}")

    OUTPUTS=()
    OUTPUT=""
    setMapLogDefault "50" "45.45" "1.93"
    setEnrLogDefault "14" "14.43"
    OUTPUTS[0]="$OUTPUT"
    OUTPUTS[1]="$OUTPUT"
    #fullOutput
    OUTPUTS[2]="${WARN1} [FATAL] All the values of the selected database(s) are badly formatted. Please check the column number set for these databases. -noCheck to ignore the bad format exit and run the analysis anyway."
    OUTPUTS[3]="${WARN2}"
    OUTPUTS[4]="${WARN2}"
    OUTPUTS[5]="${WARN2}"

    test "errors"
}

testsID_SBML(){
    setUp

    TESTS=('' '-idSBML 2' '-idSBML -2')
    WARNS=("${MSG_DEF}" "${MSG_NAME}" "[WARNING] -idSBML column parameter must be positive. ${MSG_NEG_MAP} ${MSG_NAME}")

    #fullOutput
    for i in `seq 0 $((${#TESTS[@]} -1))`; do
        OUTPUT="${WARNS[i]} ${MSG_CHECK}"
        setMappingDefaultParameters
        OUTPUTS[i]="$OUTPUT"
    done

    test "warn"
}



## InChILayersCatch ##

testsBadInChILayers(){
    setUp

    TESTS=('-l chp' '-l c,hp' '-l c,' '-l xertg')
    WARN="-l parameter badly formatted: it must be a list containing the number - separated by comma without blank spaces - of the InChi's layer concerned by the mapping (by default: c,h; for a mapping including all the layers, enter c,h,q,p,b,t,i,f,r; for a mapping on formula layer only, enter the -l option with no parameter)"
    EXIT=1

    test
}

testsDefaultInChILayers(){
    setUp

    TESTS=('-l')
    WARN="[WARNING] InChI layers parameters set without having specified the InChI column (-inchi). [WARNING] By default, the column used for InChI mapping is the 2nd of your dataset. "$MSG_NAME
    EXIT=11

    test
}


## Name ##

testsName(){
    setUp

    TESTS=('-nameCol 1' '-nameCol 1 -name 0')
    WARNS=("$MSG_MAP" "$MSG_NEG_MAP")
    #TODO:full
    OUTPUT="${MSG_CHECK}"
    setMappingDefaultParameters

    test "warn2"
}

testsNameMap(){
    setUp

    #TESTS=('-nameCol -2 -name 1')
    TESTS=('-nameCol -2 -name 1' '-name 1' '-name 1 -nameCol 2')
    NB_LINE_MAP=111
    NB_LINE_ENR=6
    WARNS=('' '' "[WARNING] You have set both name column and name mapping parameters and with different parameters. [WARNING] By default, the name mapping is activated with the column number of this parameter.")
    setMapLogDefault "3" "2.73" "0.12"
    setEnrLogDefault "5" "5.15"

    test "warn2"
}

testsNameNegative(){
    setUp

    #TESTS=('-name -1')
    TESTS=('-name -1' '-nameCol -1 -name -1' '-name -1' '-nameCol -1')

    WARNS2=("$MSG_NEG_MAP" "$MSG_NEG_MAP" "$MSG_NEG_MAP" "$MSG_MAP")
    for i in `seq 0 $((${#TESTS[@]} -1))`; do
        WARNS[i]="${WARNS2[i]} [WARNING] Your column number for the name of the chemicals is negative$WARN_NAME"
    done

    #TODO: full
    OUTPUT="${MSG_CHECK}"
    setMappingDefaultParameters

    test "warn2"
}



## Separators ##

testSep(){
    setUp

    TESTS=('-sep ;')
    WARN="$MSG_DEF $MSG_CHECK [FATAL] There is no match for this network ! Common mistakes: wrong type of mapping (by default on the SBML ID and the name of the metabolites), wrong number of column from the dataset or wrong type of bioEntity (or bad SBML). Please check your settings and rerun the analysis."
    EXIT=20

    test
}

testSepID(){
    setUp

    TESTS=('-sepID , -chebi 3')
    NB_LINE_MAP=178
    NB_LINE_ENR=15

    WARN="$MSG_NAME [WARNING] Some database identifiers are badly formatted, please take a look to \"checking_format.tsv\""
    setMapLogDefault 14 12.73 0.54
    setEnrLogDefault 14 14.43

    test
    #TODO: debug differences between database in SBML and compare with sepID ; -chebi 3
}


## Entity type ##

testsBadMappedType(){
    setUp

    TESTS=('-t 0' '-t -1' '-t 7')
    WARN=${WARN_TYPE[0]}'mapped'${WARN_TYPE[1]}
    EXIT=1

    test
}

testsBadEnrichedType(){
    setUp

    TESTS=('-tEnr 0' '-tEnr -1' '-tEnr 7')
    WARN=${WARN_TYPE[0]}'enriched'${WARN_TYPE[1]}
    EXIT=1

    test
}

testEnrReaction(){
    setUp

    TESTS=('-tEnr 2')
    NB_LINE_MAP=111
    NB_LINE_ENR=254

    WARN=$MSG_DEF
    OUTPUT="${WARN} ${MSG_CHECK}"
    setMapLogDefault 33 30.0 1.27
    setEnrLog 253 "reactions" 4210 6.01

    test
}

testMapReaction(){
    setUp

    INFILE="reactions_recon2.02.tsv"

    TESTS=('-t 2')
    NB_LINE_MAP=23
    NB_LINE_ENR=9

    WARN=$MSG_DEF
    OUTPUT="${WARN} ${MSG_CHECK}"
    setMapLogDefault 22 100.0 0.52
    setEnrLog 8 XXX 8.25

    test
}

testsGPR(){
    setUp

    INFILE="gpr_recon2.02.tsv"
    SBML="recon2.02.xml"
    #TESTS=('-t 5')
    TESTS=('-t 4' '-t 5' ' -t 6 -idSBML 3' '-t 5 -tEnr 6' '-t 4 -tEnr 6' '-t 6 -idSBML 3 -tEnr 5')

    NB_LINE_MAPS=(73 73 73 73 73 73)
    NB_LINE_ENRS=(41 41 41 69 65 69)
    MAP_PARS=('72 enzymes 72 100.0 2682 2.68' '72 proteins 72 100.0 1842 3.91' '72 genes 72 100.0 1842 3.91' '72 proteins 72 100.0 1842 3.91' '72 enzymes 72 100.0 2682 2.68' '72 genes 72 100.0 1842 3.91')
    ENR_PARS=('40 pathways 100 40.0' '40 pathways 100 40.0' '40 pathways 100 40.0' '69 genes 1842 3.75' '65 genes 1842 3.53' '69 proteins 1842 3.75')

    #WARN="${MSG_DEF}"
    setMultipleOutput "full"

    test "parameters"
}

########### MAIN ###########

START_TIME=$(date -u -d $(date +"%H:%M:%S") +"%s")
printf "Tests in progress, could take a few minutes...\n"
#mkdir temp

:'
testsDefault
testsMappingDB
testsMass
testsID_SBML
testsBadInChILayers
testsName
testsNameMap
testsNameNegative
testsBadMappedType
testsBadEnrichedType
testSep
testsDefaultInChILayers
testsFileFiltering
testMapReaction
testEnrReaction
testsCheckingFormat
testsGPR
'

testSepID

#rm -r temp/
printf "\n$NBTEST tests, $NBFAIL failed.$ERRORS\n"
getElapsedTime ${START_TIME}
[[ -z ${ERRORS} ]] || exit 1
exit 0