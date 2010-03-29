#!/usr/bin/env ruby

# this assumes you have the shp2text and cs2cs binaries installed and in your path
# you also will have to customize the coordinate_transform function to match your shapefile .prj settings
# also, this is definitely hacky and isn't very maintainable

require 'rubygems'
require 'commander/import'
require 'redis'
require 'yaml'
require 'pow'
require 'lightcsv'

program :name, 'Point feature shapefile => YAML converter'
program :version, '1'
program :description, 'Takes a point feature shapefile directory and returns a YAML dump of the points'
default_command :convert

def create_csv(args, options)
  directory = args.first
  shpfile = Pow(directory).files.select {|file| file.path if file.extension =~ /shp/i}.first
  csv = `shp2text --spreadsheet #{shpfile}`.gsub("\"", '').gsub(',', '').gsub('	', ',').gsub(/\t/, ',')
  csv = LightCsv.parse(csv)
end

def transform_coordinates(coordinates)
  # cs2cs accepts a file containing coordinates. format: space delimited, one pair per line. example: "x y\nx y\nx y"
  File.open("coordinates", 'w') {|f| f.write(coordinates)}
  transformed_coordinates = `cs2cs -f %.16f +proj=lcc +lat_1=46 +lat_2=44.33333333333334 +lat_0=43.66666666666666 +lon_0=-120.5 +x_0=2500000.0001424 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs +proj=latlon coordinates`.gsub("0.0000000000000000", "").split(" \n").map {|coords| coords.split("\t").reverse}
  File.delete("coordinates")
  transformed_coordinates
end

command :list do |c|
  c.syntax = 'shp2yaml list directory'
  c.description = 'Lists the available data attributes in the shapefile'
  c.action do |args, options|
    puts create_csv(args, options).first
  end
end

command :convert do |c|
  c.syntax = 'shp2yaml convert directory column-ids'
  c.description = 'Extracts column-ids from shapefile in given directory into a YAML dump'
  c.action do |args, options|
    filtered_data = []
    csv = create_csv(args, options)
    xcoord, ycoord = args[1].to_i, args[2].to_i
    other_attrs = args[3..-1]
    cs2cs_formatted_coords = csv[1..-1].map {|line| "#{line[xcoord]} #{line[ycoord]}"}.join("\n")
    latlons = transform_coordinates(cs2cs_formatted_coords)
    csv[1..-1].each_with_index do |line, row|
      filtered_line = {}
      filtered_line.merge!({"latitude" => latlons[row][0], "longitude" => latlons[row][1]})
      other_attrs.each do |columnid|
        columnid = columnid.to_i
        filtered_line.merge!({csv.first[columnid].downcase => line[columnid]})
      end
      filtered_data << filtered_line
    end
    filename = args[0].gsub('/', '').downcase
    File.open("#{filename}.yml", 'w') {|f| f.write(filtered_data.to_yaml)}
    puts "Saved data in #{filename}.yml"
  end
end