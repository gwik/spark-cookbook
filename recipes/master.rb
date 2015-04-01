
include_recipe "spark::default"

spark_path = node['spark']['install_dir']
spark_user = node["spark"]['user']

file "#{spark_path}/conf/slaves" do
  mode "0755"
  owner spark_user
  content(node['spark']['workers'].join("\n") + "\n")
end

service "spark" do
  start_command <<-BASH
    sudo -u '#{spark_user}' -- sh -c '#{spark_path}/sbin/start-master.sh'
  BASH
  stop_command <<-BASH
    sudo -u '#{spark_user}' -- sh -c '${#{spark_path}/sbin/stop-master.sh'
  BASH
  action :start
end

consul_service_def 'spark-master' do
  port 8080
  tags ['http']
  check(
    interval: '1s',
    script: 'curl http://localhost:8080/ping'
  )
  notifies :reload, 'service[consul]'
end
