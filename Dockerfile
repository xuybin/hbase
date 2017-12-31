FROM alpine:latest

VOLUME ["/hdfs"]
RUN HBASE_VER=1.3.1 \
 && URL3="http://archive.apache.org/dist/hbase/$HBASE_VER/hbase-$HBASE_VER-bin.tar.gz" \
 && URL4="https://mirrors.aliyun.com/apache/hbase/$HBASE_VER/hbase-$HBASE_VER-bin.tar.gz" \

 && apk --update add --no-cache wget tar openssh bash openjdk8 \
 && (wget -t 10 --max-redirect 1 --retry-connrefused -O "hbase-$HBASE_VER.tar.gz" "$URL3" || \
		 wget -t 10 --max-redirect 1 --retry-connrefused -O "hbase-$HBASE_VER.tar.gz" "$URL4") \
		  
 && sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd \
 && ssh-keygen -A \
 && ssh-keygen -t rsa -f /root/.ssh/id_rsa -P '' \
 && cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys \
 && { \
		 echo 'Host *'; \
		 echo '  UserKnownHostsFile /dev/null'; \
		 echo '  StrictHostKeyChecking no'; \
		 echo '  LogLevel quiet'; \
	  } > /root/.ssh/config \
	  		 
 && mkdir -p /hbase \
 && tar zxf hbase-$HBASE_VER.tar.gz -C /hbase --strip 1 \
 && sed -i '/^# export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/default-jvm\nexport HBASE_HOME=/hbase\nexport HBASE_LOG_DIR=/hdfs/logs\nexport HBASE_PID_DIR=/hdfs/pids\n:' /hbase/conf/hbase-env.sh \
 
 && echo -e  '<?xml version="1.0"?>\n<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>\n'\
'<configuration>\n'\
'    <property>\n'\
'        <name>hbase.cluster.distributed</name>\n'\
'        <value>true</value>\n'\
'    </property>\n'\
'    <property>\n'\
'        <name>hbase.column.max.version</name>\n'\
'        <value>10</value>\n'\
'    </property>\n'\
'    <property>\n'\
'        <name>hbase.tmp.dir</name>\n'\
'        <value>/hdfs/tmp</value>\n'\
'    </property>\n'\
'    <property>\n'\
'        <name>hbase.rootdir</name>\n'\
'        <value>hdfs://master:9000/hbase</value>\n'\
'    </property>\n'\
'    <property>\n'\
'        <name>hbase.zookeeper.quorum</name>\n'\
'        <value>#ZKS</value>\n'\
'    </property>\n'\
'</configuration>\n'\
>/hbase/conf/hbase-site.xml \


 && echo -e '#!/bin/bash\n'\
'/hadoop/sbin/start-dfs.sh\n'\
'/hbase/bin/start-hbase.sh\n'\
>/start-hbase.sh \
 && chmod -v +x /start-hbase.sh \
 
 && echo -e '#!/bin/bash\n'\
'/hadoop/sbin/stop-dfs.sh\n'\
'/hbase/bin/stop-hbase.sh\n'\
>/stop-hbase.sh \
 && chmod -v +x /stop-hbase.sh \

 && echo -e '#!/bin/bash\n'\
'export JAVA_HOME=/usr/lib/jvm/default-jvm\n'\
'export PATH=$PATH:/hbase/bin\n'\
>/etc/profile.d/hbase.sh \
 && chmod -v +x /etc/profile.d/hbase.sh \

 && echo -e '#!/bin/sh\n'\
'if [ ! -d "/hdfs/namenode" ]; then\n'\
'    mkdir -p /hdfs/logs /hdfs/pids /hdfs/tmp\n'\
'fi\n'\
'if [ -z ${SLAVES} ]; then\n'\
'    SLAVES="slave1,slave2"\n'\
'    BKMS="slave1"\n'\
'fi\n'\
'awk "BEGIN{info=\"$SLAVES\";tlen=split(info,tA,\",\");for(k=1;k<=tlen;k++){print tA[k];}}">/hbase/conf/regionservers\n'\
'sed -i 's/#ZKS/$SLAVES/' hbase/conf/hbase-site.xml\n'\
'if [ !-z ${BKMS} ]; then\n'\
'    awk "BEGIN{info=\"$BKMS\";tlen=split(info,tA,\",\");for(k=1;k<=tlen;k++){print tA[k];}}">/hbase/conf/backup-masters\n'\
'fi\n'\
'exec /usr/sbin/sshd -D '\
>/usr/local/bin/entrypoint.sh \
 && chmod -v +x /usr/local/bin/entrypoint.sh \
 
 
 && apk del wget tar \
 && rm -rf /hbase/doc /hbase-$HBASE_VER.tar.gz \
 && rm -rf /var/cache/apk/* /tmp/*
 

ENTRYPOINT ["entrypoint.sh"]

# EXPOSE 8020 8042 8088 9000 10020 19888 50010 50020 50070 50075 50090