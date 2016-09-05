require_relative 'model'
ActiveRecord::Base.logger = Testplus::Log.new("#{File.dirname(__FILE__)}/../log/testplus-slave.log")
logger = Testplus::Log.new("#{File.dirname(__FILE__)}/../log/testplus-slave.log")

$testplus_config = YAML::load(File.open("#{File.dirname(__FILE__)}/config.yml"))
env_name = 'test_db' #ENV['RAILS_ENV']
if (env_name && $testplus_config.has_key?(env_name))
  db_config = $testplus_config.fetch(env_name)
  logger.info "Connecting to #{env_name}."
else
  db_config = $testplus_config.fetch("development")
  error_msg = "Can't find environment definition for #{env_name.nil? ? "nil" : env_name}. Using development as default."
  puts error_msg
  logger.error error_msg
end

ActiveRecord::Base.establish_connection db_config
ActiveRecord::Base.default_timezone = :utc


