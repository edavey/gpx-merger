class GpxFileMerge
  def initialize(name:, target_doc:, source_path:)
    @target = target_doc
    @source = Nokogiri::XML(File.read(source_path), Encoding::UTF_8.to_s)
    @name = name
  end

  def call
    add_waypoint_for_stage_start
    append_track_points
    # append_any_waypoints
  end

  private

  def add_waypoint_for_stage_start
    waypoint_for_start = <<~XML
    <wpt lat="#{starting_point[:lat]}" lon="#{starting_point[:lon]}">
      <name>#{name}</name>
      <sym>Flag, Orange</sym>
      <type>Stage start</type></wpt>
    XML

    if target.css("wpt").none?
      target.at_css("trk").after(waypoint_for_start)
    else
      target.css("wpt").last.add_next_sibling(waypoint_for_start)
    end
  end

  def append_track_points
    target.at_css("trkseg").add_child(source.css("trkpt"))
  end

  # def append_any_waypoints
  #   target.css("wpt").last.add_next_sibling(source.css("wpt"))
  # end

  def starting_point
    source.at_css("trkpt")
  end

  attr_reader :source, :name
  attr_accessor :target
end
