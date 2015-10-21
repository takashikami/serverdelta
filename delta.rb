#
require 'yaml'
require 'net/ssh'

class Delta
  def self.delta(cmd)
    hosts = YAML.load_file('./conf/hosts.yaml')
    auths = YAML.load_file('./conf/auths.yaml')
    res = []
    hosts.each do |host|
      hostname = host['ipaddr']
      username = host['user']
      auth = auths[host['auth']].inject({}){|r,i|r[i[0].to_sym]=i[1];r}
      p [hostname, username, auth]
      res << {
          :cmd => cmd,
          :hostname => hostname,
          :out => Net::SSH.start(hostname,username,auth){|ssh|ssh.exec!(cmd)}
      }
    end
    res
  end
end

Delta.delta(ARGV.join ' ').each do |re|
  puts "======== [#{re[:hostname]}] #{re[:cmd]} ========\n#{re[:out]}\n"
end if File.basename(__FILE__) == File.basename($0)
