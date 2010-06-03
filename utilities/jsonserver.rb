get '/' do
  File.read(File.join('/home/max/web/pdxapi/public', 'index.html'))
end

get "/:resource" do
  content_type :json
  return {"error" => "You need to pass in an OpenSearch formatted bbox parameter"}.to_json unless params[:bbox]
  results = HTTParty.get("http://localhost:5984/#{params[:resource]}/_design/geojson/_spatial/points?bbox=#{params[:bbox]}")
  results = JSON.parse(results)
  results = results["spatial"].map{|i| i["value"]}
  results = PDXAPI::GeoFunctions.feature_collection_for results
  results.to_json
end