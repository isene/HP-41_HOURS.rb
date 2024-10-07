#!/usr/bin/env ruby
# encoding: utf-8

require 'getoptlong'

prgmversion = 0.1

def help
puts <<HELPTEXT

NAME
    HP-41CL_HOURS.rb - A tool to update read the HP-41 HOURSF file from
	the program "HOURS" from the HP-41 ISENE ROM 
	(https://github.com/isene/hp-41_isene-rom)

SYNOPSIS
    HP-41CL_HOURS.rb [-fvh] [long-options] [LIFimageFILE]

DESCRIPTION
    Reads and output the content of the HOURSF file residing
	in the LIF image file, "41.lif".

OPTIONS
    -f, --file	
        Specify the lifimage file where HOURSF resides
    -h, --help
    	Show this help text
    -v, --version
        Show the version of HP-41CL_HOURS.rb

COPYRIGHT:
    Copyright 2017, Geir Isene (www.isene.com)
    This program is released under the GNU General Public lisence v2
    For the full lisence text see: http://www.gnu.org/copyleft/gpl.html

HELPTEXT
end

opts = GetoptLong.new(
    [ "--file",		"-f", GetoptLong::NO_ARGUMENT ],
    [ "--help",     "-h", GetoptLong::NO_ARGUMENT ],
    [ "--version",  "-v", GetoptLong::NO_ARGUMENT ]
)

lif_dir  = File.join(File.expand_path(File.dirname(__FILE__)), "roms")
lif_file = File.join(lif_dir, "41.lif")

opts.each do |opt, arg|
  case opt
    when "--file"
			if not ARGV[0]
				puts "No LIF image file specified."
			exit
			end
			lif_file = ARGV[0]
			lif_dir  = File.dirname(lif_file)
    when "--help"
      help
      exit
    when "--version"
			puts "\nHP-41CL_HOURS.rb version: " + prgmversion.to_s + "\n\n"
      exit
  end
end

if not File.exist?(lif_file)
	puts "No such LIF image file:", lif_file
	exit
end

hours = []
h = `lifget #{lif_file} HOURSF | lifraw |liftext`

# Generate the right format for the hours
h = h.split("\n")
h.each do |line|
	line.gsub!(/^12/, (Time.now.year - 1).to_s + '-12')
	line.gsub!(/^([01][0-9])/, (Time.now.year).to_s + '-\1')
	line.sub!(/,/, '-')
	line = line.split(":")
	customer = "\n" + line[2] + ": "
	line.delete_at(2)
	line.insert(0, customer)
	line[1] += ": "
	line[2] += "t "
	line[3].capitalize!
	hours.push(line)
end
hours.sort!
hours[0][0][0] = ''
hours.flatten!
hours = hours.join

# Write hours into hours.txt
File.write(File.join(lif_dir, "hours.txt"), hours)

# Write out hours and end message
puts "OUTPUT:", hours
puts "\nHours written to hours.txt\n\n"

