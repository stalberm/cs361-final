#!/usr/bin/env ruby

class MultiLineString

  attr_reader :line_strings, :name

  def initialize(line_strings, name=nil)
    @name = name
    @line_strings = line_strings
  end

  def get_json()
    json_string = '{'
    json_string += '"type": "Feature", '
    if name != nil
      json_string+= '"properties": {'
      json_string += '"title": "' + name + '"'
      json_string += '},'
    end
    json_string += '"geometry": {'
    json_string += '"type": "MultiLineString",'
    json_string +='"coordinates": ['

    line_strings.each_with_index do |line_string, index|
      if index > 0
        json_string += ","
      end
      json_string += '['
      temp_point_json = ''
      line_string.coords.each do |coord|
        if temp_point_json != ''
          temp_point_json += ','
        end
        temp_point_json += coord.get_json
      end
      json_string+=temp_point_json
      json_string+=']'
    end
    json_string + ']}}'
  end

end

class LineString

  attr_reader :coords

  def initialize(coords)
    @coords = coords
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

class Point

  attr_reader :coord, :name, :icon

  def initialize(coord, name=nil, icon=nil)
    @coord = coord
    @name = name
    @icon = icon
  end

  def get_json()
    json_string = '{"type": "Feature",'

    json_string += '"geometry": {"type": "Point","coordinates": '
    json_string += coord.get_json
    json_string += '},'
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
    json_string += '}'
 
    json_string += "}"
    return json_string
  end

end

class FeatureCollection

  def initialize(name, features)
    @name = name
    @features = features
  end

  def add_feature(feature)
    @features.append(feature)
  end

  def get_json()
    json_string = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |feature,i|

      if i != 0
        json_string +=","
      end

      json_string += feature.get_json
    end
    json_string + "]}"
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

