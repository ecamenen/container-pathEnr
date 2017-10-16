FROM java:8

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

LABEL Description="Predicts pathway enrichment"
LABEL software.version="1.0"
LABEL version="1.0"
LABEL software="PathwayEnrichment"
LABEL website="metexplore.toulouse.inra.fr"

ENV TAG_NUMBER 1.0.2

#ADD digicertca.crt /usr/local/share/ca-certificates/digicertca.crt

# Tool installation, cleaning
RUN apt-get update && apt-get install -y --no-install-recommends maven && \
	git clone --depth 1 --single-branch --branch $TAG_NUMBER https://github.com/MetExplore/phnmnl-PathwayEnrichment.git Javafiles && \
	cd Javafiles && \
	git checkout $TAG_NUMBER && \
	cp -r data/ / && \
	mvn install:install-file install:install-file -Dfile=parseBioNet.jar -DgroupId=fr.inra.toulouse.metexplore -DartifactId=parseBioNet -Dversion=0.0.1 -Dpackaging=jar && \
	mvn install && \
	apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*  && \
	cp /root/.m2/repository/fr/inra/toulouse/metexplore/PathwayEnrichment/$TAG_NUMBER/PathwayEnrichment-$TAG_NUMBER-jar-with-dependencies.jar / && \
	cd / && rm -rf Javafiles

# Test Scripts
#ENV PATH=$PATH:/scripts
#ADD runTest1.sh /usr/local/bin/runTest1.sh
#RUN chmod +x runTest1.sh

# Define EntryPoint
#ENTRYPOINT ["java", "-jar", "PathwayEnrichment-$TAG_NUMBER-jar-with-dependencies.jar"]
