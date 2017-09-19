#require 'active_record'
require 'rest_client'

class ScriptTask
  attr_accessor :browser, :date_time, :env, :file_name, :round_id, :script_name, :script_path, :schedule_script
  def initialize(temp_schedule_script)
    if temp_schedule_script!=nil
      time_now = Time.now
      @browser = temp_schedule_script.platform
      @date_time = time_now.strftime("%Y-%m-%d %H:%M:%S")
      @env = temp_schedule_script.env_name
      @round_id = temp_schedule_script.test_round_id
      @script_name = temp_schedule_script.script_name
      @script_path = temp_schedule_script.exec_path
      @file_name = "#{@script_name}-#{@round_id}-#{time_now.strftime("%Y%m%d%H%M%S")}.htm"
      @schedule_script = temp_schedule_script
      Dir.mkdir $testplus_config['root_path'] if not File.exist? $testplus_config['root_path']
    end
  end
  
  def to_hash
    log = { "log" => { "browser" => @browser,
      "date_time" =>  @date_time,
      "env" => @env,
      "round_id" => @round_id, 
      "script_name" => @script_name,
      "script_path" => @script_path,
      "file_name" => @file_name }, 
      "commit" => "Create Log"}
  end
end

# == Schema Information
#
# Table name: temp_schedule_scripts
#
# `id` int(11) NOT NULL AUTO_INCREMENT,
# `platform` varchar(255) DEFAULT NULL,
# `ip` varchar(255) DEFAULT NULL,
# `test_round_id` int(11) DEFAULT NULL,
# `script_result_id` int(11) DEFAULT NULL,
# `timeout_limit` int(11) DEFAULT NULL,
# `script_name` varchar(255) DEFAULT NULL,
# `project_name` varchar(255) DEFAULT NULL,
# `branch_name` varchar(255) DEFAULT NULL,
# `source_path` varchar(255) DEFAULT NULL,
# `source_cmd` varchar(255) DEFAULT NULL,
# `exec_path` varchar(255) DEFAULT NULL,
# `exec_cmd` varchar(255) DEFAULT NULL,
# `env_name` varchar(255) DEFAULT NULL,
#
class TempScheduleScript #< ActiveRecord::Base
  attr_accessor :id, :platform, :ip, :test_round_id, :script_result_id, :timeout_limit, :script_name, :project_name, :branch_name, :source_path, :source_cmd, :exec_path, :exec_cmd, :env_name, :deleted
  def initialize(_hash)
    @id = _hash['id']
    @platform = _hash['platform']
    @ip = _hash['ip']
    @test_round_id = _hash['test_round_id']
    @script_result_id = _hash['script_result_id']
    @timeout_limit = _hash['timeout_limit']
    @script_name = _hash['script_name']
    @project_name = _hash['project_name']
    @branch_name = _hash['branch_name']
    @source_path = _hash['source_path']
    @source_cmd = _hash['source_cmd']
    @exec_path = _hash['exec_path']
    @exec_cmd = _hash['exec_cmd']
    @env_name = _hash['env_name']
    @deleted = _hash['deleted']    
  end
end
