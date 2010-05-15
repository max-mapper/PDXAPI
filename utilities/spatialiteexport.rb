# USAGE: use lokkju's http://code.google.com/p/pyspatialite/ and http://code.google.com/p/pyod/ to populate a spatialite enabled .sqlite database with civicapps data. should weigh in at around 700mb

require 'sqlite3' # see http://rails.nomad-labs.com/?p=34 for installation instructions
require 'ap'
require 'yaml'

SPATIALITE_DB = "/Users/Shared/test.sqlite" # path to spatialite .sqlite database
OUTPUT_FOLDER = "/Users/Shared/merged_datasets"
SPATIALITE_LIB = "/usr/local/Cellar/libspatialite/2.4.0/lib/libspatialite.dylib" # via brew install libspatialite

# note: Need to convert on a computer with more than 2gb RAM. malloc errors when these are attempted: 
# 'city_boundaries_region', 'crime_incidents', 'ground_slope', 'parks_desired_future_conditions', 'zoning', 'address_points_region', 'parks', 'parks_region', 'parks_taxlots', 'street_sweeping_routes_day', 'street_sweeping_routes_night', 'streets_region'

DATASETS = ['bicycle_network', 'bicycle_parking', 'bridges', 'business_association_boundaries', 'capital_improvement_projects_line', 'capital_improvement_projects_point', 'capital_improvement_projects_poly', 'city_boundaries', 'city_halls_region', 'corners', 'county_boundaries', 'county_boundaries_region', 'curb_ramps', 'curbs', 'development_opportunity_areas', 'elevation_map', 'enterprise_and_e_commerce_zones', 'fire_stations_region', 'freight_districts', 'freight_facilities', 'garbage_hauler_boundaries', 'guardrails', 'heritage_trees', 'home_buyer_opportunity_areas', 'hospitals_region', 'intermodal_facilities', 'its_cameras_intelligent_transportation_system', 'its_signs_intelligent_transportation_system', 'leaf_pickup', 'libraries_region', 'light_rail', 'light_rail_stops', 'local_improvement_districts', 'metro_council_districts', 'neighborhood_associations', 'neighborhood_associations_region', 'parking_meters', 'parks_easements', 'parks_trails', 'parks_vegetation_survey', 'pavement_maintained_not_maintained', 'pavement_moratorium_streets', 'pedestrian_districts', 'schools_region', 'sidewalks', 'snow_ice_routes', 'storefront_improvement_areas', 'street_centerline_pdx', 'street_centerlines',  'streets_jobs_contract_jobs_line', 'streets_jobs_contract_jobs_points', 'streets_jobs_permit_jobs_line', 'streets_jobs_permit_jobs_points', 'streets_jobs_permit_jobs_polygon', 'streets_local_improvement_district', 'traffic_calming_devices', 'traffic_signals', 'transit_district_poly', 'transit_stations', 'trimet_bus_system_routes', 'trimet_bus_system_stops', 'trimet_park_and_ride_lots', 'trimet_transit_centers', 'tsp_classifications', 'tsp_district_boundaries', 'urban_renewal_areas', 'vegetation', 'watershed_sub_watershed_info', 'wellhead_protection_area', 'zip_codes', 'zip_codes_region', 'zoning_anno', 'zoning_arrows', 'zoning_lines', 'zoning_region']

db = SQLite3::Database.new(SPATIALITE_DB)
db.enable_load_extension( 1 )
db.load_extension(SPATIALITE_LIB)
db.enable_load_extension( 0 )

DATASETS.each do |dataset|
  puts dataset
  yaml_file = "#{OUTPUT_FOLDER}/#{dataset}.yml"
  next if File.exist? yaml_file
  columns = db.execute("pragma table_info(pdx_#{dataset})").map{|i| i[1]}
  geo_rows = db.execute("select astext(transform(geometry,4326)) from pdx_#{dataset}")
  geo_index = columns.index("Geometry")
  columns.delete_at(geo_index)
  rows = db.execute("select * from pdx_#{dataset}")
  merged = []
  rows.each_with_index do |row, index|
    row.delete_at(geo_index)
    merged << Hash[*columns.zip(row).flatten].merge({"geometry" => geo_rows[index][0]})
  end
  File.open(yaml_file, "w") {|file| file.puts(merged.to_yaml) }
  puts yaml_file
end