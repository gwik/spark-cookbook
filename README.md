# spark-cookbook

[Chef](http://www.getchef.com/chef/) cookbook to install [Apache Spark](http://spark.apache.org/) master, and slaves for standalone mode.

Spark will be installed and run as <tt>['spark']['user']</tt>, the home directory of that user
will be the installed path.

In standalone mode, spark slaves are started from master using ssh
connections to the slaves. Then, if you add add slaves, add them to
<tt>['spark']['slaves']</tt>
and re-run the recipe on master to update the list of slaves.

## Supported Platforms

Only tested on debian. Please fill a ticket if you found incompatibilities with
your platform.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>["chef"]["data_bag_secret_path"]</tt></td>
    <td>String</td>
    <td>Path to secret file to decrypt data bag secret.</td>
    <td><tt>/var/chef/encrypted_data_bag_secret</tt></td>
  </tr>
  <tr>
    <td><tt>["spark"]["master_host"]</tt></td>
    <td>String</td>
    <td>hostname for spark master.</td>
    <td><tt>localhost</tt></td>
  </tr>
  <tr>
    <td><tt>["spark"]["master_port"]</tt></td>
    <td>String</td>
    <td>spark master port.</td>
    <td><tt>7077</tt></td>
  </tr>
  <tr>
    <td><tt>["spark"]["bin_url"]</tt></td>
    <td>String</td>
    <td>URL to download spark <strong>binary</strong> archive.</td>
    <td><tt>http://d3kbcqa49mib13.cloudfront.net/spark-1.0.1-bin-hadoop2.tgz</tt></td>
  </tr>
  <tr>
    <td><tt>["spark"]["bin_checksum"]</tt></td>
    <td>String</td>
    <td>SHA256 checksum to help chef cache the file. Set it if you change <tt>["spark"]["bin_url"]</tt>.</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>["spark"]["install_dir"]</tt></td>
    <td>String</td>
    <td>Where to install spark. Also home directory for <tt>['spark']['user']</tt>.</td>
    <td><tt>/opt/local/spark</tt></td>
  </tr>
  <tr>
    <td><tt>["spark"]["user"]</tt></td>
    <td>String</td>
    <td>Spark runtime user name.</td>
    <td><tt>spark</tt></td>
  </tr>
  <tr>
    <td><tt>["spark"]["group"]</tt></td>
    <td>String</td>
    <td>Spark runtime group</td>
    <td><tt>spark</tt></td>
  </tr>
  <tr>
    <td><tt>["spark"]["slaves"]</tt></td>
    <td>Array[String]</td>
    <td>List of hostname of the slaves.
      You probably want to use private network hostnames or ip addresses.</td>
    <td><tt>[]</tt></td>
  </tr>
</table>

Also you can set `spark-env.sh` environment variables with <tt>['spark']['env']['lowercase key']</tt>.
For example :

    SPARK_LOCAL_IP = 'ec2-ip-xxx.internal'

Here are the supported parameters :

    # Options read when launching programs locally with
    # ./bin/run-example or ./bin/spark-submit
    # - HADOOP_CONF_DIR, to point Spark towards Hadoop configuration files
    # - SPARK_LOCAL_IP, to set the IP address Spark binds to on this node
    # - SPARK_PUBLIC_DNS, to set the public dns name of the driver program
    # - SPARK_CLASSPATH, default classpath entries to append

    # Options read by executors and drivers running inside the cluster
    # - SPARK_LOCAL_IP, to set the IP address Spark binds to on this node
    # - SPARK_PUBLIC_DNS, to set the public DNS name of the driver program
    # - SPARK_CLASSPATH, default classpath entries to append
    # - SPARK_LOCAL_DIRS, storage directories to use on this node for shuffle and RDD data
    # - MESOS_NATIVE_LIBRARY, to point to your libmesos.so if you use Mesos

    # Options read in YARN client mode
    # - HADOOP_CONF_DIR, to point Spark towards Hadoop configuration files
    # - SPARK_EXECUTOR_INSTANCES, Number of workers to start (Default: 2)
    # - SPARK_EXECUTOR_CORES, Number of cores for the workers (Default: 1).
    # - SPARK_EXECUTOR_MEMORY, Memory per Worker (e.g. 1000M, 2G) (Default: 1G)
    # - SPARK_DRIVER_MEMORY, Memory for Master (e.g. 1000M, 2G) (Default: 512 Mb)
    # - SPARK_YARN_APP_NAME, The name of your application (Default: Spark)
    # - SPARK_YARN_QUEUE, The hadoop queue to use for allocation requests (Default: ‘default’)
    # - SPARK_YARN_DIST_FILES, Comma separated list of files to be distributed with the job.
    # - SPARK_YARN_DIST_ARCHIVES, Comma separated list of archives to be distributed with the job.

    # Options for the daemons used in the standalone deploy mode:
    # - SPARK_MASTER_IP, to bind the master to a different IP address or hostname
    # - SPARK_MASTER_PORT / SPARK_MASTER_WEBUI_PORT, to use non-default ports for the master
    # - SPARK_MASTER_OPTS, to set config properties only for the master (e.g. "-Dx=y")
    # - SPARK_WORKER_CORES, to set the number of cores to use on this machine
    # - SPARK_WORKER_MEMORY, to set how much total memory workers have to give executors (e.g. 1000m, 2g)
    # - SPARK_WORKER_PORT / SPARK_WORKER_WEBUI_PORT, to use non-default ports for the worker
    # - SPARK_WORKER_INSTANCES, to set the number of worker processes per node
    # - SPARK_WORKER_DIR, to set the working directory of worker processes
    # - SPARK_WORKER_OPTS, to set config properties only for the worker (e.g. "-Dx=y")
    # - SPARK_HISTORY_OPTS, to set config properties only for the history server (e.g. "-Dx=y")
    # - SPARK_DAEMON_JAVA_OPTS, to set config properties for all daemons (e.g. "-Dx=y")
    # - SPARK_PUBLIC_DNS, to set the public dns name of the master or workers

## Data bags

You must provide an keypair (rsa or dsa) in a databag item :

    spark
      ssh_key
        type: "rsa" or "dsa"
        private_key: the private key
        public_key: the public key

You can generate a keypair with :

    ssh-keygen -t dsa -f spark_key

Put the content of `spark_key.pub` file in `public_key` and
`spark_key` file in `private_key` and `dsa` as type.

## Usage

Include `spark::master` and/or `spark::slave` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[spark::master]"
  ]
}
```

Here is a more concrete example that also configures java and scala :

```json
{
  "java": {
    "install_flavor": "oracle",
    "jdk_version": "8",
    "oracle": {
      "accept_oracle_download_terms": true
    }
  },
  "scala": {
    "version": "2.10.4",
    "home": "/usr/lib/scala",
    "checksum": "b46db638c5c6066eee21f00c447fc13d1dfedbfb60d07db544e79db67ba810c3",
    "url": "http://www.scala-lang.org/files/archive/scala-2.10.4.tgz"
  },
  "spark": {
    "slaves": ["ip-xxx-xxx-xxx-xxx.eu-west-1.compute.internal"]
  },
  "run_list": [
    "recipe[spark::master]"
  ]
}
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (i.e. `add-new-recipe`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request

## License and Authors

Copyright (C) 2014 Antonin Amand

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
