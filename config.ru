require 'sinatra'
require 'json'
require 'haml'
require 'sass/plugin/rack'

use Sass::Plugin::Rack
Sass::Plugin.options[:always_update] = true
Sass::Plugin.options[:css_location] = "./public"
Sass::Plugin.options[:template_location] = "./views"

require File.join(File.dirname(__FILE__), 'proximity')
require File.join(File.dirname(__FILE__), 'application')

run Sinatra::Application