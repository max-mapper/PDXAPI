// parses ATIS xml and returns activitystreams
// built to parse the ATIS xml road incident feed from ODOT TTIP

var sys = require('sys')
    , fs = require('fs')
    , xml2js = require('xml2js');

var parser = new xml2js.Parser();

function getClass(obj) {
  if (typeof obj === "undefined")
    return "undefined";
  if (obj === null)
    return "null";
  return Object.prototype.toString.call(obj)
    .match(/^\[object\s(.*)\]$/)[1];
}

function zeroPad(n, pad) {
    return n < pad ? '0' + n : n;
}

function rfc3339(ymdhms) {
  return ymdhms.substr(0,4) + '-' +
    ymdhms.substr(4, 2)     + '-' +
    ymdhms.substr(6, 2)     + 'T' +
    ymdhms.substr(8, 2)     + ':' +
    ymdhms.substr(10,2)     + ':' +
    ymdhms.substr(12,2)     + 'Z';
};

function lengthInMiles(locationData) {
  return locationData.linearReferenceLink.offset2.miDec -
  locationData.linearReferenceLink.offset1.miDec;
}

function parseLocation(location) {
  if (!location.latitde) return [null, null];
  var x = [], y = [];
  x = x.concat(location.latitude.substr(0, 2));
  x = x.concat(location.latitude.split(x[0])[1]);
  y = y.concat(location.longitude.substr(0, 4));
  y = y.concat(location.longitude.split(y[0])[1]);    
  return [x.join('.'), y.join('.')];
}

function postedTime(event) {
  return rfc3339(event.head.updateTime.date +""+ event.head.updateTime.time);
}

function getText(text) {
  var content = "";
  if (getClass(text) == "Array") {
    content = text.join(' ');
  } else if (text.length > 0) {
    content = text;
  }
  return content;
}

function contentFor(event) {
  var text = getText(event.advice.text);
  if (text == "") text = getText(event.description.text);
  return text;
}

function parseEvent(event) {
  var locationData = event.location.linkLocation;
  var location = locationData.geoLocationLink.startPoint;
  var oregonHwyId = locationData.linearReferenceLink.refOrImplicitType.link.linkId.idAlpha;
  var travelDirection = locationData.linearReferenceLink.travelDirection;

  var parsed = {
    "postedTime" : postedTime(event)
    , "object" : {
         "content" : contentFor(event)
       , "permalinkUrl" : event.tail.entry[8]['value']
       , "objectType" : "article"
       , "summary" : getText(event.description.text)
       , "location" : parseLocation(location)
       , "locationName" : event.location.locationName
       , "oregonHwyId" : zeroPad(oregonHwyId, 100)
       , "travelDirection": travelDirection
       , "lengthInMiles": lengthInMiles(locationData)
       , "startDate" : rfc3339(event.startTime.date +""+ event.startTime.time)
       , "endDate" : rfc3339(event.clearTime.date +""+ event.clearTime.time)
      }
     , "verb" : "post"
     , "actor" : {
         "permalinkUrl" : "http://www.oregon.gov/ODOT"
       , "objectType" : "service"
       , "displayName" : "ODOT"
      }
  }

  for (i = 0; i <= 7; i++) {
    parsed['object'][event.tail.entry[i]['tag']] = event.tail.entry[i]['value'];
  }

  return parsed;
}

function parseIncident(event) {
  var locationData = event.location.linkLocation;
  var location = locationData.geoLocationLink.startPoint;
  var oregonHwyId = locationData.linearReferenceLink.refOrImplicitType.link.linkId.idAlpha;
  var travelDirection = locationData.linearReferenceLink.travelDirection;
  
  var parsed = {
    "postedTime" : postedTime(event)
    , "object" : {
         "content" : contentFor(event)
       , "permalinkUrl" : event.tail.entry[8]['value']
       , "objectType" : "article"
       , "incidentType" : event.typeEvent.accidentsAndIncidents
       , "summary" : getText(event.description.text)
       , "location" : parseLocation(location)
       , "locationName" : event.location.locationName
       , "oregonHwyId" : zeroPad(oregonHwyId, 100)
       , "travelDirection": travelDirection
       , "lengthInMiles": lengthInMiles(locationData)
       , "startDate" : rfc3339(event.startTime.date +""+ event.startTime.time)
       , "endDate" : rfc3339(event.clearTime.date +""+ event.clearTime.time)
      }
     , "verb" : "post"
     , "actor" : {
         "permalinkUrl" : "http://www.oregon.gov/ODOT"
       , "objectType" : "service"
       , "displayName" : "ODOT"
      }
  }

  for (i = 0; i <= 7; i++) {
    parsed['object'][event.tail.entry[i]['tag']] = event.tail.entry[i]['value'];
  }

  return parsed;
}

function parseLink(event) {
  var locationData = event.location.linkLocation;
  var location = locationData.geoLocationLink.startPoint;
  var oregonHwyId = locationData.linearReferenceLink.refOrImplicitType.link.linkId.idAlpha;
  var travelDirection = locationData.linearReferenceLink.travelDirection;
  
  var parsed = {
    "postedTime" : postedTime(event)
    , "object" : {
         "content" : event.tmddOther
       , "permalinkUrl" : event.tail.entry[8]['value']
       , "objectType" : "article"
       , "summary" : event.tail.entry[1]['value']
       , "location" : parseLocation(location)
       , "locationName" : event.location.locationName
       , "oregonHwyId" : zeroPad(oregonHwyId, 100)
       , "travelDirection": travelDirection
       , "lengthInMiles": lengthInMiles(locationData)
       , "startDate" : rfc3339(event.coverageTime.start.date +""+ event.coverageTime.start.time)
       , "endDate" : rfc3339(event.coverageTime.end.date +""+ event.coverageTime.end.time)
      }
     , "verb" : "post"
     , "actor" : {
         "permalinkUrl" : "http://www.oregon.gov/ODOT"
       , "objectType" : "service"
       , "displayName" : "ODOT"
      }
  }

  for (i = 0; i <= 7; i++) {
    parsed['object'][event.tail.entry[i]['tag']] = event.tail.entry[i]['value'];
  }

  return parsed;
}

parser.addListener('end', function(data) {
  var events = data.responseGroups.responseGroup[1].events.event;
  var incidents = data.responseGroups.responseGroup[2].incidents.incident;
  var links = data.responseGroups.responseGroup[3].links.link;

  // use parseEvent, parseIncident or parseLink against events, incidents and links to get activitystream objects
  
  for (var i in links) {
    console.log(sys.inspect(
      {
         _id: links[i].head.id
       , feed: parseLink(links[i])
      }
    ));
  }
});

fs.readFile(__dirname + '/highway.xml', function(err, data) {
    //highway.xml is the saved version of http://www.tripcheck.com/TTIPv2/TTIPData/DataRequest.aspx?uid=YOURTTIPUUIDHERE&fn=incd
    parser.parseString(data);
});
