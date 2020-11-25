control 'postgres-1.0' do
  title 'Postgres'
  desc 'Test database system managed by Patroni for use with Sensu backend'

  describe package('postgresql96-server') do
    its('version') { should cmp > '9.6' }
  end

  describe command("netstat -tulpen | grep postgres | grep #{input('postgres_port')}") do
    its('exit_status') { should eq 0 }
  end

  #patroni
  describe command("netstat -tulpen | grep python | grep #{input('patroni_port')}") do
    its('exit_status') { should eq 0 }
  end

  describe file('/opt/app/patroni/etc/postgresql.yml') do
    it { should exist }
  end

  curl = [
    'curl',
    '--cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem',
    '--cert /var/lib/pgsql/cert.pem',
    '--key /var/lib/pgsql/key.pem',
    "https://#{sys_info.fqdn}:#{input('patroni_port')}/cluster | jq .[][].state | grep running | wc -l",
  ]

  describe command(curl.join(' ')) do
    its('stdout') { should cmp input('number_patroni_nodes') }
    its('exit_status') { should eq 0 }
  end

  describe command("PAGER= PGPASSWORD='#{ENV['PGPASSWORD']}' psql -U sensu -h localhost sensu_events -c 'select * from events order by id desc LIMIT 1;'", redact_regex: /PGPASSWORD='.*'\s+/) do
    its('stdout') { should match /sensu_entity/ }
    its('exit_status') { should eq 0 }
  end
end
