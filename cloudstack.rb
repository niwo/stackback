#!/usr/bin/env ruby

begin
  require 'highline/import'
  require 'mysql2'
  require 'dotenv/load'
  require 'optparse'
  require 'json'
rescue LoadError => e
  gem = e.message.scan(/.*-- (\S+)/).first.last
  puts "ERROR: Missing dependency #{gem} -- Install with 'gem install #{gem}'"
  exit 1
end

# trap ctrl-c
trap "SIGINT" do
  puts " Exiting..."
  exit 130
end

# default options
options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: cloudstack.rb [options]"

  options[:cs_db_host] = ENV['CS_DB_HOST']
  opts.on( '-h', '--db-host HOST', 'CloudStack database host' ) do |h|
    options[:cs_db_host] = h
  end

  options[:cs_db_user] = ENV['CS_DB_USER']
  opts.on( '-u', '--db-user USER', 'CloudStack database user' ) do |u|
    options[:cs_db_user] = u
  end

  options[:cs_db_password] = ENV['CS_DB_PASSWORD']
  opts.on( '-p', '--db-password password PASSWORD', 'CloudStack database password' ) do |p|
    options[:cs_db_password] = p
  end

  options[:cs_db_name] = ENV['CS_DB_NAME'] || "cloud"
  opts.on( '-n', '--db-name db_name NAME', 'CloudStack database name' ) do |n|
    options[:cs_db_name] = n
  end

  options[:destination] = "../data"
  opts.on( '-d', '--destination DEST', 'Destination of file output' ) do |d|
    options[:destination] = d
  end

  opts.on_tail('--help', 'Show this screen') do
    puts opts
    exit
  end
end

optparse.parse!

client = Mysql2::Client.new(
  host: options[:cs_db_host],
  username: options[:cs_db_user],
  password: options[:cs_db_password],
  database: options[:cs_db_name]
)

accounts = client.query("SELECT id, account_name, state, removed, domain_id FROM account ORDER BY state, account_name;").map do |row|
  domain = client.query("SELECT id, name, path FROM domain WHERE id = #{row['domain_id']};").first['name'] rescue row['n/a']
  {
    id: row['id'],
    name: row['account_name'],
    state: row['state'],
    domain: domain,
    removed: row['removed']
  }
end
puts accounts.to_json
