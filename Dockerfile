#Dockerfile for pathway enrichment tool
#
#Author: E. Camenen
#
#Copyright: PhenoMeNal/INRA Toulouse 2017

FROM java:8

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

ENV TAG_NUMBER 2.0

LABEL Description="Predicts enrichment among a (human) metabolic network (Recon 2v02 flat) from a fingerprint"
LABEL software.version=$TAG_NUMBER
LABEL version="2.0"
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
#RUN chmod +x /usr/local/bin/runTest1.sh

ENTRYPOINT ["java", "-jar", "pathwayEnrichment.jar"]
