get '/' do
  File.read(File.join('html/', 'index.html'))
end

get "/:resource" do
  content_type :json
  return {"error" => "You need to pass in an OpenSearch formatted bbox parameter"}.to_json unless params[:bbox]
  results = HTTParty.get("http://localhost:5984/#{params[:resource]}/_design/geojson/_spatial/points?bbox=#{params[:bbox]}")
  results = JSON.parse(results)
  results = results["rows"].map{|i| i["value"]["geometry"].merge({:id => i["value"]["id"]})}
  results = PDXAPI::GeoFunctions.feature_collection_for results
  results.to_json
end

get "/:resource/:id" do
  content_type :json
  results = HTTParty.get("http://localhost:5984/#{params[:resource]}/#{params[:id]}")
  results = JSON.parse(results)
  results.to_json
end

get "/image/:database/:couch_id" do
<<"EOF"
  <html>
  <head>
  	<meta name="viewport" content="width=320"/>  
  </head>
  <body>
  	<div>
  		<center>
  			<img src="http://localhost:5984/#{params[:database]}/#{params[:couch_id]}/menuphoto"/>
  		</center>
  	</div>
  </body>
  </html>
EOF
end