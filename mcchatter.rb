require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

class MCLogReader < EventMachine::FileTail
  @@mcdir = '/Users/monkemojo/minecraft_server/'
  @@backupdir = '/Users/monkemojo/Dropbox/minecraft-storage/'
  @@mcwrapper = '/usr/bin/mcwrapper'
  
  def initialize(path, startpos=-1)
    super(path, startpos)
    @buffer = BufferedTokenizer.new
  end

  def receive_data(data)
    @buffer.extract(data).each do |line|
      line_down = line.downcase
      if line_down.include? 'cmd_ping' then
        puts 'Got pinged'
        self.send_mc_message 'Ill see your ping and raise you a pong.'
      elsif line_down.include? 'cmd_backup' then
        puts 'Performing Backup'
        self.send_mc_message 'Received request for backup..'
        self.execute_mcwrapper 'backup'
        backup = self.execute_mcwrapper 'config latestbackup'
        self.send_mc_message "Backup complete. Saved: #{backup}"
      elsif line_down.include? 'cmd_restore' then
        file = line.split('cmd_restore ')[1].split(' ')[0]
        self.perform_restore(file)
      end
    end
  end

  def perform_restore(backup)
    full_backup = "#{@@backupdir}#{backup}"
    puts full_backup
    if not File.exist? full_backup then
      self.send_mc_message "Invalid backup: #{backup}"
      return
    end
    
    self.send_mc_message 'Validated backup. Restoring. Reboot to follow.'
    tmpdir = '/Users/monkemojo/mkrestore' 
    `mkdir -p #{tmpdir}; cd #{tmpdir}; cp #{full_backup} .; tar -zxf #{backup};`
    restoredir = tmpdir + "/" + backup.chomp('.tgz')
    self.execute_mcwrapper "restore #{restoredir}"
    `rm -rf #{tmpdir}`
    self.send_mc_message "Succesfully restored #{backup}"
  end

  def execute_mcwrapper(command)
    return `cd #{@@mcdir}; #{@@mcwrapper} #{command}`
  end

  def send_mc_message(msg)
    return self.execute_mcwrapper("cmd say #{msg}")
  end
end

EventMachine.run do
		EventMachine::file_tail('/Users/monkemojo/minecraft_server/server.log', MCLogReader)
end