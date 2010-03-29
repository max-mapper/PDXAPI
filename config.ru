require 'sinatra'
require 'json'
require 'haml'
require 'sass/plugin/rack'

use Sass::Plugin::Rack
Sass::Plugin.options[:css_location] = "./public"
Sass::Plugin.options[:template_location] = "./public"

require File.join(File.dirname(__FILE__), 'lib', 'proximity')
require File.join(File.dirname(__FILE__), 'lib', 'pdxapi')

run Sinatra::Application