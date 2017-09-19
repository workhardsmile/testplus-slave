require_relative 'model'
require_relative "logger"

#ActiveRecord::Base.logger = Testplus::Log.new("#{File.dirname(__FILE__)}/../log/testplus-slave-db.log")
$testplus_config = YAML::load(File.open("#{File.dirname(__FILE__)}/config/config.yml"))
$testplus_config['root_path'] = File.absolute_path($testplus_config['root_path']).gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
