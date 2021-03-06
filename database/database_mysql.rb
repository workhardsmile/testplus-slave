require 'yaml'
require 'mysql2'

class DatabaseMysql
  attr_accessor :free
  def initialize(env)
    @envHash = Hash.new
    #get the database config from ../../data/database.yml by $env
    db_config = YAML.load(File.open("#{File.dirname(__FILE__)}/database.yml"))
    @envHash[:timeout]=5000
    @envHash[:username]=db_config[env]['mysql']['username']
    @envHash[:password]=db_config[env]['mysql']['password']
    @envHash[:database]=db_config[env]['mysql']['database']
    @envHash[:encoding]= db_config[env]['mysql']['encoding']
    @envHash[:host]=db_config[env]['mysql']['host']
    @client = Mysql2::Client.new(@envHash)
    @free = true
  end

  def query(sql,is_escaped = false)    
    puts sql
    result = []
    begin
      sql = @client.escape(sql) if is_escaped
      result = @client.query(sql).to_a      
    rescue => e
      puts "error in execute_query -- #{sql} \n #{e.message}"
    end
    return result
  end

  def close
    @client.close if @client
  end
end

#puts DatabaseMysql.new("QA").query("SELECT VERSION()")
