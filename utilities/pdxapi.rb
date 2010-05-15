# this is a simple sinatra server that serves jsonp data from the proximity.rb file.
# this isn't in use anymore and has been replaced by geocouch

require 'sinatra'
require 'json'
require 'haml'
require 'sass/plugin/rack'
require File.join(File.dirname(__FILE__), 'proximity')

use Sass::Plugin::Rack
Sass::Plugin.options[:css_location] = "./public"
Sass::Plugin.options[:template_location] = "./public"

run Sinatra::Application

get '/' do
  File.read(File.join('public', 'index.html'))
end

get "/:resource" do
  content_type :json
  count = (params[:count].to_i > 0) ? params[:count].to_i : 1
  "#{params[:callback]}(#{Proximity.new(params[:lat], params[:lon]).nearest(params[:resource], count).to_json})"
end