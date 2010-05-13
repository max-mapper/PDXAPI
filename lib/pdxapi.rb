get '/' do
  File.read(File.join('public', 'index.html'))
end

get "/:resource" do
  content_type :json
  count = (params[:count].to_i > 0) ? params[:count].to_i : 1
  "#{params[:callback]}(#{Proximity.new(params[:lat], params[:lon]).nearest(params[:resource], count).to_json})"
end