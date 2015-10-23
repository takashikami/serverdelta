#
require 'yaml'
require 'net/ssh'
require 'diff/lcs'

class Delta
  def self.delta(cmd)
    hosts = YAML.load_file('./conf/hosts.yaml')
    auths = YAML.load_file('./conf/auths.yaml')
    res = []
    hosts.each_with_index do |host, idx|
      hostname = host['ipaddr']
      username = host['user']
      auth = auths[host['auth']].inject({}){|r,i|r[i[0].to_sym]=i[1];r}
      out = Net::SSH.start(hostname,username,auth){|ssh|ssh.exec!(cmd).split("\n")}
      dsp = out
      d = nil
      if idx > 0
        dsp = []
        cnt = {'+'=>0, '-'=>0}
        d = Diff::LCS.diff(res[0][:out],out)
        d.each{|dd|dd.each{|ddd|dsp << ddd.to_a.join(' '); cnt[ddd.to_a.first]+=1}}
      end
      res << {idx:idx, d:d, cmd:cmd, hostname:hostname, out:out, dsp:dsp, cnt:cnt}
    end
    res
  end
end

Delta.delta(ARGV.join ' ').each_with_index do |re, i|
  puts ARGV.unshift(Time.now.to_s).join(' ') if i == 0
  puts "======== [#{re[:hostname]}] ========\n#{re[:dsp].join("\n")}\n"
end if File.basename(__FILE__) == File.basename($0)
