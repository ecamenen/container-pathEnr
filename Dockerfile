#Dockerfile for pathway enrichment tool
#
#Author: E. Camenen
#
###############################################################################
 # Copyright INRA
 #
 #  Contact: ludovic.cottret@toulouse.inra.fr
 #
 #
 # This software is governed by the CeCILL license under French law and
 # abiding by the rules of distribution of free software.  You can  use,
 # modify and/ or redistribute the software under the terms of the CeCILL
 # license as circulated by CEA, CNRS and INRIA at the following URL
 # "http://www.cecill.info".
 #
 # As a counterpart to the access to the source code and  rights to copy,
 # modify and redistribute granted by the license, users are provided only
 # with a limited warranty  and the software's author,  the holder of the
 # economic rights,  and the successive licensors  have only  limited
 # liability.
 #  In this respect, the user's attention is drawn to the risks associated
 # with loading,  using,  modifying and/or developing or reproducing the
 # software by the user in light of its specific status of free software,
 # that may mean  that it is complicated to manipulate,  and  that  also
 # therefore means  that it is reserved for developers  and  experienced
 # professionals having in-depth computer knowledge. Users are therefore
 # encouraged to load and test the software's suitability as regards their
 # requirements in conditions enabling the security of their systems and/or
 # data to be ensured and,  more generally, to use and operate it in the
 # same conditions as regards security.
 #  The fact that you are presently reading this means that you have had
 # knowledge of the CeCILL license and that you accept its terms.
################################################################################

FROM java:8

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

ENV TAG_NUMBER 2.0

LABEL Description="Predicts enrichment among a (human) metabolic network (Recon v2.03) from a fingerprint"
LABEL software.version=2.0
LABEL version=2.1
LABEL software="PathwayEnrichment"
LABEL website="metexplore.toulouse.inra.fr"
LABEL tags="Metabolomics"

RUN apt-get update && apt-get install -y --no-install-recommends maven && \
	git clone --depth 1 --single-branch --branch $TAG_NUMBER https://github.com/MetExplore/phnmnl-PathwayEnrichment.git Javafiles && \
	cd Javafiles && \
	git checkout $TAG_NUMBER && \
	cp -r data/ / && \
	mvn install:install-file install:install-file -Dfile=parseBioNet.jar -DgroupId=fr.inra.toulouse.metexplore -DartifactId=parseBioNet -Dversion=0.0.1 -Dpackaging=jar && \
	mvn install && \
	apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*  && \
	mv /root/.m2/repository/fr/inra/toulouse/metexplore/PathwayEnrichment/$TAG_NUMBER/PathwayEnrichment-$TAG_NUMBER-jar-with-dependencies.jar /pathwayEnrichment.jar && \
	cd / && rm -rf Javafiles


ADD runTest1.sh /usr/local/bin/runTest1.sh
RUN chmod +x /usr/local/bin/runTest1.sh

ENTRYPOINT ["java", "-jar", "pathwayEnrichment.jar"]
