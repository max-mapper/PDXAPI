class PDXAPI
  module GeoFunctions
    def self.collect_features(features)
      return features if features["type"] == 'FeatureCollection' rescue false
      {"type"     =>  "FeatureCollection", 
       "features" =>  features.map{|feature| {"geometry" => feature}}}
    end
  
    def self.collect_geometries(geometries)
      return geometries if geometries["type"] == 'GeometryCollection' rescue false
      [{"type" => "GeometryCollection", "geometries" => geometries }]
    end
    
    def self.feature_collection_for(geojson)
      collect_features(collect_geometries(geojson))
    end
  end
end