control 'backend-1.0' do
  title 'Sensu Backend'
  desc 'Test a system configured as a Sensu backend'

  describe package('sensu-go-backend') do
    its('version') { should cmp > input('backend_version') }
  end

  describe command("sudo netstat -tulpen | grep sensu-backend | grep #{input('backend_webui_port')}") do
    its('exit_status') { should eq 0 }
  end

  describe command("sudo netstat -tulpen | grep sensu-backend | grep #{input('backend_api_port')}") do
    its('exit_status') { should eq 0 }
  end

  describe command("sudo netstat -tulpen | grep sensu-backend | grep #{input('backend_agent_api_port')}") do
    its('exit_status') { should eq 0 }
  end

  describe file('/etc/sensu/backend.yml') do
    it { should exist }
  end

  describe yaml('/etc/sensu/backend.yml') do
    its('no-embed-etcd') { should cmp input('no-embed-etcd') }
  end

  describe command("curl -i https://#{sys_info.fqdn}:#{input('backend_api_port')}/health") do
    its('stdout') { should match(/200 OK/) }
  end
end

control 'postgres-1.0' do
  title 'Sensu Backend PostgreSQL'
  desc 'Sensu backend is configured to use postgres'

  describe yaml({command: 'sensuctl dump store/v1.PostgresConfig --format yaml' }) do
    its(['spec', 'dsn']) { should_not be nil }
  end

  describe json({command: "curl https://#{sys_info.fqdn}:#{input('backend_api_port')}/health"}) do
    its(['PostgresHealth', 0, 'Active']) { should cmp 'true' }
    its(['PostgresHealth', 0, 'Healthy']) { should cmp 'true' }
  end
end
