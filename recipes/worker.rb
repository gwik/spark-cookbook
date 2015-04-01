
include_recipe "spark::default"

spark_path = node['spark']['install_dir']
spark_user = node["spark"]["user"]

service "spark" do
  start_command <<-BASH
    sudo -u '#{spark_user}' -- sh -c '#{spark_path}/sbin/start-slave.sh'
  BASH
  stop_command <<-BASH
    sudo -u '#{spark_user}' -- sh -c '${#{spark_path}/sbin/stop-slave.sh'
  BASH
  action :start
end


consul_service_def 'spark-worker' do
  port 8080
  tags ['http']
  check(
    interval: '1s',
    script: 'curl http://localhost:8080/ping'
  )
  notifies :reload, 'service[consul]'
end
