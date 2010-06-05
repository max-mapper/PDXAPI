# KNOWN BUG: SHAPEFILES CONTAINING NULL DATE VALUES WILL THROW CRAZY ERRORS. DOES ANYONE KNOW HOW TO MAKE POSTGRES MORE FAULT TOLERANT OF NULL DATE VALUES?
# ERROR DUMP:
  # ERROR:  date/time field value out of range: "0"
  # LINE 1: ...trfullnam","expr1",geometry) VALUES ('1','1',NULL,'0',NULL,'...
  #                                                              ^
  # HINT:  Perhaps you need a different "datestyle" setting.
#
# -------------------
# this will populate a postgis database called 'civicapps' with all of the shapefiles from datasets.yml
# inspired by http://iknuth.com/2010/05/bulk-loading-shapefiles-into-postgis/
#
# requires binaries: wget, unzip, ogr2ogr, shp2pgsql
#
# usage: CivicAppsShapefiles.new.install!

require 'yaml'

class CivicAppsShapefiles
  def initialize()
    @unzip_dir = Dir.pwd + "/unzipped"
    @datasets = YAML.load_file(Dir.pwd + "/datasets.yml")
  end
  
  def install!
    download
    unzip
    convert
    import
  end
  
  def name_for(shapefile)
    shapefile.split('/')[-1].split('.shp')[0].downcase
  end
  
  def download
    @datasets.each do |dataset, attributes|
      dataset_url = attributes["uri"]
      `wget #{dataset_url}`
    end
  end

  def unzip
    zips = Dir.glob("*.zip")
    zips.each do |zip|
      name = zip.split('.')[0]
      output_dir = "#{@unzip_dir}/#{name}"
      puts "Unzipping #{name}..."
      `mkdir -p #{output_dir}`
      `unzip #{zip} -d #{output_dir}`
    end
  end
  
  def convert
    Dir[File.join( @unzip_dir, "**/*.shp" )].each do |shapefile|
      puts "Converting #{name_for(shapefile)}..."
      `ogr2ogr -t_srs EPSG:4326 -a_srs EPSG:4326 -f "ESRI Shapefile" #{shapefile.split('.shp')[0]}_4326.shp #{shapefile}`
    end
  end
  
  def import
    Dir[File.join( @unzip_dir, "**/*4326.shp" )].each do |shapefile|
      puts "Importing #{name_for(shapefile)}..."
      `shp2pgsql -s 4326 -d -g geometry #{shapefile} #{name_for(shapefile)} |psql civicapps`
    end
  end
end