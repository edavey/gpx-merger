require "pry-byebug"
require "nokogiri"
require_relative "./gpx_merger"

$KCODE = 'UTF8'
usage = "Provide the path to a directory containing gpx files to be combined"

source_dir = ARGV[0]
puts usage unless source_dir && File.exist?(source_dir)

gpx_files = Dir.glob("*.gpx", base: source_dir).sort
puts "No gpx files found in '#{File.absolute_path(source_dir)}'" if gpx_files.none?

GpxMerger.new(gpx_file_paths: gpx_files.map {|f| File.join(source_dir, f)}).call

