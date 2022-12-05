require_relative 'gis.rb'
require 'json'
require 'test/unit'

class TestGis < Test::Unit::TestCase

  def test_waypoints
    coord = Coordinate.new(-121.5, 45.5, 30)
    w = Point.new(coord, "home", "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(w.get_json)
    assert_equal(result, expected)

    coord = Coordinate.new(-121.5, 45.5, nil)
    w = Point.new(coord, nil, "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(w.get_json)
    assert_equal(result, expected)

    coord = Coordinate.new(-121.5, 45.5, nil)
    w = Point.new(coord, "store", nil)
    expected = JSON.parse('{"type": "Feature","properties": {"title": "store"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(w.get_json)
    assert_equal(result, expected)
  end

  def test_tracks
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
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    result = JSON.parse(t.get_json)
    assert_equal(expected, result)

    t = MultiLineString.new([ts3], "track 2")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}')
    result = JSON.parse(t.get_json)
    assert_equal(expected, result)
  end

  def test_world
    coord = Coordinate.new(-121.5, 45.5, 30)
    w = Point.new(coord, "home", "flag")
    coord = Coordinate.new(-121.5, 45.6, nil)
    w2 = Point.new(coord, "store", "dot")

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

    expected = JSON.parse('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Point","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    result = JSON.parse(feature_collection.get_json)
    assert_equal(expected, result)
  end

end
