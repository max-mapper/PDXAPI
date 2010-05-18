require 'rubygems'
require 'pow'
require 'yaml'
require 'json'
require 'couchrest'

class CouchPush
  def initialize(path)
    Pow(path).files.each do |dataset|
      name = dataset.name.split('.')[0]
      puts name
      @db = CouchRest.database!("http://localhost:5984/#{name}")
      @db.save_doc({
        "_id" => "_design/main", 
        :spatial => {
          :points => "function(doc) {\n        emit(doc.geometry, doc._id);\n    };"
        }
      })
      post(name, JSON.load(File.read("#{path}/#{name}.json")))
    end
  end
  
  def post(name, data)
    data.each_with_index do |d,i|
      d['geometry'] = JSON.load(d['geometry']) if d['geometry']
      response = @db.save_doc(d)
    end
  end
end

