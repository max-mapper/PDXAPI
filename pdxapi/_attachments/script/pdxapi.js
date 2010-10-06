var map;
$(document).ready(function(){
  $('#fullscreen').live('click', function(){
    var button = $(this);
    button.text('view smaller');
    $('#map').animate({'height': $(window).height()}, function(){
      map.checkResize();
      updateBikeRacks();
    });
    $('#fullscreen').attr("id", "smallscreen");
  });
  
  $('#smallscreen').live('click', function(){
    var button = $(this);
    button.text('view larger');
    $('#map').animate({'height': '300px'}, function(){
      map.checkResize();
      updateBikeRacks();
    });
    $('#smallscreen').attr("id", "fullscreen");
  });

  
  function getBikeRacks(lat, lon, count) {
    var one_block = 0.0012;
    var dataset = 'bicycle_parking';
    $.ajax({
      url: "http://pdxapi.com/" + dataset + "/geojson?bbox="+ (lon - one_block) + "," + (lat - one_block) + "," + (lon + one_block) + "," + (lat + one_block),
      dataType: 'jsonp',
      success: function(response){
        var data = response.rows;
        map.clearOverlays();
        var markers = [];
        $.each(data, function(i,point) {
          var point = new GLatLng(point.bbox[1], point.bbox[0]);
          var marker = new GMarker(point, {icon:bikeRack});
          map.addOverlay(marker);
          markers.push(marker);
        });
      }
    });
  }
  
  function updateBikeRacks(){
    var center = map.getCenter();
    getBikeRacks(center.lat(), center.lng(), 10);
  };
  
  map = new GMap2($("#map").get(0));
  
  var bikeRack = new GIcon();
  bikeRack.image = 'images/bikerack.png';
  bikeRack.iconSize = new GSize(30,44);
  bikeRack.iconAnchor = new GPoint(15,44);
  bikeRack.infoWindowAnchor = new GPoint(15,0);
  bikeRack.imageMap = [27,0,29,1,28,2,28,3,29,4,29,5,28,6,28,7,28,8,28,9,28,10,28,11,28,12,28,13,28,14,28,15,28,16,28,17,28,18,28,19,28,20,28,21,28,22,28,23,28,24,28,25,28,26,28,27,28,28,28,29,29,30,29,31,29,32,25,33,28,34,4,35,4,36,6,37,8,38,22,39,22,40,9,41,10,42,10,43,0,43,1,42,0,41,0,40,0,39,1,38,1,37,1,36,1,35,1,34,1,33,1,32,1,31,1,30,1,29,1,28,1,27,1,26,2,25,2,24,2,23,2,22,2,21,2,20,2,19,2,18,1,17,1,16,1,15,1,14,1,13,1,12,1,11,1,10,1,9,1,8,1,7,2,6,2,5,3,4,4,3,2,2,6,1,10,0];
  map.addMapType({type:G_AERIAL_MAP});
  map.setMapType(G_AERIAL_MAP);
  var portlandOR = new GLatLng(45.51330163230602, -122.67764210700989);
  map.setCenter(portlandOR, 18);

  GEvent.addListener(map, "moveend", function(){
    updateBikeRacks();
  });
  
  updateBikeRacks();
});