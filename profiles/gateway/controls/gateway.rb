control 'gateway-1.0' do
  title 'Sensu Backend Gateway'
  desc 'Test system configured as a Sensu Gateway'

  if input('federation')
    describe command('sensuctl dump federation/v1.cluster') do
      its('stdout') { should match /type: Cluster/ }
    end
  end
end

include_controls 'backend' do
  skip_control 'postgres-1.0'
end
