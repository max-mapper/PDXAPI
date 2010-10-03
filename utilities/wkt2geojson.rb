# NOTICE: this isn't in use, but is included here for reference
#
# this demonstrates how to convert lots of well known text based objects into geojson
# it operates on a bunch of yaml files that each contains an array of geo-object hashes. 
# any geo-objects with the key 'geometry' and the value == a string of wkt will be converted into geojson
#
# note: this will create invalid polygons
#
# an example: 
# geometry: POINT(-122.663408 45.719247)
# would be converted to:
# "geometry":"{\"type\":\"Point\",\"coordinates\":[-122.663408, 45.719247]}
#

WKT_DIR="" # set this to the folder containing your wkt yamls!
OUTPUT_DIR="json"

require 'yaml'
require 'pow'
require 'geo_ruby'
require 'json'

module Jsonifier
  module JsonEncoding
    def to_json(options = {})
      hashifier = JsonHashifier.new(self, options)
      hashifier.to_hash.merge(options[:additional] || {}).to_json
    end
  end
end

module GeoRuby
  module SimpleFeatures
    class Polygon
      def to_json(options = nil)
        coords = self.first.points.collect {|point| [point.x, point.y] }
        {:type => "Polygon", 
          :coordinates => coords}.to_json
      end
    end
    class Point
      def to_json(options = nil)
        {:type => "Point", 
          :coordinates => [self.x, self.y]}.to_json
      end
    end  
    class LineString
      def to_json(options = nil)
        coords = self.points.collect {|point| [point.x, point.y] }
        {:type => "LineString", 
          :coordinates => coords}.to_json
      end
    end 
    class GeometryCollection
      def to_json(options = nil)
        {:type => "GeometryCollection", 
          :geometries => self.geometries}.to_json        
      end
    end 
  end
end

Pow(WKT_DIR).files.each do |file|
  next if file =~ /.DS_Store/
  dataset = YAML.load_file(file)
  dataset.each do |datapoint|
    if datapoint["geometry"]
      datapoint["geometry"] = GeoRuby::SimpleFeatures::Geometry.from_ewkt(datapoint["geometry"]).to_json
    end
  end
  filename = "#{WKT_DIR}/#{OUTPUT_DIR}/#{file.name.split('.')[0]}.json"
  File.open(filename, "w") {|newfile| newfile.puts(dataset.to_json) } unless File.exist? filename
  puts "wrote #{filename}"
end