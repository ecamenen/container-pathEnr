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
TESTS=('' '-f 30' '-l c,h,p' '-l p,h,c' '-l' '-chebi 2' '-inchi -1 -chebi 2')
NAME_TESTS=('by default' 'filtered column' 'including p layer in mapping' 'with shuffled layer parameters' 'mapping on formula only' 'chebi column activated' 'inchi column disabled and chebi column activated')
EXPECTED_LENGTH=(41 19 24 24 44 45 25)

createdDummyFile(){
   (cat <<-EOF
variableMetadata	database_identifier	chemical_formula	smiles	inchi	metabolite_identification	mass_to_charge	mass_of_proton	mass	fragmentation	modifications	charge	retention_time	reliability	sample_mea	poolCV_over_sampleCV	chebi.id	chemspider.id	biodb.compound.name
Testosterone glucuronide	NA	C25H36O8	[H][C@@]12CCC3=CC(=O)CC[C@]3(C)[C@@]1([H])CC[C@]1(C)[C@H](CC[C@@]21[H])O[C@@H]1O[C@@H]([C@@H](O)[C@H](O)[C@H]1O)C(O)=O	InChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1	Testosterone glucuronide	463,2329	1,00727647	464,24017647	NA	[(M-H)]-	1	7,9	4	2,1475578771	0,5701078279	0,265467969	178149,617939526	12351,5841321731	0,0693326445	0,2611714128	28835	NA	testosterone 17-glucosiduronic acid						plsda|randomforest|svm
Malic acid	NA	C4H6O5	OC(CC(O)=O)C(O)=O	InChI=1S/C4H6O5/c5-2(4(8)9)1-3(6)7/h2,5H,1H2,(H,6,7)(H,8,9)	Malic acid	133,013511	1,00727647	134,02078747	NA	[(M-H)]-	1	1,08	5	2,705885808	0,2514229882	0,0929170726	455610,344205852	48548,3017483153	0,1065566275	1,1467927746	6650	NA	malic acid
Cinnamoylglycine	CHEBI:68616	C11H11NO3	OC(=O)CNC(=O)C=Cc1ccccc1	InChI=1S/C11H11NO3/c13-10(12-8-11(14)15)7-6-9-4-2-1-3-5-9/h1-7H,8H2,(H,12,13)(H,14,15)/b7-6+	Cinnamoylglycine	204,065452	1,00727647	205,07272847	NA	[(M-H)]-	1	7,03	5	4,0160399219	0,5133270871	0,1278192192	11742041,4996239	2134365,54261586	0,1817712484	1,4220963763	68616	NA	N-cinnamoylglycine
Taurine	CHEBI:15891	C2H7NO3S	C(CS(O)(=O)=O)N	NA	Taurine	124.006693	1.00727647	125.01396947	NA	[(M-H)]-	1	0.88	5	2.61228952156894	0.635845779388173	0.243405554452588	387859.346882448	11652.3712684191	0.0300427754599161	0.123426827820266	15891	NA	taurine
EOF
    ) > $INFILE
}

createdDummyOutput(){
    local DUMMY_OUTFILE1="temp/$OUTFILE1$1"
    local DUMMY_OUTFILE3="temp/$OUTFILE3$1"
    printf "Mapped\tInputFile's name\tSBML's name\tInfile's val\tSBML's val\n" > $DUMMY_OUTFILE1;
    case $1 in
        0) printf "true	Testosterone glucuronide	testosterone 3-glucosiduronic acid	InChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1	InChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1
true	Malic acid	(S)-malate(2-)	InChI=1S/C4H6O5/c5-2(4(8)9)1-3(6)7/h2,5H,1H2,(H,6,7)(H,8,9)	InChI=1S/C4H6O5/c5-2(4(8)9)1-3(6)7/h2,5H,1H2,(H,6,7)(H,8,9)/p-2/t2-/m0/s1
false	Cinnamoylglycine
false	Taurine\n" >> $DUMMY_OUTFILE1
 	printf "2 metabolites have been mapped (on 4).
3 pathways are concerned among the network (on 97)." > $DUMMY_OUTFILE3;;
        1) printf "true	Testosterone glucuronide	testosterone 3-glucosiduronic acid	InChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1	InChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1\n" >> $DUMMY_OUTFILE1
 	printf "1 metabolites have been mapped (on 1).
1 pathways are concerned among the network (on 97)." > $DUMMY_OUTFILE3;;
        2 | 3)  printf "true	Testosterone glucuronide	testosterone 3-glucosiduronic acid	InChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1	InChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1
false	Malic acid
false	Cinnamoylglycine
false	Taurine\n" >> $DUMMY_OUTFILE1
 	printf "1 metabolites have been mapped (on 4).
1 pathways are concerned among the network (on 97)." > $DUMMY_OUTFILE3;;
        4) printf "true	Testosterone glucuronide	testosterone 3-glucosiduronic acid	InChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1	InChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1
true	Malic acid	(S)-malate(2-)	InChI=1S/C4H6O5/c5-2(4(8)9)1-3(6)7/h2,5H,1H2,(H,6,7)(H,8,9)	InChI=1S/C4H6O5/c5-2(4(8)9)1-3(6)7/h2,5H,1H2,(H,6,7)(H,8,9)/p-2/t2-/m0/s1
true	Cinnamoylglycine	5-Methoxyindoleacetate	InChI=1S/C11H11NO3/c13-10(12-8-11(14)15)7-6-9-4-2-1-3-5-9/h1-7H,8H2,(H,12,13)(H,14,15)/b7-6+	InChI=1S/C11H11NO3/c1-15-8-2-3-10-9(5-8)7(6-12-10)4-11(13)14/h2-3,5-6,12H,4H2,1H3,(H,13,14)
false	Taurine\n" >> $DUMMY_OUTFILE1
 	printf "3 metabolites have been mapped (on 4).
4 pathways are concerned among the network (on 97)." > $DUMMY_OUTFILE3;;
        5) printf "true	Testosterone glucuronide	testosterone 3-glucosiduronic acid	InChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1	InChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1
true	Malic acid	(S)-malate(2-)	InChI=1S/C4H6O5/c5-2(4(8)9)1-3(6)7/h2,5H,1H2,(H,6,7)(H,8,9)	InChI=1S/C4H6O5/c5-2(4(8)9)1-3(6)7/h2,5H,1H2,(H,6,7)(H,8,9)/p-2/t2-/m0/s1
true	Taurine	Taurine	CHEBI:15891	CHEBI:15891
false	Cinnamoylglycine\n" >> $DUMMY_OUTFILE1
 	printf "3 metabolites have been mapped (on 4).
6 pathways are concerned among the network (on 97)." > $DUMMY_OUTFILE3;;
        6) printf "true	Taurine	Taurine	CHEBI:15891	CHEBI:15891
false	Testosterone glucuronide
false	Malic acid
false	Cinnamoylglycine\n" >> $DUMMY_OUTFILE1
 	printf "1 metabolites have been mapped (on 4).
3 pathways are concerned among the network (on 97)." > $DUMMY_OUTFILE3;;
    esac
}

testError(){
    local NBLINE=$( wc $OUTFILE2 | awk '{print $1}')
    local BOOLEAN_ERR="false"
    local MSG="$ERRORS\nTest \"${NAME_TESTS[$3]}\": "

    [ $2 -ne 0 ] && {
        MSG=$MSG"Program exited with error. "
        BOOLEAN_ERR="true"
    }

    [[ ( ! -f $OUTFILE1 ) ||  ( ! -f $OUTFILE2) ||  ( ! -f $OUTFILE3) ]] && {
        [ ! -f $OUTFILE1 ] && MSG=$MSG"$OUTFILE1 "
        [ ! -f $OUTFILE2 ] && MSG=$MSG"$OUTFILE2 "
        [ ! -f $OUTFILE3 ] && MSG=$MSG"$OUTFILE3 "
        MSG=$MSG"not created. "
        BOOLEAN_ERR="true"
    }

    [ $NBLINE -ne $1 ] && {
        MSG=$MSG"$1 lines expected in $OUTFILE2. Actual file has $NBLINE lines. "
        BOOLEAN_ERR="true"
    }

    [[ ( -n $(cmp temp/$OUTFILE1$3 $OUTFILE1) ) || ( -n $(cmp temp/$OUTFILE3$3 $OUTFILE3) ) ]] && {
    	compareFile $OUTFILE1 $3
    	compareFile $OUTFILE3 $3
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
    java -jar pathwayEnrichment.jar -o3 info.txt $@ >> resultRuns.log 2>&1
}

tests(){
    local GIT_PATH="https://raw.githubusercontent.com/phnmnl/container-pathwayEnrichment/master/testData"
    for i in `seq 0 $((${#TESTS[@]} -1))`; do
        if [ -z $1 ]; then
            wget -q -P temp/ $GIT_PATH/mapping.tsv"${i}" $GIT_PATH/info.txt"${i}"
        else createdDummyOutput $i
        fi
        run "-i $INFILE ${TESTS[i]}"
        EXIT=$?
        printError ${EXPECTED_LENGTH[i]} $EXIT $i
    done
}

quickTests(){
    EXPECTED_LENGTH=(4 2 2 2 5 7 4)
    INFILE="temp/dummyInfile.tsv"
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
    mkdir temp
    if [ -z $1 ]; then tests
    else quickTests
    fi
    rm -r temp/
    printf "\n$NBTEST tests, $NBFAIL failed.$ERRORS\n"
    getElapsedTime $START_TIME
    [[ -z $ERRORS ]] || exit 1
    exit 0
}

main $1
