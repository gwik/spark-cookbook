#
# Cookbook Name:: spark
# Recipe:: default
#
# Copyright (C) 2014 Antonin Amand
#
# MIT License
#

require 'etc'

include_recipe "scala"

archive = "#{Chef::Config[:file_cache_path]}/spark.tar.gz"
extract_path = "/tmp/spark/archive"
spark_path = node['spark']['install_dir']
bin_path = File.join(spark_path, 'sbin')
spark_user = node["spark"]["user"]

remote_file archive do
  source node['spark']['bin_url']
  checksum node['spark']['bin_checksum']
end

directory File.dirname(spark_path) do
  mode "0755"
  recursive true
end

spark_group = node['spark']['group']

group spark_group do
  system true
end

user spark_user do
  gid spark_group
  system true
  shell "/bin/bash"
  home spark_path
end

bash 'install_spark' do
  cwd ::File.dirname(archive)
  code <<-EOH
    rm -rf '#{extract_path}'
    mkdir -p '#{extract_path}'
    tar xzf '#{archive}' -C '#{extract_path}'
    mv #{extract_path}/spark* '#{spark_path}'
    chown -R '#{spark_user}:#{spark_group}' '#{spark_path}'
  EOH
  not_if { ::File.exists?(spark_path) }
end

template "spark-env.sh" do
  mode "0644"
  owner "root"
  path File.join(spark_path, "conf", "spark-env.sh")
  variables :spark_env => node["spark"]["env"]
end

directory "#{spark_path}/.ssh" do
  mode "0700"
  owner spark_user
end
