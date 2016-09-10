require_relative 'model'
require_relative "logger"

ActiveRecord::Base.logger = Testplus::Log.new("#{File.dirname(__FILE__)}/../log/testplus-slave.log")
logger = Testplus::Log.new("#{File.dirname(__FILE__)}/../log/testplus-slave.log")

$testplus_config = YAML::load(File.open("#{File.dirname(__FILE__)}/config.yml"))



