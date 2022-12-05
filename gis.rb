#!/usr/bin/env ruby

class MultiLineString

  attr_reader :segments, :name

  def initialize(segments, name=nil)
    @name = name
    @segments = segments
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

    segments.each_with_index do |s, index|
      if index > 0
        json_string += ","
      end
      json_string += '['
      temp_point_json = ''
      s.points.each do |point|
        if temp_point_json != ''
          temp_point_json += ','
        end
        temp_point_json += '['
        temp_point_json += "#{point.lon},#{point.lat}"
        if point.elev != nil
          temp_point_json += ",#{point.elev}"
        end
        temp_point_json += ']'
      end
      json_string+=temp_point_json
      json_string+=']'
    end
    json_string + ']}}'
  end

end

class TrackSegment

  attr_reader :points

  def initialize(points)
    @points = points
  end
  
end

class Coordinate

  attr_reader :lat, :lon, :elev

  def initialize(lon, lat, elev=nil)
    @lon = lon
    @lat = lat
    @elev = elev
  end

end

class Waypoint

  attr_reader :point, :name, :icon

  def initialize(point, name=nil, icon=nil)
    @point = point
    @name = name
    @icon = icon
  end

  def get_json()
    json_string = '{"type": "Feature",'

    json_string += '"geometry": {"type": "Point","coordinates": '
    json_string += "[#{point.lon},#{point.lat}"
    if point.elev != nil
      json_string += ",#{point.elev}"
    end
    json_string += ']},'

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
  w = Waypoint.new(p, "home", "flag")
  coord = Coordinate.new(-121.5, 45.6, nil)
  w2 = Waypoint.new(p, "store", "dot")

  ts1_coords = [
    Coordinate.new(-122, 45),
    Coordinate.new(-122, 46),
    Coordinate.new(-121, 46),
  ]
  ts1 = TrackSegment.new(ts1_coords)

  ts2_coords = [ 
    Coordinate.new(-121, 45), 
    Coordinate.new(-121, 46),
   ]

  ts2 = TrackSegment.new(ts2_coords)

  ts3_coords = [
    Coordinate.new(-121, 45.5),
    Coordinate.new(-122, 45.5),
  ]

  ts3 = TrackSegment.new(ts3_coords)
  
  t = MultiLineString.new([ts1, ts2], "track 1")
  t2 = MultiLineString.new([ts3], "track 2")

  feature_collection = FeatureCollection.new("My Data", [w, w2, t, t2])

  puts feature_collection.get_json()
end

if File.identical?(__FILE__, $0)
  main()
end

