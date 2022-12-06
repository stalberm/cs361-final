require_relative 'gis.rb'
require 'json'
require 'test/unit'

class TestGis < Test::Unit::TestCase

  def test_full_point
    coord = Coordinate.new(-121.5, 45.5, 30)
    point = Point.new(coord, "home", "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(point.get_json)
    assert_equal(result, expected)
  end

  def test_point_missing_elev
    coord = Coordinate.new(-121.5, 45.5, nil)
    point = Point.new(coord, "home", "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(point.get_json)
    assert_equal(result, expected)
  end

  def test_point_missing_name
    coord = Coordinate.new(-121.5, 45.5, 30)
    point = Point.new(coord, nil, "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(point.get_json)
    assert_equal(result, expected)
  end

  def test_point_missing_icon
    coord = Coordinate.new(-121.5, 45.5, 30)
    point = Point.new(coord, "home")
    expected = JSON.parse('{"type": "Feature","properties": {"title": "home"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(point.get_json)
    assert_equal(result, expected)
  end

  def test_point_missing_name_and_icon
    coord = Coordinate.new(-121.5, 45.5, 30)
    point = Point.new(coord)
    expected = JSON.parse('{"type": "Feature","properties": {},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(point.get_json)
    assert_equal(result, expected)
  end

  def test_multilinestring_multiple_linestrings

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

    mls = MultiLineString.new([ls1, ls2], "track 1")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    result = JSON.parse(mls.get_json)
    assert_equal(expected, result)
  end

  def test_multilinestring_one_linestring

    ls_coords = [
      Coordinate.new(-122, 45),
      Coordinate.new(-122, 46),
      Coordinate.new(-121, 46),
    ]
    ls1 = LineString.new(ls_coords)

    mls = MultiLineString.new([ls1], "track 1")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]]]}}')
    result = JSON.parse(mls.get_json)
    assert_equal(expected, result)
  end
 
  def test_multilinestring_missing_name

    ls_coords = [
      Coordinate.new(-122, 45),
      Coordinate.new(-122, 46),
      Coordinate.new(-121, 46),
    ]
    ls1 = LineString.new(ls_coords)

    mls = MultiLineString.new([ls1])
    expected = JSON.parse('{"type": "Feature", "properties": {},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]]]}}')
    result = JSON.parse(mls.get_json)
    assert_equal(expected, result)
  end

  def test_world
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

    expected = JSON.parse('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Point","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    result = JSON.parse(feature_collection.get_json)
    assert_equal(expected, result)
  end

end
