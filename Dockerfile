FROM ubuntu:latest

RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install wget ssh openjdk-8-jdk-headless

# Download and unpack Hadoop
RUN wget http://apache.mirrors.spacedump.net/hadoop/common/hadoop-3.0.3/hadoop-3.0.3.tar.gz --progress=bar:force:noscroll \
    && tar xf hadoop-3.0.3.tar.gz \
    && mv hadoop-3.0.3 /usr/local/hadoop \
    && rm hadoop-3.0.3.tar.gz

# Only used for manual testing
RUN apt-get -y install vim

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Generate keys to allow for node communication via SSH. Pseudo-distribute mode simulates this behavior locally.
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ""
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Setup necessary 'HADOOP_HOME' variable and add Hadoop binaries to 'PATH'
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Not sure why this is necessary, something about Hadoop 3.x.x introducing this
ENV HDFS_NAMENODE_USER="root"
ENV HDFS_DATANODE_USER="root"
ENV HDFS_SECONDARYNAMENODE_USER="root"
ENV YARN_RESOURCEMANAGER_USER="root"
ENV YARN_NODEMANAGER_USER="root"

COPY startup.sh $HADOOP_HOME/startup.sh
COPY hadoop_config /usr/local/hadoop/etc/hadoop
COPY ssh_config/config /root/.ssh/

RUN chmod 744 -R $HADOOP_HOME

EXPOSE 9870 9864 9868 8088 9000 8042

ENTRYPOINT $HADOOP_HOME/startup.sh; bash
