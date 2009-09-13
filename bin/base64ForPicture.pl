#!/usr/bin/perl

# $Id: base64ForPicture.pl,v 1.0.0-0 2009/09/04 17:03:39 Cnangel Exp $

use strict;
use warnings;
use vars qw/$starttime %ARGV/;
BEGIN { $starttime = (times)[0] + (times)[1]; }
END { printf("%d\n", ((times)[0] + (times)[1] - $starttime) * 1000) if ($ARGV{debug}); }
use Getopt::Long qw(:config no_ignore_case);
use Pod::Usage;
# use File::Find;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Conf::Libconfig;
use Net::FTP;

my $man = 0;
my $help = 0;
pod2usage() if (scalar @ARGV == 0); 
GetOptions (
		"c|conf=s"			=> \$ARGV{conf},
		"i|infile=s"		=> \$ARGV{infile},
		"o|outfile=s"		=> \$ARGV{outfile},
		"m|method=i"		=> \$ARGV{method},
		"debug"             => \$ARGV{debug},
		"verbose"           => \$ARGV{verbose},
		'help|?'            => \$help,
		man                 => \$man
		) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;
$ARGV{conf} = "$Bin/../conf/config.cfg" unless ($ARGV && -f $ARGV{conf});

# use vars qw/@files/;
use Data::Dumper;

my ($infile, $outfile, $method) = ('') x 3;
my $conf;
# read config file
if (-f $ARGV{conf})
{
	$conf = Conf::Libconfig->new;
	$conf->read_file($ARGV{'conf'});
	$infile = $ARGV{'infile'} ? $ARGV{'infile'} : $conf->lookup_value("base64application.infile");
	$outfile = $ARGV{'outfile'} ? $ARGV{'outfile'} : $conf->lookup_value("base64application.outfile");
	$method = $ARGV{'method'} ? $ARGV{'method'} : $conf->lookup_value("base64application.method");
}
else 
{
	$infile = $ARGV{'infile'};
	$outfile =  $ARGV{'outfile'};
	$method =  $ARGV{'method'};
}
pod2usage() unless ($outfile ne "" && $infile ne "" && -f $infile);
$method ||= 0;

open my $fp, '<', $infile or die "Can't read the file:$!";
binmode($fp) if ($method == 0);
sysread($fp, my $content, (stat($fp))[7]);
close($fp);
$content = $method == 0 ? Base64encode($content) : Base64decode($content);
print $content if ($ARGV{debug} && $method == 0);
open my $op, '>', $outfile or die "Can't write the file:$!";
binmode($op) if ($method == 1);
print $op $content;
close($fp);


sub Base64encode
{
	my $str = shift;
	my $res = pack("u", $str);
	$res =~ s/^.//mg;
	$res =~ s/\n//g;
	$res =~ tr|` -_|AA-Za-z0-9+/|;
	my $padding = (3 - length($str) % 3) % 3;
	$res =~ s/.{$padding}$/'=' x $padding/e if $padding;
	return $res;
}

sub Base64decode
{
	local($^W) = 0;
	my $str = shift;
	my $res = '';

	$str =~ tr|A-Za-z0-9+/||cd;
	$str =~ tr|A-Za-z0-9+/| -_|;
	while ($str =~ /(.{1,60})/gs)
	{
		my $len = chr(32 + length($1) * 3 / 4);
		$res .= unpack("u", $len . $1 );
	}
	return $res;
}

# sub GetFileFromDir
# {
# 	my $dir = shift;
# 	find(\&wanted, $dir);
# 	return \@files;
# }
# 
# sub wanted
# {
# 	push @files, $File::Find::name if (-f $_);
# }

__END__

=head1 NAME

base64ForPicture.pl - Base64 Code For Picture 

=head1 SYNOPSIS

base64ForPicture.pl -c <conf>

base64ForPicture.pl -i <inFile> -o <outFile> -m <Method>

base64ForPicture.pl -help

=head1 OPTIONS

=over 8

=item B<-c|--conf>

Configuration for the script, default is $PROJECT_HOME/conf.

=item B<-i|--infile>

Input file.

=item B<-o|--outfile>

Output file.

=item B<-m|--method>

Define:

   0 => pic to base64 code
   1 => base64 code to pic

=item B<--debug>

Debug mode, you can see how much time spent in B<this program>.

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do something
useful with the contents thereof, then output result of file(s).

=head1 AUTHOR 

B<Cnangel> (I<junliang.li@alibaba-inc.com>)

=head1 HISTORY

I<2009/09/04 17:03:39> Builded.

=cut
