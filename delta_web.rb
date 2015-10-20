#
require 'sinatra/base'
require 'sinatra/reloader'

require './delta'

class DeltaWeb < Sinatra::Base
  set :bind, '0.0.0.0'

  get '/' do
    erb :index, locals: {out:{}, now:'', cmd:''}
  end

  post '/' do
    cmd = params[:cmd]
    out = Delta.delta(cmd)
    now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    erb :index, locals: {out: out, now: now, cmd: cmd}
  end

  run! if app_file == $0
end