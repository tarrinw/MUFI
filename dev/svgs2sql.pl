#!/bin/perl
# usage (use font ID from MUFI database as first argument, followed by the svg files from the font)
#  perl ../svgs2sql.pl 99 *.svg | mysql -h mysql -u username -p schemaname
#
use strict;
# first argument is font ID (integer)
my $id = shift @ARGV;
# sql in printf format
my $sqlf = q{
INSERT INTO mufi_font_glyph (mufi_font_id,name,codepoint,svg_viewbox,svg_path_d,
	  svg_viewbox_x,svg_viewbox_y,svg_viewbox_w,svg_viewbox_h) 
	VALUES (%d,'%s',%d,'%s','%s',%d,%d,%d,%d);
};
# go through each glyph file
for (@ARGV) {
  open my $fh, '<', $_ or die "Can't open file $!";
  my $file_content = do { local $/; <$fh> };
  close $fh;
  my ($vb) = $file_content =~ /viewBox="([^"]+)/;
  $vb =~ s/\s+/ /g;
  $vb =~ s/^ //;
  $vb =~ s/ $//;
  my ($d)  = $file_content =~ /\sd="([^"]+)/s;
  my ($x, $y, $w, $h) = $vb =~ /^([0-9-]+) ([0-9-]+) ([0-9-]+) ([0-9]+)$/; 
  my ($name, $cp) = /^ffglyph-(.+?)-(\d+)\.svg/;
  printf $sqlf, $id, $name, $cp, $vb, $d, $x, $y, $w, $h;
}
