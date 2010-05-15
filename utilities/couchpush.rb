require 'rubygems'
require 'pow'
require 'yaml'

class CouchPush
  def initialize(path)
    Pow(path).files.each do |dataset|
      name = dataset.name.split('.')[0]
      system "curl -X PUT http://localhost:5984/#{name}"
      system %Q!curl -X PUT -d '{\"spatial\":{\"points\":\"function(doc) {emit(doc._id, {type: \"Point\",coordinates: [doc.longitude, doc.latitude]});};\"}}\"}}' http://localhost:5984/#{name}/_design/main!
      post(name, YAML.load_file(dataset.path))
    end
  end
  
  def post(name, data)
    data.each_with_index do |d,i|
      json = "{"
      coords = {}
      d.each do |attribute, value|
        pair = %Q!\\"#{attribute}\\":\\"#{value}\\"!
        if value == "latitude" || value == "longitude"
          pair = %Q!\\"#{attribute}\\":#{value}!
        end
        json << %Q!#{pair},! unless value == ""
        case attribute
          when "latitude" then coords[:latitude] = value
          when "longitude" then coords[:longitude] = value
        end
      end
      json = json[0..-2]
      json << "}"
      system "curl -H \"Content-Type: application/json\" -X PUT -d \"#{json}\" http://localhost:5984/#{name}/#{coords[:longitude]}-#{coords[:latitude]}"
    end
  end
end

