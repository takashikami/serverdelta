#
require 'sinatra/base'
require 'sinatra/reloader'
require 'net/ssh'
require 'yaml'
require 'benchmark'

class Delta < Sinatra::Base
  set :bind, '0.0.0.0'

  get '/' do
    erb :index, locals: {out:{}, now:'', bench:0.0}
  end

  post '/' do
    out = {}
    bench = {}
    hosts = YAML.load_file('./conf/hosts.yaml')
    auths = YAML.load_file('./conf/auths.yaml')
    hosts.each do |host|
      hostname = host['ipaddr']
      username = host['user']
      auth=auths[host['auth']].inject({}){|r,i|r[i[0].to_sym]=i[1];r}
      p [hostname, username, auth]
      bench[hostname] = Benchmark.realtime do
        out[hostname] = Net::SSH.start(hostname,username, auth){|ssh|ssh.exec!(params[:cmd])}
      end
    end
    now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    erb :index, locals: {out: out, now: now, bench: bench}
  end

  run! if app_file == $0
end