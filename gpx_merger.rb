require_relative "./gpx_file_merge"

class GpxMerger
  def initialize(gpx_file_paths:)
    @file_paths = gpx_file_paths
    @doc_name = name_for_output_file
    @doc = Nokogiri::XML(
      build_doc_for_merged_files.to_xml(encoding: "utf-8"),
      Encoding::UTF_8.to_s
    )
  end

  def call
    print_plan
    merge_files
    save_doc
  end

  private

  def name_for_output_file
    "#{file_paths.count}_merged_gpx_files_#{Time.now.iso8601.split(/\+/).first}.gpx"
  end

  def print_plan
    puts "The following gpx files will be combined in this order:"
    puts
    file_paths.each {|f| puts "  - #{f}"}
  end

  def build_doc_for_merged_files
    Nokogiri::XML::Builder.new do |xml|
      xml.gpx(document_metadata) {
        xml.trk {
          xml.name(doc_name)
          xml.trkseg
        }
      }
    end
  end

  def document_metadata
    {
      version: "1.0",
      name: name_for_output_file,
      description: "A merge of trackpoints and waypoints from #{@file_paths.count} GPX files",
      creator: "based on cycle.travel",
      xmlns: "http://www.topografix.com/GPX/1/0",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "xsi:schemaLocation" => "http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd"
    }
  end

  def save_doc
    puts
    File.write(temp_doc_name, doc.to_xml(indent: 2, encoding: "utf-8"))
    indent_doc
    remove_temp_file
    puts "-> saved file: #{doc_name}"
  end

  def merge_files
    file_paths.each do |path|
      GpxFileMerge.new(
        name: File.basename(path, ".gpx"),
        target_doc: doc,
        source_path: File.expand_path(path)
      ).call
    end
  end

  def temp_doc_name
    "#{doc_name}.tmp"
  end

  attr_reader :file_paths, :doc_name
  attr_accessor :doc

  private def indent_doc
    system "xmllint --format #{temp_doc_name} > #{doc_name}"
  end

  private def remove_temp_file
    File.delete(temp_doc_name)
  end
end
