#!/bin/sh

DIR="/home/bmerlet/Documents/PathwayEnrichment"
SBML="$DIR/recon2.v03_ext_noCompartment_noTransport_v2.xml"
INFILE="$DIR/tmp/sacurineVariableMetadataEnhanced.tsv"
DUMMY_INFILE="$DIR/tmp/dummyInfile.tsv"
OUTFILE="$DIR/tmp/output4.tsv"
DUMMY_OUTFILE="$DIR/tmp/dummyOutfile.tsv"
ERRORS=""
NBFAIL=0
NBTEST=0

createdDummyFiles(){
    local LINE="$"
    cat "variableMetadata\tdatabase_identifier\tchemical_formula\tsmiles\tinchi\tmetabolite_identification\tmass_to_charge\tmass_of_proton\tmass
    \tfragmentation\tmodifications\tcharge\tretention_time\treliability\tsample_mean\tsample_sd\tsample_CV\tpool_mean\tpool_sd\tpool_CV
    \tpoolCV_over_sampleCV\tchebi.id\tchemspider.id\tbiodb.compound.name\n$LINE" > $DUMMY_INFILE
}

testError(){
    result=0
    [ $? -ne 0 ] && {
        ERRORS="$ERRORS\n$?"
        result=1
    }
    [! -f $outfile] &&{
        ERRORS="$ERRORS\nError: output file have not been created."
        result=1
        }
    [ $(wc - l "$") -ne EXPECTED_LENGTH ] && {
        ERRORS+="$ERRORS\nError: Expected: $1; Actual: $2."
        result=1
    }
    return result
}

printError(){
    if [ $(testError $@) -ne 0 ]; then
        echo "E"
        let NBFAIL+=1
    else
        echo "."
    fi
    let NBTEST+=1
}

run(){
    CMD="java -jar ../phnml-pathwayEnrichment.jar "$@
    eval $CMD
}

unitTests(){
    TESTS=('' '-f 25' '-l p,h,c' '-l c,h,p' '-l ')
    #mapped=(105 3 88 88 139)
    EXPECTED_LENGTH=(50 19 33 33 53)
    for i in `seq 0 3`
    do
        run "-i $INFILE "${TESTS[i]}
        printError ${EXPECTED_LENGTH[i]} ${TESTS[i]}
    done

functionalTests(){
   TESTS=('' '' '-f 25' '-l p,h,c' '-l c,h,p' '-l')
   INPUT=(
    #test inchi mapping
    "Malic acid\tNA\tC4H6O5\tOC(CC(O)=O)C(O)=O\tInChI=1S/C4H6O5/c5-2(4(8)9)1-3(6)7/h2,5H,1H2,(H,6,7)(H,8,9)\tMalic acid\t133,013511\t1,00727647\t134,02078747\tNA\t[(M-H)]-\t1\t1,08\t5\t2,705885808\t0,2514229882\t0,0929170726\t455610,344205852\t48548,3017483153\t0,1065566275\t1,1467927746\t6650\tNA\tmalic acid"
    #test chebi mapping
    "Testosterone glucuronide\tCHEBI:28835\tC25H36O8
    \t[H][C@@]12CCC3=CC(=O)CC[C@]3(C)[C@@]1([H])CC[C@]1(C)[C@H](CC[C@@]21[H])O[C@@H]1O[C@@H]([C@@H](O)[C@H](O)[C@H]1O)C(O)=O
    \tNA\tTestosterone glucuronide\t463,2329\t1,00727647\t464,24017647\tNA\t[(M-H)]-\t1\t7,9\t4\t2,1475578771\t0,5701078279\t0,265467969
    \t178149,617939526\t12351,5841321731\t0,0693326445\t0,2611714128\t28835\tNA\ttestosterone 17-glucosiduronic acid"
    #test filtered
    "Testosterone glucuronide\tCHEBI:28835\tC25H36O8\t[H][C@@]12CCC3=CC(=O)CC[C@]3(C)[C@@]1([H])CC[C@]1(C)[C@H](CC[C@@]21[H])O[C@@H]1O[C@@H]([C@@H](O)[C@H](O)[C@H]1O)C(O)=O\tInChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1\tTestosterone glucuronide\t463,2329\t1,00727647\t464,24017647\tNA\t[(M-H)]-\t1\t7,9\t4\t2,1475578771\t0,5701078279\t0,265467969\t178149,617939526\t12351,5841321731\t0,0693326445\t0,2611714128\t28835\tNA\ttestosterone 17-glucosiduronic acid\tplsda|randomforest|svm\n
    Malic acid\tNA\tC4H6O5\tOC(CC(O)=O)C(O)=O\tInChI=1S/C4H6O5/c5-2(4(8)9)1-3(6)7/h2,5H,1H2,(H,6,7)(H,8,9)\tMalic acid\t133,013511\t1,00727647\t134,02078747\tNA\t[(M-H)]-\t1\t1,08\t5\t2,705885808\t0,2514229882\t0,0929170726\t455610,344205852\t48548,3017483153\t0,1065566275\t1,1467927746\t6650\tNA\tmalic acid"
    #test p layer
    "Testosterone glucuronide\tCHEBI:28835\tC25H36O8\t[H][C@@]12CCC3=CC(=O)CC[C@]3(C)[C@@]1([H])CC[C@]1(C)[C@H](CC[C@@]21[H])O[C@@H]1O[C@@H]([C@@H](O)[C@H](O)[C@H]1O)C(O)=O\tInChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1\tTestosterone glucuronide\t463,2329\t1,00727647\t464,24017647\tNA\t[(M-H)]-\t1\t7,9\t4\t2,1475578771\t0,5701078279\t0,265467969\t178149,617939526\t12351,5841321731\t0,0693326445\t0,2611714128\t28835\tNA\ttestosterone 17-glucosiduronic acid\tplsda|randomforest|svm\n
    Malic acid\tNA\tC4H6O5\tOC(CC(O)=O)C(O)=O\tInChI=1S/C4H6O5/c5-2(4(8)9)1-3(6)7/h2,5H,1H2,(H,6,7)(H,8,9)\tMalic acid\t133,013511\t1,00727647\t134,02078747\tNA\t[(M-H)]-\t1\t1,08\t5\t2,705885808\t0,2514229882\t0,0929170726\t455610,344205852\t48548,3017483153\t0,1065566275\t1,1467927746\t6650\tNA\tmalic acid"
    #test shuffle layers
    "Testosterone glucuronide\tCHEBI:28835\tC25H36O8\t[H][C@@]12CCC3=CC(=O)CC[C@]3(C)[C@@]1([H])CC[C@]1(C)[C@H](CC[C@@]21[H])O[C@@H]1O[C@@H]([C@@H](O)[C@H](O)[C@H]1O)C(O)=O\tInChI=1S/C25H36O8/c1-24-9-7-13(26)11-12(24)3-4-14-15-5-6-17(25(15,2)10-8-16(14)24)32-23-20(29)18(27)19(28)21(33-23)22(30)31/h11,14-21,23,27-29H,3-10H2,1-2H3,(H,30,31)/t14-,15-,16-,17-,18-,19-,20+,21-,23+,24-,25-/m0/s1\tTestosterone glucuronide\t463,2329\t1,00727647\t464,24017647\tNA\t[(M-H)]-\t1\t7,9\t4\t2,1475578771\t0,5701078279\t0,265467969\t178149,617939526\t12351,5841321731\t0,0693326445\t0,2611714128\t28835\tNA\ttestosterone 17-glucosiduronic acid\tplsda|randomforest|svm\n
    Malic acid\tNA\tC4H6O5\tOC(CC(O)=O)C(O)=O\tInChI=1S/C4H6O5/c5-2(4(8)9)1-3(6)7/h2,5H,1H2,(H,6,7)(H,8,9)\tMalic acid\t133,013511\t1,00727647\t134,02078747\tNA\t[(M-H)]-\t1\t1,08\t5\t2,705885808\t0,2514229882\t0,0929170726\t455610,344205852\t48548,3017483153\t0,1065566275\t1,1467927746\t6650\tNA\tmalic acid"
   #test formula layers
    "Cinnamoylglycine\tCHEBI:68616\tC11H11NO3\tOC(=O)CNC(=O)C=Cc1ccccc1\tInChI=1S/C11H11NO3/c13-10(12-8-11(14)15)7-6-9-4-2-1-3-5-9/h1-7H,8H2,(H,12,13)(H,14,15)/b7-6+\tCinnamoylglycine\t204,065452\t1,00727647\t205,07272847\tNA\t[(M-H)]-\t1\t7,03\t5\t4,0160399219\t0,5133270871\t0,1278192192\t11742041,4996239\t2134365,54261586\t0,1817712484\t1,4220963763\t68616\tNA\tN-cinnamoylglycine"
     )
    EXPECTED_LENGTH=(3 2 2 2 2 2)
    for i in `seq 0 4`
    do
        createdDummyFiles ${INPUT[i]}
        run "-i $DUMMY_INFILE "${TESTS[i]}
        printError ${EXPECTED_LENGTH[i]} ${TESTS[i]}
    done
}

mkdir tmp
wget -P "$DIR"/tmp/ http://.../infile.tsv
wget -P "$DIR"/tmp/ http://.../outfile.tsv #TODO: zip avec un set d'output pour comparer avec l'expected

functionalTests
#unitTests

echo "$NBTEST done: $NBFAIL failed\n$ERRORS"

rm -r temp/
