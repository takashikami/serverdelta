#
require 'yaml'
require 'net/ssh'

class Delta
  def self.delta(cmd)
    hosts = YAML.load_file('./conf/hosts.yaml')
    auths = YAML.load_file('./conf/auths.yaml')
    out = {}
    hosts.each do |host|
      hostname = host['ipaddr']
      username = host['user']
      auth = auths[host['auth']].inject({}){|r,i|r[i[0].to_sym]=i[1];r}
      p [hostname, username, auth]
      out[hostname] = Net::SSH.start(hostname,username,auth){|ssh|ssh.exec!(cmd)}
    end
    out
  end
end

Delta.delta(ARGV.join ' ').each_pair do |k,v|
  puts "======== #{k} ========\n#{v}\n"
end if File.basename(__FILE__) == File.basename($0)
