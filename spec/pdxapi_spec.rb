require File.dirname(__FILE__) + "/../utilities/pdxapi"
require 'spec'

describe PDXAPI::GeoFunctions do
  describe "#collect_geometries" do
    it "should wrap geometries in a geometry collection" do
      points = [{"coordinates" => [-122.672727,45.521561],"type" => "Point"}, 
                {"coordinates" => [-122.675647,45.523729],"type" => "Point"}]
      geometry_collection = [{"type" => "GeometryCollection", "geometries" => points }]
      PDXAPI::GeoFunctions.collect_geometries(points).should == geometry_collection
    end
    
    it "shouldn't alter existing geometry collections" do
      geometry_collection = { "type" => "GeometryCollection",
                              "geometries" => [
                                { "coordinates" => [-122.672727,45.521561], "type" => "Point" },
                                { "coordinates" => [-122.675647,45.523729], "type" => "Point" }
                              ]
                            }
      PDXAPI::GeoFunctions.collect_geometries(geometry_collection).should == geometry_collection
    end
  end
  
  describe "#collect_features" do
    it "should wrap geometry collections in a feature collection" do
      geometry_collections = [{"type" => "GeometryCollection", 
                               "geometries" => 
                                 [{"type"=>"LineString",
                                   "coordinates" => [[-122.593225, 45.563783], [-122.592189, 45.563325]]
                                 }]
                              },
                              {"type" => "GeometryCollection", 
                                 "geometries" => 
                                   [{"type"=>"LineString",
                                      "coordinates" => [[-122.593225, 45.563783], [-122.592189, 45.563325]]
                                   }]
                             }]
      feature_collection = {"type" =>  "FeatureCollection", 
                            "features" => [{"geometry" => geometry_collections[0]}, {"geometry" => geometry_collections[1]}]
                           }
      PDXAPI::GeoFunctions.collect_features(geometry_collections).should == feature_collection
    end
    
    it "shouldn't alter existing feature collections" do
      feature = { "type" => "FeatureCollection",
                  "features" => [{"geometry" => 
                    { "type" => "GeometryCollection",
                      "geometries" => [
                        { "coordinates" => [-122.672727,45.521561], "type" => "Point" },
                        { "coordinates" => [-122.675647,45.523729], "type" => "Point" }
                      ]
                    }}
                  ]
                }
      PDXAPI::GeoFunctions.collect_features(feature).should == feature
    end
  end
  
  describe "#feature_collection_for" do
    it "should convert arbitrary arrays of individual geojson objects into a feature collection" do
      points = [{"coordinates" => [-122.672727,45.521561],"type" => "Point"}, 
                {"coordinates" => [-122.675647,45.523729],"type" => "Point"}]
      PDXAPI::GeoFunctions.feature_collection_for(points).should == 
        { "type" => "FeatureCollection",
          "features" => [{"geometry" => 
            { "type" => "GeometryCollection",
              "geometries" => [
                { "coordinates" => [-122.672727,45.521561], "type" => "Point" },
                { "coordinates" => [-122.675647,45.523729], "type" => "Point" }
              ]
            }}
          ]
        }
    end
  end
end
