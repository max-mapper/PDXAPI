#!/usr/bin/perl -w
use strict;
use warnings;
use YAML::Syck ();
use Data::Dumper ();
use URI::Split qw(uri_split uri_join);
use File::Basename;

my $namelist = ["neighborhoods","counties","bridges","zipcodes","parks","tran_cen","bicycle_network","homebuyer_opp_area","night_street_sweeping","street_permit_jobs_line","sidewalks","buslines","parks_taxlots","lrt_stop","cty_fill","nbo_hood","wellheadprotarea","cityhall","fire_sta","redline_1938","urban_renewal_area","lid_boundaries","snow_ice_routes","zipcode","pavement_moratorium","pedestrian_districts","transit_district","traffic_calming","development_opp_areas","streets_permit_jobs_point","bicycle_parking","its_cameras","tsp_district_boundaries","_replicator","heritage_trees","traffic_signals","transit_stations","parking_meters","public_art","parks_trails","business_associations","public_alerts","storefront_improvement_areas","co_fill","parkride","parks_desired_fut_cond","cities","parks_vegetation_survey","landmarks","streets_permit_jobs_polygon","hospital","freight_districts","day_street_sweeping","inspected_restaurants","lrt_line","parks_easements","street_contract_jobs","freight_facilities","intermodal_facilities","watershed","lid_streets","_users","hauler","signage_lighting_imp_prog","schools","vegetation","leaf_pickup","library","busstops","council","enterprise_ecommerce_zone","its_signs","guardrails","food_carts","curb_ramps"];


#print "@$namelist\n";

my $manual_fixes = {
		    'cityhalls' => 'cityhall',
		    'development_opportunity_areas' => 'development_opp_areas',
		    'firestations' => 'fire_sta',
		    'guardrail' => 'guardrails',
		    'homebuyer_opportunity_areas' => 'homebuyer_opp_area',
		    'hospitals' => 'hospital',
		    'its_camera' => 'its_cameras',
		    'its_sign' => 'its_signs',
		    'libraries' => 'library',
		    'lightrail' => 'lrt_line',
		    'lightrailstops' => 'lrt_stop',
		    'parks_desired_future_cond' => 'parks_desired_fut_cond',
		    'parks_vegetation_surveys' => 'parks_vegetation_survey',
		    'pavemoratorium' => 'pavement_moratorium',
		    'signage_lighting_improvement_program' => 'signage_lighting_imp_prog',
		    'traffic_signal' => 'traffic_signals',
		    'transitcenter' => 'tran_cen',
		    'transitdistrict' => 'transit_district',
		    'urban_renewal_areas' => 'urban_renewal_area',
		    'watersheds' => 'watershed',
		    'haulerfranchise' => 'hauler',
		    'wellhead_prot_areas' => 'wellheadprotarea',
		    'metrocouncil' => 'council',
		    'busroutes' => 'buslines',
		    'county' => 'co_fill',
		    'city' => 'cty_fill',
		    'neighborhoods' => 'nbo_hood',
		    'neighborhood_ass' => 'neighborhoods',
		    
		    };

my $dataset = YAML::Syck::LoadFile("datasets.yml");

#print "dataset keys ", join( "\n", keys %$dataset), "\n";
my $reverse_map = {};
foreach my $key (keys %$dataset)
  {
    my $uri = $dataset->{$key}{'uri'};
    my ($scheme, $auth, $path, $query, $frag) = uri_split($uri);
    #print "path->$path\n";
    my $filename_noext = fileparse($path,".zip");
    #print "filename_noext->$filename_noext\n";
    my $filename_noext_lc = lc($filename_noext);
    #print lc($filename_noext), "->", $key, "\n";
    $filename_noext_lc =~ s/neighborhoods_pdx/neighborhood_ass/;
    #the previous line is part of an ugly hack :-)
    $filename_noext_lc =~ s/_pdx$//;
    $filename_noext_lc =~ s/^portland_//;
    if(exists $manual_fixes->{$filename_noext_lc})
      {$filename_noext_lc = $manual_fixes->{$filename_noext_lc};}
    $reverse_map->{$filename_noext_lc} = $key;
  }

my %dbnames = ();

foreach my $name (@$namelist)
  {
    $dbnames{$name}++;
  }
#print join("\n", sort(keys(%dbnames))), "\n";
my %mergedlist = %dbnames;
foreach my $key (keys %$reverse_map)
  {$mergedlist{$key}++;}

foreach my $name (sort(keys %mergedlist))
  {
    if ($mergedlist{$name} == 2)
      {
	my $top_level = $reverse_map->{$name};
	print '+"', "$name",'" => "', $top_level,'"',",\n";
	$dataset->{$top_level}{'dataset_name'} = $name;
      }
    elsif (exists($reverse_map->{$name}))
      {
	print '-m-"', "$name",'" => "', $reverse_map->{$name},'"',",\n";
      }
    elsif (exists($dbnames{$name}))
      {
	print "d-$name\n";
      }
    else
      {
	print "!-ERROR-! $name not found wtf\n";
      }
  }


#print Data::Dumper->Dumper($dataset);

YAML::Syck::DumpFile("datasets_edited.yaml",$dataset);
