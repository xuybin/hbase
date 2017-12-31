# xuybin/hbase

## Run HBase&HDFS cluster with docker-compose
In China
```bash
docker rmi -f registry.cn-shenzhen.aliyuncs.com/xuybin/hbase && curl -L -s https://raw.githubusercontent.com/xuybin/hbase/master/docker-compose-aliyun.yml >docker-compose.yml && docker-compose up -d
docker exec -it  master /bin/bash
    /start-hdfs.sh
    /start-hbase.sh
    jps
    exit
docker-compose ps
```
Outside China
```bash
docker rmi -f xuybin/hbase &&curl -L -s https://raw.githubusercontent.com/xuybin/hbase/master/docker-compose.yml >docker-compose.yml && docker-compose up -d
docker exec -it  master /bin/bash
    /start-hdfs.sh
    /start-hbase.sh
    jps
    exit
docker-compose ps
```

### Optional 
```bash
docker ps
docker network ls
docker network inspect  **_hbase
docker volume ls
docker volume inspect **_hdfs-master[slave1,slave2]
```

## Verification HBase&HDFS cluster
```bash
NameNode:visit http://ip:50070
HBaseRESTWeb:visit http://ip:50080
HBaseMasterWeb:visit http://ip:16010
HBaseRegionWebSlave1:visit http://ip:16031
HBaseRegionWebSlave2:visit http://ip:16032
```

## Test HBase&HDFS cluster
```bash

```

## Stop HBase&HDFS cluster
```bash
docker exec -it  master /bin/bash
    /stop-hbase.sh
    /stop-hdfs.sh
    jps
    exit
docker-compose stop
```

## Clean Hadoop cluster
```bash
docker-compose rm -f
docker volume ls
docker volume rm **_hdfs-master[slave1,slave2]
docker network ls
docker network rm  **_hbase
```
