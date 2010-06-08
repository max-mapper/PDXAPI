# PREREQUISITE: use installer.rb to populate a postgis database with the civicapps data
@output_folder = "/home/max/web/pdxapi/json"
# memory failures: 'contours_5ft_pdx', 'corner_improved_pdx', 'curbs_pdx', 'parks', 'percent_slope_pdx', 'streets',
@datasets = ['bicycle_network_pdx', 'bicycle_parking_pdx', 'bridges_pdx', 'business_associations', 'buslines', 'busstops', 'cities', 'cityhall', 'co_fill', 'council', 'counties_pdx', 'cty_fill', 'curb_ramps_pdx', 'day_street_sweeping_pdx', 'development_opp_areas_pdx', 'enterprise_ecommerce_zone_pdx', 'fire_sta', 'freight_districts_pdx', 'freight_facilities_pdx', 'guardrails_pdx', 'hauler', 'heritage_trees_pdx', 'homebuyer_opp_area_pdx', 'hospital', 'intermodal_facilities_pdx', 'its_cameras_pdx', 'its_signs_pdx', 'leaf_pickup_pdx', 'library', 'lid_boundaries_pdx', 'lid_streets_pdx', 'lrt_line', 'lrt_stop', 'nbo_hood', 'neighborhoods_pdx', 'night_street_sweeping_pdx', 'parking_meters_pdx', 'parkride', 'parks_desired_fut_cond_pdx', 'parks_easements_pdx', 'parks_pdx', 'parks_taxlots_pdx', 'parks_trails_pdx', 'parks_vegetation_survey_pdx', 'pavement_moratorium_pdx', 'pedestrian_districts_pdx', 'schools', 'sidewalks_pdx', 'signage_lighting_imp_prog_pdx', 'snow_ice_routes_pdx', 'storefront_improvement_areas_pdx', 'street_contract_jobs_pdx', 'street_permit_jobs_line_pdx', 'streets_pdx', 'streets_permit_jobs_point_pdx', 'streets_permit_jobs_polygon_pdx', 'traffic_calming_pdx', 'traffic_signals_pdx', 'tran_cen', 'transit_district', 'transit_stations_pdx', 'tsp_classifications_pdx', 'tsp_district_boundaries_pdx', 'urban_renewal_area_pdx', 'vegetation_pdx', 'watershed_pdx', 'wellheadprotarea_pdx', 'zipcode', 'zipcodes_pdx', 'zoning', 'zoning_anno_pdx', 'zoning_arrows_pdx', 'zoning_lines_pdx', 'zoning_pdx']

require 'rubygems'
require 'pg'
require 'yaml'
require 'ruby-debug'
require 'json'

@db_name = "civicapps"
@db = PGconn.new("dbname=#{@db_name}")

@datasets.each do |dataset|
  puts dataset
  json_file = "#{@output_folder}/#{dataset}.json"
  next if File.exist? json_file
  
  #TODO: MEMORY OPTIMIZATION
  @geo_rows = @db.exec("SELECT ST_AsGeoJSON(geometry) from #{dataset}").map {|r| r}
  @rows = @db.exec("SELECT * from #{dataset}").map {|r| r}
  @rows.each_with_index do |row, index|
    row["geometry"] = JSON.parse(@geo_rows[index]["st_asgeojson"]) rescue nil
  end
  File.open(json_file, "w") {|file| file.puts(@rows.to_json) }
end