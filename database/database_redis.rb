require 'yaml'
require 'redis'

class DatabaseRedis
  def self.get_redis(env)
    @envHash = Hash.new
    #get the database config from ../../data/database.yml by $env
    db_config = YAML.load(File.open("#{File.dirname(__FILE__)}/database.yml"))
    @envHash[:host]=db_config[env]['redis']['host']
    @envHash[:port]=db_config[env]['redis']['port']
    @redis = Redis.new(@envHash)
  end
end
# redis = DatabaseRedis.get_redis("QA")
# redis.set:"str1","1234567890"
# p redis.get:"str1"
