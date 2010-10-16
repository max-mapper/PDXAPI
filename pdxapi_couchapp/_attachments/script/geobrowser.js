var GeoJSONHelper = function() {
  return {
    collect_geometries : function(geometries) {
      if (geometries.type == 'GeometryCollection')
        return geometries;
      return [{"type" : "GeometryCollection", "geometries" : geometries }]
    },
    collect_features : function(features){
      if (features.type == 'FeatureCollection')
        return features;
      return { "type" : "FeatureCollection", "features" : features }
    },
    pdxapi_feature_collection : function(data) {
      var features = $.map(data.rows, function(row, idx){
        return {
          geometry: row.value.geometry,
          type: 'Feature',
          properties: {id: row.id}
        };
      });
      return GeoJSONHelper.collect_features(features);
    }
  }
}();

var Map = function() {
  return {
    geocoder: new GClientGeocoder(),
    couchUrl: "http://pdxapi.com/",
    currentDataset: "",
    fetchFeatures: function() {
      Indicator.show();
      $.ajax({
        url: Map.couchUrl + Map.currentDataset + "/geojson",
        dataType: 'jsonp',
        data: {
          "bbox": Map.container.getExtent().transform( proj900913, proj4326 ).toBBOX()
        },
        success: function(data){
          Indicator.hide();
          var feature_collection = GeoJSONHelper.pdxapi_feature_collection(data);
          Map.drawFeature(Map.geojson_format.read(feature_collection));
        }
      })
    },
    formatMetadata: function(data) {
      out = '<dl>';
      $.each(data, function(key, val) {
        if (typeof(val) == 'string' && key[0] != '_') {
          out = out + '<dt>' + key + '<dd>' + val;
        } else if (typeof(val) == 'object' && key != "geometry" && val != null) {
          if (key == 'properties') {
            $.each(val, function(attr, value){
              out = out + '<dt>' + attr + '<dd>' + value;
            })
          } else {
            out = out + '<dt>' + key + '<dd>' + val.join(', ');
          }
        }
      });
      out = out + '</dl>';
      return out;
    },
    fetchFeatureMetadata: function(feature) {
      Map.clearMetadata(feature);
      $.ajax({
        url: Map.couchUrl + Map.currentDataset + "/" + feature.attributes.id,
        dataType: 'jsonp',
        success: function(data) {
          // TODO: Format using formatting func
          $('#metadata').html("<h3>Feature Metadata</h3>"+
            Map.formatMetadata(data));
        }
      });
    },
    clearMetadata: function(arg) {
      $('#metadata').html('');
    },
    fetchDatasetMetadata: function(dataset) {
      Map.clearMetadata(dataset);
      $.ajax({
        url: Map.couchUrl + "pdxapi/" + Map.currentDataset,
        dataType: 'jsonp',
        success: function(data){
          $('#metadata').html("<h3>Dataset Metadata</h3>"+
            Map.formatMetadata(data)
          );
        }
      });
    },

    drawFeature: function(features) {
      $.each(features, function(idx, item) {
        item.geometry.transform(proj4326, proj900913);
      });
      Map.vector_layer.destroyFeatures();
      Map.vector_layer.addFeatures(features);
    }
  }
}();

var Indicator = {
  show: function(text) {
    var top = $('#map').height() / 2 - 50;
    var left = $('#map').width() / 2 - 50;
    $('#loader').show().css({'top': top, 'left': left});
  },
  hide: function() {
    $('#loader').hide();
  }
}

var showing_layers = [];

$(function() {
  $('.geocoder_form').submit(function(){
    Map.geocoder.getLatLng(this.address.value + " portland, oregon", function(point) {
      if (!point) {
        alert(address + " not found");
      } else {
        var newCenter = new OpenLayers.LonLat(point.x, point.y);
        newCenter.transform( proj4326, proj900913 )
        Map.container.setCenter(newCenter, 16);
      }
    });
    return false;
  })
  
  OpenLayers.ImgPath="/images/themes/dark/"
  $.ajax({
    url: "http://maxogden.couchone.com/_all_dbs",
    dataType: 'jsonp',
    success: function(databases){
      var dbList = $('#databases');
      $.each(databases.sort(), function(index, database){
        if (database[0] !== "_" && database !== "pdxapi") {
          dbList.append('<li>' + database + '</li>');
        }
      });
      $('#databases li:first').click();
    }
  });

  proj900913 = new OpenLayers.Projection("EPSG:900913"); //Spherical mercator used for google maps
  proj4326 = new OpenLayers.Projection("EPSG:4326"); 
  var lat = 45.52811798237782;
  var lon = -122.66733169555664;
  var fifteenMiles = 0.03;
  var pdxLL = new OpenLayers.LonLat(lon - fifteenMiles, lat - fifteenMiles);
  var pdxUR = new OpenLayers.LonLat(lon + fifteenMiles, lat + fifteenMiles);
  pdxLL.transform( proj4326, proj900913 );
  pdxUR.transform( proj4326, proj900913 );
  Map.options = {
    maxExtent: new OpenLayers.Bounds(pdxLL.lon,pdxLL.lat, pdxUR.lon,pdxUR.lat),    
    restrictedExtent: new OpenLayers.Bounds(pdxLL.lon,pdxLL.lat, pdxUR.lon,pdxUR.lat),    
    projection: proj900913,
    displayProjection: proj4326,
    tileSize: new OpenLayers.Size(256, 256),
    controls: [
      new OpenLayers.Control.Navigation(),
      new OpenLayers.Control.PanZoomBar(),
      new OpenLayers.Control.KeyboardDefaults()
    ]
  };
  Map.container = new OpenLayers.Map('map', Map.options);
  Map.gmap = new OpenLayers.Layer.Google("Google Streets", {"sphericalMercator": true, MIN_ZOOM_LEVEL: 14, MAX_ZOOM_LEVEL: 21}); 
  Map.container.addLayer(Map.gmap);

  Map.styleMap = new OpenLayers.StyleMap({
    'default': OpenLayers.Util.applyDefaults({
      fillOpacity: 0.2, 
      strokeColor: "black", 
      strokeWidth: 4,
      pointRadius: 10
    }),
    'select': new OpenLayers.Style({
      strokeColor: "#019DBE",
    }),
    'temporary': new OpenLayers.Style({
      strokeColor: "#DE027F",
    }),
  });

  Map.vector_layer = new OpenLayers.Layer.Vector("GeoJSON", {
    projection: proj4326, 
    styleMap: Map.styleMap
  });
  Map.container.addLayer(Map.vector_layer);

  var highlightCtrl = new OpenLayers.Control.SelectFeature(Map.vector_layer, {
      hover: true,
      highlightOnly: true,
      renderIntent: "temporary",
  });

  var selectCtrl = new OpenLayers.Control.SelectFeature(Map.vector_layer, {
      onSelect: Map.fetchFeatureMetadata,
      onUnselect: Map.clearMetadata, 
  });

  Map.container.addControl(highlightCtrl);
  Map.container.addControl(selectCtrl);

  highlightCtrl.activate();
  selectCtrl.activate();

  Map.geojson_format = new OpenLayers.Format.GeoJSON();     

  Map.container.setCenter(new OpenLayers.LonLat(-122.6762071,45.5234515), 3);
  Map.container.events.register( 'moveend', this, function(){ Map.fetchFeatures() });

  if (OpenLayers.Control.MultitouchNavigation) {
    var touchControl = new OpenLayers.Control.MultitouchNavigation();
    Map.container.addControl(touchControl);
  }
  
  
  $('#databases li').live('click', function(){
    var dataset = $(this).text();
    $('.selected').removeClass('selected');
    $(this).addClass('selected');
    Map.currentDataset = dataset;
    Map.fetchDatasetMetadata(dataset);
    Map.fetchFeatures();
  });
});
