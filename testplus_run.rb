require 'yaml'
require 'thread'
 
Dir[File.dirname(__FILE__) + '/**/*.rb'].each {|file| require file if file!="./"<<__FILE__}
#Dir[File.dirname(__FILE__) + '/library/*/**/*.rb'].each {|file| require file if file!="./"<<__FILE__}
$queue = Queue.new
mutex=Mutex.new
#threads number
threads = []
$testplus_config['threads_number'].to_i.times.each do |i|
  threads<<Thread.new do
    puts "######Thread#{i}#######"
    database_util = DatabaseMysql.new('TESTPLUS')
    #until $queue.empty?
    while(true)
      if $queue.empty?
        $testplus_config['platforms'].each do |platform|
          database_util.query("call get_schedule_scripts_by_tnumber_and_project_and_platform(#{($testplus_config['threads_number'].to_i/$testplus_config['platforms'].length).to_i+1},'#{$testplus_config['project']}','#{platform['type']}','#{platform['version']}','#{$testplus_config['operation_system']['type']}','#{$testplus_config['operation_system']['version']}','#{$testplus_config['slave_name']}','#{$testplus_config['local_ip']}')")
          mutex.lock        
            temp_schedule_scripts = TempScheduleScript.find_all_by_project_name_and_platform_and_ip_and_deleted($testplus_config['project'],platform['type'],$testplus_config['local_ip'],0)
            temp_schedule_scripts.each do |temp_schedule_script|
              script_task = ScriptTask.new(temp_schedule_script)
              $queue.push(script_task)
              database_util.query("update temp_schedule_scripts set `deleted`=1 where `id`=#{temp_schedule_script.id}")
            end
          mutex.unlock
        end        
      end
      sleep(1)
      if $queue.empty? 
        # loop server
        # sleep(60)
        # next
        # single
        ActiveRecord::Base.connection.close rescue false  
        database_util.close rescue false
        break       
      else
        script_task = $queue.pop
        exec_cmd = nil
        case "#{script_task.schedule_script.exec_cmd}".downcase
        when "rspec"||"ruby"
          exec_cmd = "ruby"
        when "maven"||"mvn"
          exec_cmd = "mvn"
        when "ant"
          exec_cmd = "ant"
        when "java"
          exec_cmd = "java"
        when "python"
          exec_cmd = "python"
        else 
          next
        end
        local_path = File.join($testplus_config['root_path'],script_task.schedule_script.exec_path)
        testing_path = local_path.split('testing')[0]
        remote_path = JSON.parse(script_task.schedule_script.source_path)[0]["remote"]
        start_cmd = "#{exec_cmd} #{File.join(testing_path,'testing','run.rb')} -e #{script_task.env} -p #{script_task.browser} -s #{File.join(local_path,script_task.script_name)} -r #{script_task.round_id} -o #{script_task.file_name} -j #{script_task.to_hash.to_json}"
        database_util.query("call update_script_result_status_by_script_result_id(#{script_task.schedule_script.script_result_id})")
        case script_task.schedule_script.source_cmd.downcase
        when 'git'
          unless File.exist?(local_path)            
            puts "mkdir -p #{testing_path};git clone #{remote_path} #{testing_path}"
          else
            puts "cd #{local_path};git reset HEAD --hard;git update"
          end
        when 'svn'
          unless File.exist?(local_path)
            puts "mkdir -p #{local_path};svn checkout #{remote_path} #{testing_path}"
          else
            puts "cd #{local_path};svn revert;svn update"
          end
        end
        puts "#{start_cmd}"
      end
    end
  end
end
threads.each{|t| t.join}
#####################################output######################################
# ruby /tmp/testplus_projects/GitLab/commerce_adminui/run.rb
# -e LV-REG 
# -p firefox 
# -s /tmp/testplus_projects/GitLab/commerce_adminui/test/commerce/regression/commerce_admin_ui_bug_tracking_t3560
# -r 48600 
# -o commerce_admin_ui_bug_tracking_t3560-48600-20160903014521.htm
# -j {"log":{"browser":"firefox","date_time":"2016-09-03 01:45:21","env":"LV-REG","round_id":48600,"script_name":"commerce_
# admin_ui_bug_tracking_t3560","script_path":"GitLab/commerce_adminui/test/commerce/regression","file_name":"commerce_admin_ui_bug_
# tracking_t3560-48600-20160903014521.htm"},"commit":"Create Log"}
#####################################output######################################