#!/usr/bin/env ruby

begin
  require 'thor'
  require 'mysql2'
  require 'dotenv'
  require 'json'
rescue LoadError => e
  gem = e.message.scan(/.*-- (\w+).*/).first.first
  puts "ERROR: Missing dependency #{gem} -- Install with 'gem install #{gem}'"
  exit 1
end

class Stackback < Thor
  include Thor::Actions

  package_name "stackback"

  Dotenv.load

  class_option :cs_db_host,
    default: ENV['CS_DB_HOST'],
    aliases: '-h',
    desc: 'CloudStack database host'

  class_option :cs_db_user,
    default: ENV['CS_DB_USER'],
    aliases: '-u',
    desc: 'CloudStack database user'

  class_option :cs_db_password,
    default: ENV['CS_DB_PASSWORD'],
    aliases: '-p',
    desc: 'CloudStack database password'

  class_option :cs_db_name,
    default: ENV['CS_DB_NAME'] || 'cloud',
    aliases: '-n',
    desc: 'CloudStack database name'

  # catch control-c and exit
  trap("SIGINT") do
    puts
    puts "exiting.."
    exit!
  end

  # exit with return code 1 in case of a error
  def self.exit_on_failure?
    true
  end

  desc "accounts", "Generate JSON data from accounts"
  def accounts
    accounts = client.query("SELECT id, account_name, type, state, removed, domain_id FROM account;").map do |row|
      domain = client.query("SELECT path FROM domain WHERE id = #{row['domain_id']};").first['path'] rescue row['n/a']
      if row['type'] == 5 && row['removed'] == nil
        project = client.query("select distinct projects.name, projects.display_text from projects join project_account on project_account.project_id = projects.id join account on account.id = project_account.project_account_id where project_account.project_account_id = #{row['id']};").first
      end
      name = project ? project['name'] : row['account_name']
      description = project ? project['display_text'] : "-"
      {
        id: row['id'],
        name: name,
        description: description,
        state: row['state'],
        type: row['type'],
        domain: domain,
        removed: row['removed']
      }
    end
    puts JSON.pretty_generate(accounts)
  end

  desc "projects", "Generate JSON data from projects"
  def projects
    projects = client.query("SELECT id, name, display_text, created, domain_id FROM projects WHERE name IS NOT NULL;").map do |row|
      domain = client.query("SELECT path FROM domain WHERE id = #{row['domain_id']};").first['path'] rescue row['n/a']
      {
        id: row['id'],
        name: row['name'],
        domain: domain,
        description: row['display_text'],
        created: row['created']

      }
    end
    puts JSON.pretty_generate(projects)
  end

  no_commands do
    def client
      @@client ||= client = Mysql2::Client.new(
        host: options[:cs_db_host],
        username: options[:cs_db_user],
        password: options[:cs_db_password],
        database: options[:cs_db_name]
      )
    end
  end
end

Stackback.start
