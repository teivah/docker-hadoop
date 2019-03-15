#FROM java:openjdk-8-jre
#
#ENV HADOOP_VERSION 3.2.0
#
#RUN apt-get update && \
#    wget -q http://apache.mirror.anlx.net/hadoop/common/hadoop-"$HADOOP_VERSION"/hadoop-"$HADOOP_VERSION".tar.gz -O /tmp/hadoop.tar.gz && \
#    tar xfz /tmp/hadoop.tar.gz && \
#    rm /tmp/hadoop.tar.gz && \
#    ls && \
#    pwd && \
#    mv hadoop-"$HADOOP_VERSION" /opt/hadoop
#
#EXPOSE 50070 50075 50090 50105 8020 50010 50020 50100 9000
#ENV HDFS_NAMENODE_USER root
#ENV HDFS_DATANODE_USER root
#ENV HDFS_SECONDARYNAMENODE_USER root
#ENV YARN_RESOURCEMANAGER_USER root
#ENV YARN_NODEMANAGER_USER root
##ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
##RUN echo $JAVA_HOME
##ENV PATH $PATH:$JAVA_HOME/bin
#RUN apt-get install -y ssh
#RUN apt-get install -y rsync
#RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64' >> /opt/hadoop/etc/hadoop/hadoop-env.sh
#ADD ssh_config /root/.ssh/config
## create ssh keys
#
#RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
#  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
#  chmod 0600 ~/.ssh/authorized_keys
##RUN /etc/init.d/ssh start
##RUN /etc/init.d/ssh start
#ADD core-site.xml.template /opt/hadoop/etc/hadoop/core-site.xml.template
#RUN sed s/HOSTNAME/localhost/ /opt/hadoop/etc/hadoop/core-site.xml.template > /opt/hadoop/etc/hadoop/core-site.xml
#
##RUN openssh-server
#
#RUN apt-get clean
##ENTRYPOINT ["/opt/hadoop/sbin/start-all.sh"]
##CMD service ssh restart && /opt/hadoop/sbin/start-all.sh
##CMD ["/etc/bootstrap.sh", "-d"]
##ENTRYPOINT ["ssh", "localhost"]
##ENTRYPOINT ["/etc/init.d/ssh", "status"]
#RUN cat /opt/hadoop/etc/hadoop/core-site.xml
##CMD /etc/init.d/ssh start && /opt/hadoop/sbin/start-dfs.sh && /opt/hadoop/bin/hdfs dfs -mkdir -p /user/root
##CMD /etc/init.d/ssh start && /opt/hadoop/bin/hdfs namenode -format && /opt/hadoop/sbin/start-dfs.sh && /opt/hadoop/sbin/start-yarn.sh && tail -f /dev/null
#CMD /etc/init.d/ssh start && /opt/hadoop/sbin/start-dfs.sh && /opt/hadoop/sbin/start-yarn.sh && /opt/hadoop/bin/hdfs dfs -mkdir -p /user/root && tail -f /dev/null

FROM ubuntu:16.04

# install packages
# set environment vars
ENV HADOOP_HOME /opt/hadoop
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# install packages
RUN \
  apt-get update && apt-get install -y \
  ssh \
  rsync \
  vim \
  openjdk-8-jdk


# download and extract hadoop, set JAVA_HOME in hadoop-env.sh, update path
RUN \
  wget http://apache.mirror.anlx.net/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz && \
  tar -xzf hadoop-2.9.2.tar.gz && \
  mv hadoop-2.9.2 $HADOOP_HOME && \
  echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
  echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc

# create ssh keys
RUN \
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
  chmod 0600 ~/.ssh/authorized_keys

# copy hadoop configs
ADD configs/*xml $HADOOP_HOME/etc/hadoop/

# copy ssh config
ADD configs/ssh_config /root/.ssh/config

# copy script to start hadoop
ADD start-hadoop.sh start-hadoop.sh

RUN mkdir $HADOOP_HOME/tmp

# expose various ports
EXPOSE 8088 50070 50075 50030 50060

# start hadoop
CMD bash start-hadoop.sh