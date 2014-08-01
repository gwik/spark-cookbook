
include_recipe "spark::default"

secret = Chef::EncryptedDataBagItem.load_secret(node["chef"]["data_bag_secret_path"])
key = Chef::EncryptedDataBagItem.load("spark", "ssh_key", secret)
spark_path = node['spark']['install_dir']
spark_user = node["spark"]["user"]

file "#{spark_path}/.ssh/authorized_keys" do
  mode "0400"
  owner spark_user
  content key['public_key']
end
