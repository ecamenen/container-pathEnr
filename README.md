![LOGO](Logo_Metexplore.png)
# PathwayEnrichement

Version: 2.1

## Short description
Predicts pathway enrichment into a (human) metabolic network (Recon v2.03)

## Description
Chemical entities (metabolites, reactions, enzymes, proteins or genes) belonging to the fingerprint (the input file) are mapped on Recon2 network (Thiele et al., 2013) using identifiers from a chosen database (among ChEBI, ChemSpider, InChI, InChI key, KEGG, Human Metabolome DataBase, PubChem or SMILES) or by using their isotopic weight. Pathway enrichment is calculated with an exact Fisher one-tailed test (and corrected by Bonferroni and Benjamini Hochberg methods). This tool is part of the MetExplore's project consisting in a web server dedicated to the analysis of omics data in the context of genome scale metabolic networks (Cottret et al., 2018).

### Input files
- a ```fingerprint``` (tsv or tabular format): required, composed by at least a column containing identifier values to map on the network file. Multi-mapping (i.e., mapping on different identifier) could be performed if these three kind of values are included each in a separate column. Optionally, this program could filter empty values from a designated column (e.g., non-significant bio-entities after a statistical pre-selection).
- a ```metabolic network``` (SBML) : optional, by default Recon v2.03 SBML file (without compartments) (Thiele et al., 2013).

### Output files
- ```checking_format.tsv``` (optional, if bad identifier are detected): each line corresponds to an error in a database identifier in the dataset file: the n° of line, the name of the bio-entity, the concerned database, the InChI layer (optional) and the corresponding wrong value.
- ```mapping.tsv```: each line corresponds to the bio-entities (metabolites, reactions, genes,...) from the dataset file: the success or the failure of the mapping, their names in the dataset, those of one or several elements of the network in case of matching, their identifier in the SBML and the matched values in the fingerprint and in the SBML.
- ```pathwayEnrichment.tsv```: contains for each pathway associated with the mapped entities: their names, the number of mapped entities and their coverage on the total of bio-entities contained in the studied pathway, the Fisher's p value of enrichment, the Bonferroni and the Benjamini-Hochberg corrections, the list of the mapped bio-entities and their corresponding name and identifier in the SBML.
- ```information.txt``` (if -gal or -galaxy parameter is activated): contains general information about mapping and pathway enrichment results. This file contains the total number of mapped bio-entities with the coverage in the dataset and in the network, the total number of enriched pathways and the coverage in the network. Eventually, warnings alert about default settings or doublets in mapping which are discarded from the pathway analysis. In this last case, the user must choose the corresponded bio-entities' identifier in the network in order to add them in a new column of the fingerprint dataset. Then, the program must be relaunched by using the SBML identifier mapping only (-idSBML <columnNumber>).

## Key features
- Metabolic network
- Modeling
- Pathway analysis
- Prediction

## Functionality
- Post-processing
- Statistical Analysis

## Tool Authors
- MetExplore Group contact-metexplore@inra.fr

## Container Contributors
- Etienne Camenen (INRA Toulouse)

## Git Repository
- https://github.com/phnmnl/container-pathwayEnrichment.git

## Installation
For local installation of the container:
```
docker pull docker-registry.phenomenal-h2020.eu/phnmnl/pathwayenrichment
```

## Usage Instructions
For direct usage of the docker image:

```
docker run docker-registry.phenomenal-h2020.eu/phnmnl/pathwayenrichment -i <input_file>
```

With optional parameters:

```
docker run docker-registry.phenomenal-h2020.eu/phnmnl/pathwayenrichment -i <input_file> [-h] [-v] [-s <sbml_file>] [-o1 <checking_output_file>] [-o2 <mapping_output_file>] [-o3 <pathway_enrichment_output_file>] [-f <filtered_column>] [-sep <separator_column>] [-header] [-sepID <separator_identifiers>] [-noCheck] [-lWarn] [-nameCol <name_column] [-name <name_column>] [-idSBML <SBML_ID_column>] [-chebi <ChEBI_ID_column>] [-kegg <KEGG_ID_column>] [-hmdb <HMDB_ID_column>] [-csid <ChemSpider_ID_column>] [-pubChem <PubChem_ID_column>] [-mass <isotopic_mass_column>] [-prec <precision_error>] [-inchikey <InChIKey_column>] [-inchi <InChI_column>] [-l <layer_selection>] [-t <bio_entity_from_fingerprint>] [-tEnr <bio_entity_to_enrich>]
```

- ```-h (-help)``` for printing the help.
- ```-v (-version)``` for printing the tool's version.

##### Files parameters
- ```-i (-inFile)```, ```-s (-sbml)``` (STRING) are used to specify the inputs files. Only ```-i``` - corresponding to the dataset of fingerprint - is required. ```-s``` - the sbml file where the network is extracted - used Recon v2.03 network by default (Thiele et al., 2013).
- ```-o1 (-outCheck)```, ```-o2 (-outMap)``` and ```-o3 (-outPath)``` (STRING) could be used to specify the output file. They contains respectively results from checking database identifiers format validity (default: disabled), mapping (default: "mapping.tsv") and pathway enrichment (default: "pathwayEnrichment.tsv") 

##### Parsing parameters
- ```-f (-filter)``` (NUMERICAL) the specified column is used to discard from the analysis lines containing empty values (for example : after a statistical pre-selection among the fingerprint). 
- ```-header``` could be used to discard first line of the file to the analysis.
- ```-sep (-separator)``` and ```-sepID (-separatorID)``` (STRING) respectively specify the character used to separate the column in the fingerprint dataset (e.g., "\t") and the identifiers (e.g., ";"). By default, the program uses "\\t" for tabulation separators.
- ```-noChek``` and ```-lWarn``` are used in checking database identifiers step. The first option allow to avoid this step. The second one verify InChI layers when InChI identifiers are included in the fingerprint file.


##### Mapping parameters
- ```-nameCol```, ```-name```, ```-idSBML```, ```-inchi```, ```-inchikey```, ```-chebi```,```-kegg```, ```-hmdb```, ```-pubChem```, ```-csid (-chemspider)``` and ```-mass``` (NUMERICAL) options point out specific column numbers in the fingerprint file. ```-nameCol``` or ```-name``` indicate the name of the bio-entities. Only one of them should be used: the second one to perform name mapping or the first one otherwise. ```-idSBML``` corresponds to the identifier of the bio-entities in the SBML and ```-mass``` to isotopic mass. The others are database identifiers. With At least one mapping parameter should be activated; multiple parameters could be activated together. By default, ```-name``` and ```-id``` are set respectively to 1 and 2 ("1" is considered as the first column); the other parameters are disabled.
- ```-prec (-precision)``` is used as the allowed error (in ppm) used with isotopic mass mapping. 
- ```-l``` (STRING) selects the InChI's layers used to map metabolites. Nine layers could be selected: connections (c), hydrogen atoms (h), charge (q), protons (p), double-bond stereo (b), tetrahedral sp4 stereo (t), isotopic atoms (i), fixed hydrogens (f) and reconnected layers (r). These layers must be set as a list of characters containing the letter of each selected layer separated by commas. By default, this option is set on ```c,h``` for a mapping only on connections and hydrogens atom layers. A whole layers selected must be ```c,h,q,p,b,t,i,f,r```. For mapping on formula only, select ```-l``` option with no parameters after.
- ```-t``` and ```-tEnr``` (NUMERICAL) specify the bio-entities respectively used in input of the process and to perform enrichment analysis: 1 for metabolites (by default as inputs), 2 for reactions, 3 for pathways (by default in enrichment analysis), 4 for enzymes, 5 for proteins and 6 for genes. When there are used in mapping input, the three last only match with SBML identifiers.


## References
- Thiele I., Swainston N., Fleming R.M.T., et al. A community-driven global reconstruction of human metabolism (2013). Nature biotechnology 31(5):10. doi:10.1038/nbt.2488.
- Cottret, L., Frainay, C., Chazalviel, M., et al. (2018). MetExplore: collaborative edition and exploration of metabolic networks. Nucleic acids research, 1.