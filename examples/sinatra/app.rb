require 'sinatra/base'
require 'low_type'

class App < Sinatra::Base
  include LowType

  get '/' do -> { HTML }
    '<strong>Hello!</strong>'
  end

  # Integer interpreted as HTTP status code therefore body is empty and invalid.
  get '/integer' do -> { HTML }
    123 # Responds with 500 status and "Invalid return value..." body.
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
