# this is the initial version of the proximity lookup database
# this isn't in use anymore and has been replaced by geocouch
# it has been included for reference, as it demonstrates how to calculate the distance between two lat/lon points on a geoid in pure ruby

module Haversine
  RAD_PER_DEG = 0.017453293
  Rmiles = 3956
  Rfeet = Rmiles * 5280

  def haversine_distance( lat1, lon1, lat2, lon2 )
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    dlon_rad = dlon * RAD_PER_DEG 
    dlat_rad = dlat * RAD_PER_DEG
    lat1_rad = lat1 * RAD_PER_DEG
    lon1_rad = lon1 * RAD_PER_DEG
    lat2_rad = lat2 * RAD_PER_DEG
    lon2_rad = lon2 * RAD_PER_DEG
    a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
    dFeet = Rfeet * c
  end
end

class Proximity
  include Haversine
  include Enumerable
  require 'redis'
  attr_accessor :lat, :lon
  
  def initialize(lat, lon)
    @lat, @lon = lat, lon
    @redis = Redis.new
    @proximity = 2000
    @data = []
  end   
  
  def <<(element)
    @data = (@data << element)
  end
  
  def other_attrs_for(resource, latlon)
    @redis
  end
  
  def nearest(resource, num=1)
    @redis.list_range("pdxapi:#{resource}:latlons", 0, -1).each do |latlon|
      lat, lon = latlon.split(",")
      distance = haversine_distance( @lat.to_f, @lon.to_f, lat.to_f, lon.to_f )
      if distance < @proximity
        point_data = {}
        point_data.merge!({"latitude" => lat, "longitude" => lon, "distance" => distance})
        self << point_data
      end
    end
    sorted_data = {} 
    @data.sort_by{|a| a["distance"]}[0..num-1].map do |data|
      lat, lon = data["latitude"], data["longitude"]
      point_with_attrs = {}
      @redis.list_range("pdxapi:#{resource}:custom_attrs", 0, -1).each do |attribute|
        point_with_attrs.merge!({attribute => @redis["pdxapi:#{resource}:#{lat}:#{lon}:#{attribute}"]})
      end
      sorted_data.merge!(point_with_attrs)
    end
    sorted_data
  end
end