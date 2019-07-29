FROM openjdk:8

LABEL maintainer="Stéphane Walter <stephane.walter@me.com>"
LABEL REFRESHED_AT="2019-07-26"
LABEL version="SPARK 2.3"

# We will be running our Spark jobs as `root` user.
USER root

# Working directory is set to the home folder of `vagrant` user.
WORKDIR /root/

# Spark related variables.
ARG SPARK_VERSION=2.3.0
ARG SPARK_BINARY_ARCHIVE_NAME=spark-${SPARK_VERSION}-bin-hadoop2.7
ARG SPARK_BINARY_DOWNLOAD_URL=https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_BINARY_ARCHIVE_NAME}.tgz

# Configure env variables for Spark.
# Also configure PATH env variable to include binary folders of Java and Spark.

ENV SPARK_HOME  /usr/local/spark
ENV PATH        $JAVA_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH

# Download, uncompress and move all the required packages and libraries to their corresponding directories in /usr/local/ folder.
RUN wget -qO - ${SPARK_BINARY_DOWNLOAD_URL} | tar -xz -C /usr/local/ && \
    cd /usr/local/ && \
    ln -s ${SPARK_BINARY_ARCHIVE_NAME} spark && \
    cp spark/conf/log4j.properties.template spark/conf/log4j.properties && \
    sed -i -e s/WARN/ERROR/g spark/conf/log4j.properties && \
    sed -i -e s/INFO/ERROR/g spark/conf/log4j.properties

# Loop to avoid to exit
ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh && \
chmod 700 /etc/bootstrap.sh

EXPOSE 4040 8080 8081 7077

CMD ["/etc/bootstrap.sh", "-d"]

