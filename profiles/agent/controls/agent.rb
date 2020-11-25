control 'agent-1.0' do
  title 'Sensu Agent'
  desc 'Test the sensu agent'

  describe package('sensu-go-agent') do
    its('version') { should cmp > input('agent_version') }
  end

  describe command("sudo netstat -tulpen | grep sensu-agent | grep #{input('agent_socket_port')}") do
    its('exit_status') { should eq 0 }
  end

  describe command("sudo netstat -tulpen | grep sensu-agent | grep #{input('agent_api_port')}") do
    its('exit_status') { should eq 0 }
  end

  describe file('/etc/sensu/agent.yml') do
    it { should exist }
  end

  describe yaml('/etc/sensu/agent.yml') do
    its('password') { should_not cmp nil }
    its('backend-url') { should_not cmp nil }
  end

  describe command("curl -s http://localhost:#{input('agent_api_port')}/healthz") do
    its('stdout') { should match(/ok/) }
    its('exit_status') { should eq 0 }
  end
end
