#!/bin/bash

SBML="data/recon2.v03_ext_noCompartment_noTransport_v2.xml"
INFILE="data/sacurineVariableMetadataEnhanced.tsv"
DUMMY_INFILE="tmp2/dummyInfile.tsv"
OUTFILE="/tmp2/pathwayEnrichment.tsv"
DUMMY_OUTFILE="tmp2/dummyOutfile.tsv"
ERRORS=""
NBFAIL=0
NBTEST=0
TESTS=( '-f 25' )
#TESTS=( '' '-f 25' '-l p,h,c' '-l c,h,p' '-l' '-chebi 0 -inchi 0' '-c 0' '-l ch')

createdDummyFiles(){
    printf 'variableMetadata\tdatabase_identifier\tchemical_formula\tsmiles\tinchi\tmetabolite_identification\tmass_to_charge\tmass_of_proton\tmass\tfragmentation\tmodifications\tcharge\tretention_time\treliability\tsample_mea\tpoolCV_over_sampleCV\tchebi.id\tchemspider.id\tbiodb.compound.name' > $DUMMY_INFILE
    printf '\nTestosterone glucuronide\tCHEBI:28835\tC25H36O8\t[H][C@@]12CCC3=CC(=O)CC[C@]3(C)[C@@]1([H])CC[C@]1(C)[C@H](CC[C@@]21[H])O[C@@H]1O[C@@H]([C@@H](O)[C@H](O)[C@H]1O)C(O)=O\tInChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1\tTestosterone glucuronide\t463,2329\t1,00727647\t464,24017647\tNA\t[(M-H)]-\t1\t7,9\t4\t2,1475578771\t0,5701078279\t0,265467969\t178149,617939526\t12351,5841321731\t0,0693326445\t0,2611714128\t28835\tNA\ttestosterone 17-glucosiduronic acid\tplsda|randomforest|svm' >> $DUMMY_INFILE
    printf '\nMalic acid\tNA\tC4H6O5\tOC(CC(O)=O)C(O)=O\tInChI=1S/C4H6O5/c5-2(4(8)9)1-3(6)7/h2,5H,1H2,(H,6,7)(H,8,9)\tMalic acid\t133,013511\t1,00727647\t134,02078747\tNA\t[(M-H)]-\t1\t1,08\t5\t2,705885808\t0,2514229882\t0,0929170726\t455610,344205852\t48548,3017483153\t0,1065566275\t1,1467927746\t6650\tNA\tmalic acid' >> $DUMMY_INFILE
    printf '\nCinnamoylglycine\tCHEBI:68616\tC11H11NO3\tOC(=O)CNC(=O)C=Cc1ccccc1\tInChI=1S/C11H11NO3/c13-10(12-8-11(14)15)7-6-9-4-2-1-3-5-9/h1-7H,8H2,(H,12,13)(H,14,15)/b7-6+\tCinnamoylglycine\t204,065452\t1,00727647\t205,07272847\tNA\t[(M-H)]-\t1\t7,03\t5\t4,0160399219\t0,5133270871\t0,1278192192\t11742041,4996239\t2134365,54261586\t0,1817712484\t1,4220963763\t68616\tNA\tN-cinnamoylglycine' >> $DUMMY_INFILE
}

testError(){
    local result=0
    echo 'ok'
    [[ $? -ne 0 ]] && {
        ERRORS="$ERRORS\n$?"
        result=1
        echo 'ok2'
    }
    [[ ! (-f $OUTFILE) ]] && {
        ERRORS="$ERRORS\nError: output file have not been created."
        result=1
        echo 'ok3'
    }
    [[ $(wc - l $OUTFILE) != $1 ]] && {
        ERRORS="$ERRORS\nError: Expected: $1; Actual: $(wc - l $OUTFILE)"
        result=1
        echo 'ok4'
    }
    echo 'ok5'
    return result
}

printError(){
    echo 'ok6'
    if [ $(testError $1) -ne 0 ]; then
        echo "E"
        let NBFAIL+=1
    else
        echo "."
    fi
    let NBTEST+=1
}

run(){
    java -jar PathwayEnrichment-1.0.2-jar-with-dependencies.jar $@
}

unitTests(){
    local EXPECTED_LENGTH=( 50 19 33 33 53 )
    for i in `seq 0 $((${#TESTS[@]}-1))`; do
        run "-i $INFILE "${TESTS[i]}
        printError ${EXPECTED_LENGTH[i]}
    done
}

functionalTests(){
    local EXPECTED_LENGTH=(3 1 1 1 4 0 0 0)
    createdDummyFiles
    for i in `seq 0 $((${#TESTS[@]}-1))`; do
        run "-i $DUMMY_INFILE "${TESTS[i]}
        #printError ${EXPECTED_LENGTH[i]}
        printf "\n\n*****\n\n\n"
    done
}

mkdir tmp2
#wget -P "$DIR"/tmp/ http://.../infile.tsv
#wget -P "$DIR"/tmp/ http://.../outfile.tsv #TODO: zip avec un set d'output pour comparer avec l'expected
#unitTests
functionalTests
rm -r tmp2/

printf "$NBTEST done: $NBFAIL failed\n$ERRORS"

[[ -z $ERRORS ]] || exit 1
exit 0