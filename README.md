![LOGO](Logo_Metexplore.png)
# PathwayEnrichement

Version: 1.0.4

## Short description
Predicts enrichment among a (human) metabolic network (Recon 2v02 flat) from a fingerprint

## Description
Metabolites belonging to the fingerprint (input file) are mapped on Recon2 network (Thiele et al., 2013) using either INCHI, CHEBI or metabolite ID in SBML (or all) information. Pathway enrichment is calculated with an exact Fisher one-tailed test corrected by Bonferroni and Benjamini Hochberg methods. This tool is part of the MetExplore's project consisting in a web server dedicated to the analysis of omics data in the context of genome scale metabolic networks (Cottret et al., 2010).

### Input files
- a fingerprint (tsv or tabular format): a list of identified metabolites containing at least their names (first column), their InChI or their CHEBI, and optionnaly a information indicating if metabolites are significant or not.
- a metabolic network (bionetwork) : optional, by default recon2 sbml file is used (Thiele et al., 2013).

### Output files
- "mapping.tsv": each line corresponds to metabolites from the dataset file: the success or the failure of the mapping, their names in the dataset, those of one or several elements of the network in case of matching.
- "pathwayEnrichment.tsv" contains for each pathway associated with the mapped metabolites: their names, the Fisher's p value of enrichment, the Bonferroni (or other test correction) q-value, the list of mapped metabolites, the number of mapped metabolites and the coverage of mapped metabolites on the total of metabolites contained in the studied pathway.
- "info.txt" contains general information about mapping and pathway enrichment results. This file contains the total number of mapped metabolites, the total number of metabolites from the dataset, the total number of pathways after mapping and the total number of pathways in the original SBML files. Eventually, warnings show doublets in mapping wich are discarded from the pathway analysis. In this case, the user must select the corresponded metabolite ID in the network and relaunch the analysis.

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
docker run docker-registry.phenomenal-h2020.eu/phnmnl/pathwayenrichment -i  <input file> [-s <sbml file>] [-o1 <mapping output file>] [-o2 <pathway enrichment output file>] [-o3 <info output file>] [-name <name column>] [-chebi <CHEBI column>] [-inchi <InChI column>] [-id <ID SBML column>] [-f <filtered column>] [-l <layer selection>] [-h]
```

- ```-i```, ```-s`` are used for inputs files. Only ```-i``` - corresponding to the dataset of fingerprint - is required. ```-s``` - the sbml file where the bionetwork is extracted - used Recon2.02 network by default (Thiele et al., 2013).
```-o1```, ```-o2``` and ```-o3``` could be used to customize output file's name. They contains respectivly mapping (default: "mapping.tsv"), pathway enrichment (default: "pathwayEnrichment.tsv") and log information (some information printing by the program). The creation of the last output is disabled by default.
- ```-name```, ```-f```, ```-inchi```, ```-chebi```, and ```-id``` options point out specific column numbers in the fingerprint file. ```-name``` indicates the name of the metabolites. ```-f``` option is used to discard from the anaylisis lines containing empty values among the selected column (for example : after a statistical pre-selection among the fingerprint). The type of mapping is selected by activating or disabling the last three parameters : InChI, CHEBI, and metabolite's ID used in the SBML. At least one mapping parameter should be activated; multiple parameters could be activated together. By default, ```-name``` and ```-inchi``` are set respectively to 1 and 5 ("1" is considered as the first column); the other parameters are disabled (by choosing "0" or negative values).
- ```-l``` selects the InChI's layers used for mapping. Nine layers could be selected: connections (c), hydrogens atoms (h), charge (q), protons (p), double-bond stereo (b), tetrahedral sp3 stereo (t), isotopic atoms (i), fixed hydrogens (f) and reconnected layers (r). These layers must be set as a list of characters containing the letter of each selected layer separated by commas. By default, this option is set on ```c,h``` for a mapping only on connections and hydrogens atom layers. A whole layers selected must be ```c,h,q,p,b,t,i,f,r```. For mapping on formula only, select ```-l``` option with no parameters after.
- ```-h``` option prints a help.

## References
- Thiele I., Swainston N., Fleming R.M.T., et al. A community-driven global reconstruction of human metabolism (2013). Nature biotechnology 31(5):10. doi:10.1038/nbt.2488.
- Cottret L. , Wildridge D., Vinson F., Barrett M.P., Charles H., Sagot M.-F. and Jourdan F. MetExplore: a web server to link metabolomic experiments and genome-scale metabolic networks. (2010) Nucleic Acids Research 1:38 Suppl:W132-7. doi:10.1093/nar/gkq312.
