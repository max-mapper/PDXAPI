
# This utility turned out to be too memory inefficient to be useful with the data I was working with, so I used the ruby version of this algorithm instead
# I have included it here for reference, as it demonstrates how to convert WKT to GeoJson in python

import sys
import yaml
import os
from geojson import dumps
from shapely.wkt import loads
path = '/datasets'
datasets=os.listdir(path)

for dataset_yaml in datasets:
  print dataset_yaml
  dataset = yaml.load(open(path+dataset_yaml, 'r').read())
  for data in dataset:
      if data.has_key('geometry'):
          print data['geometry']
          updated = dumps(loads(data['geometry']))
          data['geometry'] = updated
  f = open(path+"latlon/"+dataset_yaml, "w")
  yaml.dump(dataset, f)
  f.close()