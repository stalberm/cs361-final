require_relative 'gis.rb'
require 'json'
require 'test/unit'

class TestGis < Test::Unit::TestCase

  def test_waypoints
    p = Point.new(-121.5, 45.5, 30)
    w = Waypoint.new(p, "home", "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(w.get_json)
    assert_equal(result, expected)

    p = Point.new(-121.5, 45.5, nil)
    w = Waypoint.new(p, nil, "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(w.get_json)
    assert_equal(result, expected)

    p = Point.new(-121.5, 45.5, nil)
    w = Waypoint.new(p, "store", nil)
    expected = JSON.parse('{"type": "Feature","properties": {"title": "store"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(w.get_json)
    assert_equal(result, expected)
  end

  def test_tracks
    ts1_points = [
      Point.new(-122, 45),
      Point.new(-122, 46),
      Point.new(-121, 46),
    ]

    ts1 = TrackSegment.new(ts1_points)
    
    ts2_points = [
      Point.new(-121, 45),
      Point.new(-121, 46),
    ]

    ts2 = TrackSegment.new(ts2_points)

    ts3_points = [
      Point.new(-121, 45.5),
      Point.new(-122, 45.5),
    ]
    
    ts3 = TrackSegment.new(ts3_points)

    t = Track.new([ts1, ts2], "track 1")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    result = JSON.parse(t.get_json)
    assert_equal(expected, result)

    t = Track.new([ts3], "track 2")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}')
    result = JSON.parse(t.get_json)
    assert_equal(expected, result)
  end

  def test_world
    p = Point.new(-121.5, 45.5, 30)
    w = Waypoint.new(p, "home", "flag")
    p = Point.new(-121.5, 45.6, nil)
    w2 = Waypoint.new(p, "store", "dot")

    ts1_points = [
      Point.new(-122, 45),
      Point.new(-122, 46),
      Point.new(-121, 46),
    ]
    ts1 = TrackSegment.new(ts1_points)

    ts2_points = [ 
      Point.new(-121, 45), 
      Point.new(-121, 46),
    ]

    ts2 = TrackSegment.new(ts2_points)

    ts3_points = [
      Point.new(-121, 45.5),
      Point.new(-122, 45.5),
    ]
    ts3 = TrackSegment.new(ts3_points)

    t = Track.new([ts1, ts2], "track 1")
    t2 = Track.new([ts3], "track 2")

    w = World.new("My Data", [w, w2, t, t2])

    expected = JSON.parse('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Point","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    result = JSON.parse(w.get_json)
    assert_equal(expected, result)
  end

end
