require 'yaml'
require 'thread'

Dir[File.dirname(__FILE__) + '/**/*.rb'].each {|file| require file if file!="./"<<__FILE__}
#Dir[File.dirname(__FILE__) + '/library/*/**/*.rb'].each {|file| require file if file!="./"<<__FILE__}
$logger = Testplus::Log.new("#{File.dirname(__FILE__)}/log/testplus-slave-#{Time.now.strftime("%Y-%m-%d")}.log")
$queue = Queue.new
$global_status = true

def get_push_queue
  $global_status = false
  #params[:salve_name],params[:platforms],params[:project_names],params[:threads_number].to_i,params[:operation_system]
  data = {:salve_name=>$testplus_config['slave_name'],
    :platforms=>$testplus_config['platforms'],
    :project_names=>$testplus_config['project_names'],
    :threads_number=>$testplus_config['threads_number'],
    :operation_system=>$testplus_config['operation_system']}
  url = "#{$testplus_config['web_server']}/get_schedule_scripts"
  hash_results = JSON.parse(RestClient.post(url,data))
  $logger.info hash_results
  (hash_results||[]).each do |hash_result|
    temp_schedule_script = TempScheduleScript.new(hash_result)
    script_task = ScriptTask.new(temp_schedule_script)
    $queue.push(script_task)
  end
  $global_status = true
end

#threads
threads = []
mutex=Mutex.new
$testplus_config['threads_number'].to_i.times.each do |i|
  threads<<Thread.new do
    loop do
      $logger.info "######Thread#{i}"
      if $queue.empty?
        # single
        # ActiveRecord::Base.connection.close rescue false
        # $database_util.close rescue false
        # break
        mutex.synchronize do
          if $global_status
            get_push_queue
          end
          # loop server
          if $queue.empty?
            sleep(30)
            $global_status = true
          end
        end
        next
      else
        script_task = $queue.pop
        exec_cmd = start_cmd = nil
        local_path = File.join($testplus_config['root_path'],script_task.schedule_script.exec_path)
        testing_path = local_path.split('testing')[0]
        remote_path = JSON.parse(script_task.schedule_script.source_path)[0]["remote"]
        case "#{script_task.schedule_script.exec_cmd}".downcase
        when "rspec"
          exec_cmd = "ruby"
          start_cmd = "#{exec_cmd} #{File.join(testing_path,'testing','run.rb')} -e #{script_task.env} -p #{script_task.browser} -s #{File.join(local_path,script_task.script_name)} -r #{script_task.round_id} -o #{script_task.file_name} -j '#{script_task.to_hash.to_json}'"
        when "ruby"
          exec_cmd = "ruby"
          start_cmd = "#{exec_cmd} #{File.join(testing_path,'testing','run.rb')} -e #{script_task.env} -p #{script_task.browser} -s #{File.join(local_path,script_task.script_name)} -r #{script_task.round_id} -o #{script_task.file_name} -j '#{script_task.to_hash.to_json}'"
        when "python"
          exec_cmd = "python"
          start_cmd = "#{exec_cmd} #{File.join(testing_path,'testmain.py')} -e #{script_task.env} -p #{script_task.browser} -s #{File.join(local_path,script_task.script_name)} -r #{script_task.round_id} -o #{script_task.file_name} -j '#{script_task.to_hash.to_json}'"
        when "pyunit"
          exec_cmd = "python"
          start_cmd = "#{exec_cmd} #{File.join(testing_path,'testmain.py')} -e #{script_task.env} -p #{script_task.browser} -s #{File.join(local_path,script_task.script_name)} -r #{script_task.round_id} -o #{script_task.file_name} -j '#{script_task.to_hash.to_json}'"
        when "maven"||"mvn"
          exec_cmd = "mvn"
          start_cmd = "cd #{testing_path}&&mvn test"
        when "ant"
          exec_cmd = "ant"
          start_cmd = "cd #{testing_path}&&ant"
        when "java"
          exec_cmd = "java"
          start_cmd = ""
        else
        next
        end
        
        case script_task.schedule_script.source_cmd.downcase
        when 'git'
          unless File.exist?(local_path)
            $logger.info `mkdir -p #{testing_path};git clone #{remote_path} #{testing_path};cd #{testing_path}&&bundle install`
          else
            `cd #{local_path};git reset HEAD --hard;git pull&&bundle update`
          end
        when 'svn'
          unless File.exist?(local_path)
            $logger.info `mkdir -p #{local_path};svn checkout #{remote_path} #{testing_path};cd #{testing_path}&&bundle install`
          else
            `cd #{local_path};svn revert;svn update&&bundle update`
          end
        end
        $logger.info "######Thread#{i}\n#{start_cmd}"
        $logger.info `#{start_cmd}`
      end
    end
  end
end

loop do
  threads.each{|t| t.join}
end
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