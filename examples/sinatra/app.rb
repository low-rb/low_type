require 'sinatra/base'
require 'low_type'

class App < Sinatra::Application
  include LowType

  get '/' do
    'Hello!'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
