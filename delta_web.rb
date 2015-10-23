#
require 'sinatra/base'
require 'sinatra/reloader'

require './delta'

class DeltaWeb < Sinatra::Base
  set :bind, '0.0.0.0'

  get '/' do
    now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    erb :index, locals: {res:[], cmd:'', now:now}
  end

  post '/' do
    cmd = params[:cmd]
    res = Delta.delta(cmd)
    now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    erb :index, locals: {res: res, now: now, cmd: cmd}
  end

  get '/multi' do
    now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    erb :multi, locals: {ress:nil, cmds:nil , now: now}
  end

  post '/multi' do
    cmds = params[:cmds].split("\n")
    ress = cmds.map{|cmd|Delta.delta(cmd)}
    now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    erb :multi, locals: {ress: ress, cmds: cmds, now: now}
  end

  run! if app_file == $0
end