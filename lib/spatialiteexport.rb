# USAGE: use lokkju's http://code.google.com/p/pyspatialite/ and http://code.google.com/p/pyod/ to populate a spatialite enabled .sqlite database with civicapps data. should weigh in at around 700mb

require 'sqlite3' # see http://rails.nomad-labs.com/?p=34 for installation instructions

DATASETS = ['pdx_address_points', 'pdx_address_points_region', 'pdx_bicycle_network', 'pdx_bicycle_parking', 'pdx_bridges', 'pdx_business_association_boundaries', 'pdx_capital_improvement_projects_line', 'pdx_capital_improvement_projects_point', 'pdx_capital_improvement_projects_poly', 'pdx_city_boundaries', 'pdx_city_boundaries_region', 'pdx_city_halls_region', 'pdx_corners', 'pdx_county_boundaries', 'pdx_county_boundaries_region', 'pdx_crime_incidents', 'pdx_curb_ramps', 'pdx_curbs', 'pdx_development_opportunity_areas', 'pdx_elevation_map', 'pdx_enterprise_and_e_commerce_zones', 'pdx_fire_stations_region', 'pdx_freight_districts', 'pdx_freight_facilities', 'pdx_garbage_hauler_boundaries', 'pdx_ground_slope', 'pdx_guardrails', 'pdx_heritage_trees', 'pdx_home_buyer_opportunity_areas', 'pdx_hospitals_region', 'pdx_intermodal_facilities', 'pdx_its_cameras_intelligent_transportation_system', 'pdx_its_signs_intelligent_transportation_system', 'pdx_leaf_pickup', 'pdx_libraries_region', 'pdx_light_rail', 'pdx_light_rail_stops', 'pdx_local_improvement_districts', 'pdx_metro_council_districts', 'pdx_neighborhood_associations', 'pdx_neighborhood_associations_region', 'pdx_parking_meters', 'pdx_parks', 'pdx_parks_desired_future_conditions', 'pdx_parks_easements', 'pdx_parks_region', 'pdx_parks_taxlots', 'pdx_parks_trails', 'pdx_parks_vegetation_survey', 'pdx_pavement_maintained_not_maintained', 'pdx_pavement_moratorium_streets', 'pdx_pedestrian_districts', 'pdx_schools_region', 'pdx_sidewalks', 'pdx_snow_ice_routes', 'pdx_storefront_improvement_areas', 'pdx_street_centerline_pdx', 'pdx_street_centerlines', 'pdx_street_sweeping_routes_day', 'pdx_street_sweeping_routes_night', 'pdx_streets_jobs_contract_jobs_line', 'pdx_streets_jobs_contract_jobs_points', 'pdx_streets_jobs_permit_jobs_line', 'pdx_streets_jobs_permit_jobs_points', 'pdx_streets_jobs_permit_jobs_polygon', 'pdx_streets_local_improvement_district', 'pdx_streets_region', 'pdx_traffic_calming_devices', 'pdx_traffic_signals', 'pdx_transit_district_poly', 'pdx_transit_stations', 'pdx_trimet_bus_system_routes', 'pdx_trimet_bus_system_stops', 'pdx_trimet_park_and_ride_lots', 'pdx_trimet_transit_centers', 'pdx_tsp_classifications', 'pdx_tsp_district_boundaries', 'pdx_urban_renewal_areas', 'pdx_vegetation', 'pdx_watershed_sub_watershed_info', 'pdx_wellhead_protection_area', 'pdx_zip_codes', 'pdx_zip_codes_region', 'pdx_zoning', 'pdx_zoning_anno', 'pdx_zoning_arrows', 'pdx_zoning_lines', 'pdx_zoning_region']
SPATIALITE_DB = "" # path to spatialite .sqlite database
OUTPUT_FOLDER = ""
SPATIALITE_LIB = "/usr/local/Cellar/libspatialite/2.4.0/lib/libspatialite.dylib" # via brew install libspatialite

db = SQLite3::Database.new(SPATIALITE_DB)
db.enable_load_extension( 1 )
db.load_extension(SPATIALITE_LIB)
db.enable_load_extension( 0 )

DATASETS.each do |dataset|  
  puts dataset
  data = {:name => dataset, :data => db.execute("select astext(transform(geometry,4326)) from #{dataset};")}
  File.open("#{OUTPUT_FOLDER}/#{dataset}.yml", "w") {|file| file.puts(data.to_yaml) }
end

# no such geometry errors on:
# 'pdx_address_points'

# malloc errors on: 
#  'pdx_city_boundaries_region', 'pdx_crime_incidents', 'pdx_ground_slope', 'pdx_parks_desired_future_conditions', 'pdx_zoning'