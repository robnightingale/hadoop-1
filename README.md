# Hadoop

# Build Hadoop binaries

- Build the docker image
```console
cd build_binary
./build.sh
```

- Run the docker image, this would compile hadoop source code and generate tar.gz file in hadoop-dist/target directory(Note: this would take around 30 minutes to 1 hour)
```console
./run.sh
```

- To view the logs:
```console
./log.sh
```


## Configuration
The following table lists the configurable parameters of hadoop and their default values.

| Parameter                   | Description                                           | Default                |
|-----------------------------|-------------------------------------------------------|------------------------|
| `BRANCH`                    | The branch of the repository                          | `kubernetes`           |
| `BUILD_PATH`                | The location where repository would be cloned         | `/tmp`                 |
| `IMAGE_NAME`                | The name of the docker image.                         | `sumit/hadoop`         |
| `REPO_NAME`                 | The name of the repository in docker registry.        | `hadoop`               |
| `CONTAINER_NAME`            | The name of the container.                            | `hadoop`               |
| `MASTER`                    | The hostname of hadoop master.                        | `hafs-master`          |
| `DOMAIN_NAME`               | The domain name of the hadoop cluster.                | `default.svc.cloud.uat`|
| `HADOOP_INSTALL`            | Location of the hadoop install.                       | `/usr/local/hadoop`    |
| `KEY_PWD`                   | Key password of the jsk files.                        | `sumit@1234`           |
| `ENABLE_HADOOP_SSL`         | Enable SSL for hadoop.                                | `true`                 |
| `ENABLE_KERBEROS`           | Enable kerberos authentication.                       | `true`                 |
| `ENABLE_KUBERNETES`         | Enable kubernetes configuration.                      | `true`                 |
| `REPOSITORY_HOST`           | Repository of hadoop binaries.                        |                        |
| `HADOOP_VERSION`            | Hadoop version.                                       | `hadoop-3.1.0`         |


## Usefull Links
- Compile hadoop native code
http://www.ercoppa.org/posts/how-to-compile-apache-hadoop-on-ubuntu-linux.html
- Integrate hadoop with kerberos:
http://wccandlinux.blogspot.in/2016/07/how-to-configure-hadoop-with-kerberos.html

- Enable Sasl in datanodes:
http://coheigea.blogspot.in/2017/05/using-sasl-to-secure-the-data-transfer.html<br>
https://www.ibm.com/support/knowledgecenter/en/SSPT3X_4.2.0/com.ibm.swg.im.infosphere.biginsights.admin.doc/doc/admin_ssl_hbase_mr_yarn_hdfs_web.html<br>
https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.4/bk_security/content/ch_wire-ssl-httpfactory.html
