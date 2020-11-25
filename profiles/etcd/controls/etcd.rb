control 'etcd-1.0' do
  title 'etcd'
  desc 'Test a system configured to run etcd for a Sensu backend'

  # etcd should be v3
  describe command('etcd --version') do
    its('stdout') { should match(/ersion:\s+3/) }
    its('exit_status') { should eq 0 }
  end

  describe command('etcdctl --version') do
    its('stdout') { should match(/ersion:\s+3/) }
    its('exit_status') { should eq 0 }
  end

  describe command("netstat -tulpen | grep etcd | grep #{input('etcd_client_port')}") do
    its('exit_status') { should eq 0 }
  end

  describe command("netstat -tulpen | grep etcd | grep #{input('etcd_peer_port')}") do
    its('exit_status') { should eq 0 }
  end

  describe file('/etc/etcd.yaml') do
    it { should exist }
  end

  describe yaml('/etc/etcd.yaml') do
    its('auto-compaction-mode') { should eq 'revision' }
    its('auto-compaction-retention') { should eq '2' }
  end

  describe json({command: "ETCDCTL_API=3 ETCDCTL_ENDPOINTS=https://#{sys_info.fqdn}:#{input('etcd_client_port')} ETCDCTL_CACERT=/etc/etcd/ca.crt ETCDCTL_KEY=/etc/etcd/key.pem ETCDCTL_CERT=/etc/etcd/cert.pem etcdctl get /sensu.io/.initialized -w json" }) do
    its(['count']) { should eq 1 }
    its(['kvs']) { should_not cmp nil }
  end

  describe command("ETCDCTL_API=3 ETCDCTL_ENDPOINTS=https://#{sys_info.fqdn}:#{input('etcd_client_port')} ETCDCTL_CACERT=/etc/etcd/ca.crt ETCDCTL_KEY=/etc/etcd/key.pem ETCDCTL_CERT=/etc/etcd/cert.pem etcdctl alarm list") do
    its('stdout') { should match(/^$/) } # be silent
    its('exit_status') { should eq 0 }
  end

  describe command("ETCDCTL_API=3 ETCDCTL_ENDPOINTS=https://#{sys_info.fqdn}:#{input('etcd_client_port')} ETCDCTL_CACERT=/etc/etcd/ca.crt ETCDCTL_KEY=/etc/etcd/key.pem ETCDCTL_CERT=/etc/etcd/cert.pem etcdctl endpoint health --cluster=true -w json") do
    its('stdout') { should_not match(/false/) }
    its('exit_status') { should eq 0 }
  end
end
