
include_recipe "spark::default"

secret = Chef::EncryptedDataBagItem.load_secret(node["chef"]["data_bag_secret_path"])
key = Chef::EncryptedDataBagItem.load("spark", "ssh_key", secret)
spark_path = node['spark']['install_dir']
spark_user = node["spark"]["user"]

file "#{spark_path}/.ssh/id_#{key['type']}" do
  mode "0400"
  owner spark_user
  content key['private_key']
end

file "#{spark_path}/conf/slaves" do
  mode "0755"
  owner spark_user
  content(node['spark']['slaves'].join("\n") + "\n")
end

service "spark" do
  start_command <<-BASH
    sudo -u '#{spark_user}' -- sh -c 'cd #{spark_path} && ./sbin/start-all.sh'
  BASH
  stop_command <<-BASH
    sudo -u '#{spark_user}' -- sh -c 'cd #{spark_path} && ./sbin/stop-all.sh'
  BASH
  action :start
end
