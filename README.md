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


## Usefull Links
- Compile hadoop native code
http://www.ercoppa.org/posts/how-to-compile-apache-hadoop-on-ubuntu-linux.html
- Integrate hadoop with kerberos:
http://wccandlinux.blogspot.in/2016/07/how-to-configure-hadoop-with-kerberos.html

- Enable Sasl in datanodes:
http://coheigea.blogspot.in/2017/05/using-sasl-to-secure-the-data-transfer.html<br>
https://www.ibm.com/support/knowledgecenter/en/SSPT3X_4.2.0/com.ibm.swg.im.infosphere.biginsights.admin.doc/doc/admin_ssl_hbase_mr_yarn_hdfs_web.html<br>
https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.4/bk_security/content/ch_wire-ssl-httpfactory.html
