# GPX Merger

## Purpose

To merge multiple GPX files into a single file, in a single track.

My use case is to take the individual files for a multi-day bike tour and
combine them so that I can view the whole tour visually on a map. I want to do
this in order to reviewing my overall plan. It's not for navigation. My GPX
device does not work well with pausing overnight, so on tour I will use my
individual source files (1 per stage) which I've created on the excellent
[http://cycle.travel](https://cycle.travel) site.

Similarly I've found that some tools including cycle.travel and Komoot can't
cope with the combined file which this script produces: they reject with "file
too large" or "too many GPX points" errors.

However, two services into which I could import the merged GPX are:

- [https://ridewithgps.com](https://ridewithgps.com)
- [https://gps.studio](https://ridewithgps.com)

## Usage

Give the `gpx_file_merge` script the path to a directory containing the GPX files
you wish to merge. They will be merged in alpha-numeric order.

```sh
gpx_file_merge path/to/directory
```

## Dependencies

- **Ruby**: version 3.4.2 is specified in the `mise.toml` file but any recent version
  should work

- **Nokogiri**: for XML manipulation. Unfortunately Nokogiri doesn't seem to
  have good support for outputting the final manipulated document with
  consistent indentation so it's on not very easy to review the output visually.
  But it is machine_readable!

## What it does

### 1. Create file for merged data

`GpxMerger` sets up the target document.

We create an new gpx file to house the merged information. Note that Nokogiri
has 2 distinct modes:

1. `Nokogiri::XML::Builder` which is only used for creating new documents and

2. `Nokogiri::XML::Reader` which is used for reading and manipulating existing
  docs.

If you try to add new nodes to a "builder" object you'll get error messages
complaining that it's not possible to add an additional root node.

When preparing our target gpx document we:

- set a document name to be used for the `track > name` element and for the file
  name when saving to disc.

- set some metadata, including an acknowledgement of cycle.travel

### 2. Merge each gpx file from source dir

`GpxFileMerge` merges a given source GPX into the given target document.

We:

- create a waypoint `<wpt>` to mark the start of each merged file. (Each stage's
  start point.)

- append all the track points `<trkpt>` within `trk > trkseg`

I was intending to include all the waypoints from the source files but I haven't
been able to make those waypoints visually distinct from the waypoints used to
mark the start of each stage. The visualisation tools I tried
(https://ridewithgps.com and https://gps.studio) don't understand the `<sym>Flag,
Blue</sym>` format which is used by https://cycle.travel.
