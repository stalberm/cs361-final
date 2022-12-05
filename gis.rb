#!/usr/bin/env ruby

class Feature 

  attr_reader :properties, :coord_info

  def initialize(name, coord_info)
    @properties = {:name => name}
    @coord_info = coord_info
  end

  def get_json()
    name = properties[:name]
    icon = properties[:icon]
  
    json_string = '{"type": "' + self.class.superclass.name + '",'
    json_string += '"properties": {'
    
    if name != nil
      json_string += '"title": "' + name + '"'
    end
    if icon != nil 
      if name != nil
        json_string += ','
      end
      json_string += '"icon": "' + icon + '"' 
    end
    json_string += '},'

    json_string += '"geometry": {'
    json_string += '"type": "' + self.class.name + '",'
    json_string +='"coordinates": '
  
    json_string += coord_info
  
    json_string += '}}'
  end
end

class MultiLineString < Feature

  def initialize(line_strings, name=nil)
    coord_json = object_list_to_json(line_strings)
    super(name, coord_json)
  end

end


def object_list_to_json(object_list)
  json_list = '['
  object_list.each_with_index do |object, index|
    if index > 0
      json_list += ","
    end
    json_list += object.get_json
  end
  json_list += ']'
end

class LineString

  attr_reader :coords

  def initialize(coords)
    @coords = coords
  end

  def get_json()
    json_string = object_list_to_json(coords)
  end
end

class Coordinate

  attr_reader :lat, :lon, :elev

  def initialize(lon, lat, elev=nil)
    @lon = lon
    @lat = lat
    @elev = elev
  end

  def get_json()
    json_string = ''
    json_string += "[#{lon},#{lat}"
    if elev != nil
      json_string += ",#{elev}"
    end
    json_string += ']'
  end
end

class Point < Feature

  def initialize(coord, name=nil, icon=nil)
    coord_json = coord.get_json
    super(name, coord_json)
    properties[:icon] = icon
  end

end

class FeatureCollection

  attr_reader :features

  def initialize(name, features)
    @features = features
  end

  def add_feature(feature)
    @features.append(feature)
  end

  def get_json()
    json_string = '{"type": "' + self.class.name + '","features": '
    json_string += object_list_to_json(features)
    json_string += "}"
  end

end

def main()
  coord = Coordinate.new(-121.5, 45.5, 30)
  point1 = Point.new(coord, "home", "flag")

  coord = Coordinate.new(-121.5, 45.6, nil)
  point2 = Point.new(coord, "store", "dot")

  ls_coords = [
    Coordinate.new(-122, 45),
    Coordinate.new(-122, 46),
    Coordinate.new(-121, 46),
  ]
  ls1 = LineString.new(ls_coords)

  ls_coords = [ 
    Coordinate.new(-121, 45), 
    Coordinate.new(-121, 46),
   ]
  ls2 = LineString.new(ls_coords)

  ls_coords = [
    Coordinate.new(-121, 45.5),
    Coordinate.new(-122, 45.5),
  ]
  ls3 = LineString.new(ls_coords)
  

  mls1 = MultiLineString.new([ls1, ls2], "track 1")
  mls2 = MultiLineString.new([ls3], "track 2")

  feature_collection = FeatureCollection.new("My Data", [point1, point2, mls1, mls2])

  puts feature_collection.get_json()
end

if File.identical?(__FILE__, $0)
  main()
end

