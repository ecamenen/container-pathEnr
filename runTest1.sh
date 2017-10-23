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
ERRORS=""
NBFAIL=0
NBTEST=0
TESTS=('' '-f 30' '-l c,h,p' '-l p,h,c' '-l')
NAME_TESTS=('regular' 'filtered' 'mapping including p layer' 'with shuffled layer parameters' 'mapping on formula only')
EXPECTED_LENGTH=(45 19 29 29 48)

createdDummyFile(){
   (cat <<-EOF
variableMetadata	database_identifier	chemical_formula	smiles	inchi	metabolite_identification	mass_to_charge	mass_of_proton	mass	fragmentation	modifications	charge	retention_time	reliability	sample_mea	poolCV_over_sampleCV	chebi.id	chemspider.id	biodb.compound.name
Testosterone glucuronide	CHEBI:28835	C25H36O8	[H][C@@]12CCC3=CC(=O)CC[C@]3(C)[C@@]1([H])CC[C@]1(C)[C@H](CC[C@@]21[H])O[C@@H]1O[C@@H]([C@@H](O)[C@H](O)[C@H]1O)C(O)=O	InChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1	Testosterone glucuronide	463,2329	1,00727647	464,24017647	NA	[(M-H)]-	1	7,9	4	2,1475578771	0,5701078279	0,265467969	178149,617939526	12351,5841321731	0,0693326445	0,2611714128	28835	NA	testosterone 17-glucosiduronic acid						plsda|randomforest|svm
Malic acid	NA	C4H6O5	OC(CC(O)=O)C(O)=O	InChI=1S/C4H6O5/c5-2(4(8)9)1-3(6)7/h2,5H,1H2,(H,6,7)(H,8,9)	Malic acid	133,013511	1,00727647	134,02078747	NA	[(M-H)]-	1	1,08	5	2,705885808	0,2514229882	0,0929170726	455610,344205852	48548,3017483153	0,1065566275	1,1467927746	6650	NA	malic acid
Cinnamoylglycine	CHEBI:68616	C11H11NO3	OC(=O)CNC(=O)C=Cc1ccccc1	InChI=1S/C11H11NO3/c13-10(12-8-11(14)15)7-6-9-4-2-1-3-5-9/h1-7H,8H2,(H,12,13)(H,14,15)/b7-6+	Cinnamoylglycine	204,065452	1,00727647	205,07272847	NA	[(M-H)]-	1	7,03	5	4,0160399219	0,5133270871	0,1278192192	11742041,4996239	2134365,54261586	0,1817712484	1,4220963763	68616	NA	N-cinnamoylglycine
EOF
    ) > $INFILE
}

createdDummyOutput(){
    local DUMMY_OUTFILE="tmp/$OUTFILE1$1"
    printf "Mapped\tInputFile's name\tMetExplore's name\ntrue\tTestosterone glucuronide\ttestosterone 3-glucosiduronic acid\n" > $DUMMY_OUTFILE;
    case $1 in
        0) printf "true\tMalic acid\t(S)-malate(2-)\nfalse\tCinnamoylglycine\n" >> $DUMMY_OUTFILE;;
        1) printf "true	Testosterone glucuronide	testosterone 3-glucosiduronic acid\n" >> $DUMMY_OUTFILE;;
        2 | 3) printf "false\tMalic acid\nfalse\tCinnamoylglycine\n" >> $DUMMY_OUTFILE;;
        4)printf "true\tMalic acid\t(S)-malate(2-)\ntrue\tCinnamoylglycine\t5-Methoxyindoleacetate\n" >> $DUMMY_OUTFILE;;
    esac
}

testError(){
    local NBLINE=$( wc $OUTFILE2 | awk '{print $1}')
    local MSG="$ERRORS\nTest \"${NAME_TESTS[$3]}\""

    [ $2 -ne 0 ] && {
        ERRORS="$MSG: Program exited with error"
        return 1
    }

    [[ ( ! -f $OUTFILE1 ) ||  ( ! -f $OUTFILE2) ]] && {
        ERRORS="$MSG: Output files have not been created."
        return 1
    }

    [ $NBLINE -ne $1 ] && {
        ERRORS="$MSG: Expected $1 lines in $OUTFILE2, Actual=$NBLINE lines."
        return 1
    }

    [[ -n $(cmp tmp/$OUTFILE1$3 $OUTFILE1) ]] && {
        ERRORS="$MSG: Expected $OUTFILE1 and actual output files are not identicals."
        return 1
    }

    rm $OUTFILE1 $OUTFILE2
    return 0
}

printError(){
    let NBTEST+=1
    testError $1 $2 $3
    if [ $? -ne 0 ]; then
        echo -n "E"
        let NBFAIL+=1
    else echo -n "."
    fi
}

run(){
    java -jar pathwayEnrichment.jar $@ >> resultRuns.log 2>&1
}

tests(){
    for i in `seq 0 $((${#TESTS[@]} -1))`; do
        if [ -z $1 ]; then
        wget -q -P tmp/ https://raw.githubusercontent.com/MetExplore/container-PathwayEnrichment/master/testData/mapping.tsv"${i}"
        else createdDummyOutput $i
        fi
        run "-i $INFILE ${TESTS[i]}"
        EXIT=$?
        printError ${EXPECTED_LENGTH[i]} $EXIT $i
    done
}

quickTests(){
    EXPECTED_LENGTH=(4 2 2 2 5)
    INFILE="tmp/dummyInfile.tsv"
    createdDummyFile
    tests true
}

getElapsedTime(){
    END_TIME=$(date -u -d $(date +"%H:%M:%S") +"%s")
    ELAPSED_TIME=$(date -u -d "0 $END_TIME sec - $1 sec" +"%H:%M:%S")
    echo "Time to run the process ${ELAPSED_TIME:3:2}min ${ELAPSED_TIME:6:2}s"
}

main(){
    START_TIME=$(date -u -d $(date +"%H:%M:%S") +"%s")
    printf "Tests in progress, could take a few minutes...\n"
    mkdir tmp
    if [ -z $1 ]; then tests
    else quickTests
    fi
    rm -r tmp/
    printf "\n$NBTEST tests, $NBFAIL failed.$ERRORS\n"
    getElapsedTime $START_TIME
    [[ -z $ERRORS ]] || exit 1
    exit 0
}

main $1