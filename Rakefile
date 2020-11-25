require 'yaml'
require 'json'
require 'tempfile'

task :default => :check

desc 'Run all tests'
task :check do
  Rake::Task['validate'].invoke
  Rake::Task['vendor'].invoke
  Rake::Task['inspec_check'].invoke
end

desc 'Validate files'
task :validate do
  puts "\nValidating YAML files"
  Dir.glob('**/*.{yaml,yml}', File::FNM_DOTMATCH).sort.each do |yaml_file|
    if not yaml_file =~ /^profiles\/.*\/vendor\//
      puts "  #{yaml_file}"
      YAML.load_file(yaml_file)
    end
  end

  puts "\nValidating ruby (*.rb) files"
  Dir['**/*.rb'].each do |rb_file|
    sh "ruby -c #{rb_file}" unless rb_file =~ /^profiles\/.*\/vendor\//
  end
end

desc 'Setup inspec vendoring of profiles'
task :vendor do
  Dir['profiles/*'].each do |profile|
    sh "inspec vendor --chef-license=accept-silent --overwrite #{profile}"
    puts "\n"
  end
end

desc 'Run inspec check on profiles'
task :inspec_check do
  Dir['profiles/*'].each do |profile|
    sh "inspec check --chef-license=accept-silent #{profile}"
    puts "\n"
  end
end

def validate(profile, config, inputs)
  if ! File.exist?(config)
    puts "Config #{config} does not exist."
    exit
  end
  cfg = YAML.load_file(config)
  p = cfg[profile]
  if p.nil?
    puts "Profile #{profile} not defined in config"
  end
end

namespace :test do
  desc 'inspec testing'
  task :single, [:profile,:config,:inputs] do |t, args|
    validate(args[:profile], args[:config], args[:inputs])
    cfg = YAML.load_file(args[:config])
    profile = cfg[args[:profile]]
    cmd = ['inspec', 'exec']
    profile['profiles'].each do |p|
      cmd << "profiles/#{p}"
    end
    # Avoid writing lock file inside container that would be owned by root outside container
    cmd << '--no-create-lockfile'
    cmd << '--chef-license=accept-silent'
    cmd << '--sudo'
    if ENV['INSPEC_PASSWORD'].nil? && profile['sshkey'].nil?
      puts "Missing environment variable INSPEC_PASSWORD must be specified if profile lacks sshkey."
      exit 1
    end
    cmd << "-i #{profile['sshkey']}" if profile['sshkey']
    profile['targets'].each do |target|
      if profile['username']
        username = profile['username']
      else
        username = ENV['USER']
      end
      cmd << "-t ssh://#{username}@#{target} --password=$INSPEC_PASSWORD"
      puts "check == #{args[:config]}_inputs.yaml"
      if args[:inputs]
        cmd << "--input-file #{args[:inputs]}"
      end

      puts "===== START TEST: profile=#{args[:profile]} target=#{target}"
      sh cmd.join(' ') do |ok, res|
        # Empty block to ignore failures
      end
      puts "===== END TEST: profile=#{args[:profile]} target=#{target}"
    end
  end

  desc 'run all inspec tests'
  task :all, [:config,:inputs] do |t, args|
    cfg = YAML.load_file(args[:config])
    puts cfg.keys
    cfg.keys.each do |profile|
      Rake::Task["test:single"].invoke(profile, args[:config], args[:inputs])
      Rake::Task["test:single"].reenable
    end
  end
end

desc 'run single test'
task :test, [:profile,:config,:inputs] do |t, args|
  Rake::Task["test:single"].invoke(args[:profile], args[:config], args[:inputs])
end
