#!/usr/bin/perl

use strict;
use warnings;
use Win32::PowerPoint;

# invoke (or connect to) PowerPoint
my $pp = Win32::PowerPoint->new;

# set presentation-wide information
$pp->new_presentation(
		background_forecolor => [255,255,255],
		background_backcolor => 'RGB(0, 0, 0)',
		pattern => 'Shingle',
		);

# and master footer if you prefer (optional)
$pp->set_master_footer(
		visible         => 1,
		text            => 'My Slides',
		slide_number    => 1,
		datetime        => 1,
		datetime_format => 'MMMMyy',
		);

#(load and parse your slide text)

# do whatever you want to do for each of your slides
foreach my $slide (@slides) {
		$pp->new_slide;

		$pp->add_text($slide->title, { size => 40, bold => 1 });
		$pp->add_text($slide->body);
		$pp->add_text($slide->link,  { link => $slide->link });

# you may add pictures
		$pp->add_picture($file, { left => 10, top => 10 });
	}

$pp->save_presentation('slide.ppt');

$pp->close_presentation;

# PowerPoint closes automatically
