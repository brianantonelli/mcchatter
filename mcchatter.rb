require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

class MCLogReader < EventMachine::FileTail
  @@mcwrapper = '/path/to/mcwrapper'
  
  def initialize(path, startpos=-1)
    super(path, startpos)
    @buffer = BufferedTokenizer.new
  end

  def receive_data(data)
    @buffer.extract(data).each do |line|
      line_down = line.downcase

      if line_down.include? 'cmd_backup' then
        puts 'Performing Backup'
        self.execute_mcwrapper 'backup'
        self.send_mc_message 'Received request for backup..'
      elsif line_down.include? 'cmd_restore' then
        file = line.split('cmd_restore ')[1].split(' ')[0]
        # FIXME: validate backup exists

        puts "Performing Restore of #{file}"
        self.execute_mcwrapper "restore ~/Dropbox/minecraft_backups/#{file}"
        self.send_mc_message "Restoring #{file}"
      end
    end
  end

  def execute_mcwrapper(command)
    system "#{@@mcwrapper} #{command}"
  end

  def send_mc_message(msg)
    self.execute_mcwrapper("cmd say #{msg}")
  end
end

EventMachine.run do
		EventMachine::file_tail(File.join(File.dirname(__FILE__), 'test.txt'), MCLogReader)
end