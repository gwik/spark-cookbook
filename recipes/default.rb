#
# Cookbook Name:: spark
# Recipe:: default
#
# Copyright (C) 2014 Antonin Amand
#
# MIT License
#

include_recipe "scala"

archive = "#{Chef::Config[:file_cache_path]}/spark.tar.gz"
extract_path = "/tmp/spark/archive"
spark_path = node['spark']['install_dir']
bin_path = File.join(spark_path, 'sbin')

remote_file archive do
  source node['spark']['bin_url']
  checksum node['spark']['bin_checksum']
end

directory File.dirname(spark_path) do
  mode "0755"
  recursive true
end

group node['spark']['group'] do
  system true
end

user node['spark']['username'] do
  gid node['spark']['group']
  system true
  shell "/bin/false"
end

bash 'install_spark' do
  cwd ::File.dirname(archive)
  code <<-EOH
    rm -rf '#{extract_path}'
    mkdir -p '#{extract_path}'
    tar xzf '#{archive}' -C '#{extract_path}'
    mv #{extract_path}/spark* '#{spark_path}'
  EOH
  not_if { ::File.exists?(spark_path) }
end
