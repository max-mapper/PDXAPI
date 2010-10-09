$(function(){
  var currentDataset = "bridges";
  var po = org.polymaps;

  var map = po.map()
      .container(document.getElementById("map").appendChild(po.svg("svg")))
      .center({lat: 45.5234515, lon: -122.6762071})
      .zoom(14)
      .zoomRange([12, 16])
      .add(po.interact());

      map.add(po.image()
          .url(po.url("http://{S}tile.cloudmade.com"
          + "/1a1b06b230af4efdbb989ea99e9841af" // http://cloudmade.com/register
          + "/998/256/{Z}/{X}/{Y}.png")
          .hosts(["a.", "b.", "c.", ""])));
      
      $.ajax({
        url: "http://maxogden.couchone.com/" + currentDataset + "/_design/geojson/_spatial/points",
        dataType: 'jsonp',
        data: {
          "bbox": "-180,180,-90,90"
        },
        success: function(data){
          $.each(data.rows, function(i, row) {
            map.add(po.geoJson().features([{"geometry": row.value.geometry}]))
          });
        }
      });
              
  map.add(po.compass()
      .pan("none"));
})