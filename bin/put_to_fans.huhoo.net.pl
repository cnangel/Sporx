#!/usr/bin/perl

# $Id: put_to_fans.huhoo.net.pl,v 1.0.0-0 2009/09/04 17:03:39 Cnangel Exp $

use strict;
use warnings;
use vars qw/$starttime %ARGV/;
BEGIN { $starttime = (times)[0] + (times)[1]; }
END { printf("%d\n", ((times)[0] + (times)[1] - $starttime) * 1000) if ($ARGV{debug}); }
use Getopt::Long;
use Pod::Usage;
# use File::Find;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Conf::Libconfig;
# use Net::FTP;
use Net::FTP::File;

my $man = 0;
my $help = 0;
pod2usage() if (scalar @ARGV == 0); 
GetOptions (
		"c|conf=s"			=> \$ARGV{conf},
		"h|host|hostname=s"	=> \$ARGV{host},
		"u|user|username=s"	=> \$ARGV{user},
		"w|pass|password=s"	=> \$ARGV{pass},
		"a|action=s"		=> \$ARGV{action},
		"lf|localfile=s"	=> \$ARGV{localfile},
		"ld|localdir=s"		=> \$ARGV{localdir},
		"rf|remotefile=s"	=> \$ARGV{remotefile},
		"rd|remotedir=s"	=> \$ARGV{remotedir},
		"P|port=s"			=> \$ARGV{port},
		"debug"             => \$ARGV{debug},
		"verbose"           => \$ARGV{verbose},
		'help|?'            => \$help,
		man                 => \$man
		) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;
$ARGV{conf} = "$Bin/../conf/config.cfg" unless ($ARGV && -f $ARGV{conf});
pod2usage() unless (-f $ARGV{conf});

# use vars qw/@files/;
use Data::Dumper;

# read config file
my $conf = Conf::Libconfig->new;
$conf->read_file($ARGV{'conf'});

my $ftp = Net::FTP->new (
		$ARGV{'host'},
		Port => ($ARGV{'port'} ? $ARGV{'port'} : 21),
		Debug => 0
		) or die "Cannot connect to $ARGV{'host'}: $@";

$ftp->login($ARGV{'user'}, $ARGV{'pass'}) or die "Cannot login ", $ftp->message;

#print Dumper $ftp->ls("/fans.huhoo.net/perlxs");
print Dumper $ftp->dir("/fans.huhoo.net/perlxs");
#print $ARGV{'remotefile'}, "\n";
$ftp->cwd("/fans.huhoo.net/perlxs") or die "Cannot change working directory ", $ftp->message;
#$ftp->get("perlxs.xul") or die "get failed ", $ftp->message;
$ftp->put($ARGV{'localfile'}) or die "put failed ", $ftp->message if ($ARGV{'localfile'} && -f $ARGV{'localfile'});
print $ftp->pwd(), "\n" or die "Can't get current path", $ftp->message;


#if ($ftp->isfile("perlxs.xul"))
#{
#	print "ok\n";
#}
#else 
#{
#	print "fail\n";
#}


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

put_to_fans.huhoo.net.pl - Put Files To FTP Site

=head1 SYNOPSIS

put_to_fans.huhoo.net.pl -c <conf>

put_to_fans.huhoo.net.pl -c <conf> -h <host> -u <user> -w <password> -a <action> -lf <localfile>

put_to_fans.huhoo.net.pl -help

=head1 OPTIONS

=over 8

=item B<-c|--conf>

Configuration for the script, default is $PROJECT_HOME/conf.

=item B<-h|--host|--hostname>

Ftp hostname.

=item B<-u|--user|--username>

Ftp username.

=item B<-w|--pass|--password>

Ftp password.

=item B<-P|--port>

Ftp port.

=item B<-a|--action>

Ftp action which method do.

=item B<-lf|--localfile>

A local file.

=item B<-ld|--localdir>

A local directory(TODO).

=item B<-rf|--remotefile>

A remote file name if args have remote directory, or else a remote file include path.

=item B<-rd|--remotedir>

A remote directory.

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
