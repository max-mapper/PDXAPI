# this file assumes redis-server is running
require 'rubygems'
require 'redis'
require 'yaml'
require 'pow'

redis = Redis.new

Pow("../data").files.each do |file|
  data = YAML.load_file(file.path)
  resource = file.name(false) # false = without file extension
  data.each do |object|
    redis.push_tail("pdxapi:#{resource}:latlons", "#{object['latitude']},#{object['longitude']}")
    object.each do |attribute, value|
      value = "" if value.nil?
      redis.push_tail("pdxapi:#{resource}:custom_attrs", attribute)
      redis["pdxapi:#{resource}:#{object['latitude']}:#{object['longitude']}:#{attribute}"] = value
    end
  end
end 
