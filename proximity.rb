module Haversine
  RAD_PER_DEG = 0.017453293
  Rmiles = 3956
  Rfeet = Rmiles * 5282

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
    @r = Redis.new
    @proximity = 4000
    @data = []
  end   
  
  def <<(element)
    @data = (@data << element)
  end
  
  def nearest(resource, num=1)
    @r.list_range("points:#{resource}", 0, -1).each do |latlon|
      lat, lon = latlon.split(", ")
      distance = haversine_distance( @lat.to_f, @lon.to_f, lat.to_f, lon.to_f )
      if distance < @proximity
        self << {:lat => lat, :lon => lon, :distance => distance}
      end
    end
    @data.sort_by{|a| a[:distance]}[0..num-1]
  end
end