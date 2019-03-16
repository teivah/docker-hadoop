FROM ubuntu:16.04

MAINTAINER teivah

ENV HADOOP_HOME /opt/hadoop
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN \
  apt-get update && apt-get install -y \
  ssh \
  rsync \
  vim \
  openjdk-8-jdk

RUN \
  wget http://apache.mirror.anlx.net/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz && \
  tar -xzf hadoop-2.9.2.tar.gz && \
  mv hadoop-2.9.2 $HADOOP_HOME && \
  echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
  echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc

RUN \
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
  chmod 0600 ~/.ssh/authorized_keys

ADD configs/*xml $HADOOP_HOME/etc/hadoop/

ADD configs/ssh_config /root/.ssh/config

ADD start-hadoop.sh start-hadoop.sh

RUN mkdir $HADOOP_HOME/tmp

EXPOSE 8088 50070 50075 50030 50060

CMD bash start-hadoop.sh