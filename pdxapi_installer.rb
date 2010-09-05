# this will populate a geocouch server with a database for each of the shapefiles in datasets.yml
# you will have to have a working geocouch server. see http://maxogden.com for instructions
#
# requires binaries: curl, unzip, ogr2ogr (via gdal_bin package usually)
#
# requires rubygem: shp2geocouch (gem install shp2geocouch)

require 'yaml'
datasets = YAML.load_file(Dir.pwd + "/datasets.yml")

%x!mkdir -p civicapps_zips!

datasets.each do |dataset, attributes|
  dataset_url = attributes["uri"]
  `curl #{dataset_url} -o civicapps_zips`
end

Dir[File.join(Dir.pwd, "**/*.zip")].each do |zip|
  puts "Creating GeoCouch database for #{zip}..."
  %x!shp2geocouch #{zip}!
end