control 'sensucli-1.0' do
  title 'Sensucli'
  desc 'Sensu cli tool'

  describe package('sensu-go-cli') do
    its('version') { should cmp > input('cli_version') }
  end

  describe json({ command: 'sensuctl config view --format json' }) do
    its('api-url') { should_not eq nil }
  end
end
