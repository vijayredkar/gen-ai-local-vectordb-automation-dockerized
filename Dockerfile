FROM openjdk:17
VOLUME /tmp
COPY target/gen-ai-local-vectordb.jar gen-ai-local-vectordb.jar
ENV JAVA OPTS=""
ENTRYPOINT exec java -jar gen-ai-local-vectordb.jar --debug