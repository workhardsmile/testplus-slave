require "optparse"
require "rest-client"
require_relative "config"

options = Hash.new
#handle options and arguments
optparse = OptionParser.new do|opts|
  #set the banner
  opts.banner = "Usage: ruby testplus-runner.rb -c <ci_name> [options]"
  
  #define script path option
  options[:ci_name] = nil
  opts.on('-c', '--ci_name <string>',
  'Name of CI name (required)', 'ex - "ci_name1", "ci_name2"') do|ci_name|
    options[:ci_name] = ci_name
  end
  
  #define environment option
  options[:environment] = 'QA'
  opts.on('-e', '--environment <string>', ["QA","REG", "PROD"],
  'Name of the test environment (optinal)','ex - "QA","REG", "PROD"','Set to QA by default') do|environment|
    options[:environment] = environment
  end
  
  #define round option
  options[:version] = '1.0.0'
  opts.on('-v', '--version <string>',
  'Version of the product (optinal)', 'ex - "1.0.0", "2.0.0", "3.0.0"',"Used by Marquee client only, set to 1.0.0 by default ") do|version|
    options[:version] = version
  end
end

optparse.parse!

unless options[:ci_name].nil?
  respose = RestClient.post("#{$testplus_config["web_server"]}/status/new_build",{"project"=>options[:ci_name],"environment"=>options[:environment],"version"=>options[:version]})
  puts respose
end