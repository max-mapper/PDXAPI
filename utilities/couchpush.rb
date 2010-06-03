# THIS INSERTS .JSON FILES IN NEW_DATASETS INTO PDXAPI
# AN EXAMPLE OF GOOD DATA LOOKS LIKE THIS (AN ARRAY OF JSON OBJECTS, EACH WITH A GEOJSON GEOMETRY ATTRIBUTE):
# [{"name":"Matt Damon","geometry":{"coordinates":[-122.68161,45.520706],"type":"Point"},"hairstyle":"frosted tips"}]

require 'rubygems'
require 'pow'
require 'yaml'
require 'json'
require 'couchrest'
require 'net/http'

NEW_DATASETS = ["inspected_restaurants"]
DATASET_FOLDER = "/home/max/web/pdxapi/json"

class CouchPush
  def initialize(name)
    @db = CouchRest.database! "http://data.pdxapi.com/#{name}"
    view_exists = @db.get('_design/geojson') rescue false
    unless view_exists
      @db.save_doc({
        "_id" => "_design/geojson",
        "spatial" => {
          :points => "function(doc) {\n        emit(doc.geometry, doc.geometry);\n    };"
        }
      })
    end
    post(name, JSON.load(File.read("#{DATASET_FOLDER}/#{name}.json")))
  end
  
  def post(name, data)
    data.each_with_index do |d,i|
      response = @db.save_doc(d)
    end
  end
end

CouchPush.new(datasets)