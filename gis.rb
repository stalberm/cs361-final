#!/usr/bin/env ruby

class Track

  attr_reader :segments, :name

  def initialize(segments, name=nil)
    @name = name
    segment_objects = []
    segments.each do |s|
      segment_objects.append(TrackSegment.new(s))
    end
    @segments = segment_objects
  end

  def get_track_json()
    j = '{'
    j += '"type": "Feature", '
    if name != nil
      j+= '"properties": {'
      j += '"title": "' + name + '"'
      j += '},'
    end
    j += '"geometry": {'
    j += '"type": "MultiLineString",'
    j +='"coordinates": ['

    segments.each_with_index do |s, index|
      if index > 0
        j += ","
      end
      j += '['
      tsj = ''
      s.points.each do |point|
        if tsj != ''
          tsj += ','
        end
        # Add the coordinate
        tsj += '['
        tsj += "#{point.lon},#{point.lat}"
        if point.elev != nil
          tsj += ",#{point.elev}"
        end
        tsj += ']'
      end
      j+=tsj
      j+=']'
    end
    j + ']}}'
  end

end

class TrackSegment

  attr_reader :points

  def initialize(points)
    @points = points
  end
  
end

class Point

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

  def get_waypoint_json()
    j = '{"type": "Feature",'
    j += '"geometry": {"type": "Point","coordinates": '
    j += "[#{point.lon},#{point.lat}"

    if point.elev != nil
      j += ",#{point.elev}"
    end

    j += ']},'
    if name != nil or icon != nil
      j += '"properties": {'
      if name != nil
        j += '"title": "' + name + '"'
      end

      if icon != nil 
        if name != nil
          j += ','
        end
        j += '"icon": "' + icon + '"' 
      end
      j += '}'
    end

    j += "}"
    return j
  end

end

class World

  def initialize(name, features)
    @name = name
    @features = features
  end

  def add_feature(feature)
    @features.append(feature)
  end

  def to_geojson()
    s = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |f,i|
      if i != 0
        s +=","
      end
        if f.class == Track
            s += f.get_track_json
        elsif f.class == Waypoint
            s += f.get_waypoint_json
      end
    end
    s + "]}"
  end

end

def main()
  p = Point.new(-121.5, 45.5, 30)
  w = Waypoint.new(p, "home", "flag")
  p = Point.new(-121.5, 45.6, nil)
  w2 = Waypoint.new(p, "store", "dot")

  ts1 = [
    Point.new(-122, 45),
    Point.new(-122, 46),
    Point.new(-121, 46),
  ]

  ts2 = [ 
    Point.new(-121, 45), 
    Point.new(-121, 46),
   ]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  t = Track.new([ts1, ts2], "track 1")
  t2 = Track.new([ts3], "track 2")

  world = World.new("My Data", [w, w2, t, t2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

