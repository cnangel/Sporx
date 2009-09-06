#!/usr/bin/perl

# $Id: ftp.pl,v 1.0.0-0 2009/09/04 17:03:39 Cnangel Exp $

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
		"h|host|hostname=s"	=> \$ARGV{host},
		"u|user|username=s"	=> \$ARGV{user},
		"w|pass|password=s"	=> \$ARGV{pass},
		"a|action=i"		=> \$ARGV{action},
		"t|timeout=i"		=> \$ARGV{timeout},
		"p|passive=i"		=> \$ARGV{passive},
		"lf|localfile=s"	=> \$ARGV{localfile},
		"ld|localdir=s"		=> \$ARGV{localdir},
		"rf|remotefile=s"	=> \$ARGV{remotefile},
		"rd|remotedir=s"	=> \$ARGV{remotedir},
		"P|port=i"			=> \$ARGV{port},
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
my $host = $ARGV{'host'} ? $ARGV{'host'} : $conf->lookup_value("ftpapplication.ftphost");
my $user = $ARGV{'user'} ? $ARGV{'user'} : $conf->lookup_value("ftpapplication.ftpuser");
my $pass = $ARGV{'pass'} ? $ARGV{'pass'} : $conf->lookup_value("ftpapplication.ftppass");
my $port = $ARGV{'port'} ? $ARGV{'port'} : $conf->lookup_value("ftpapplication.ftpport");
my $timeout = $ARGV{'timeout'} ? $ARGV{'timeout'} : $conf->lookup_value("ftpapplication.ftptimeout");
my $passive = $ARGV{'passive'} ? $ARGV{'passive'} : $conf->lookup_value("ftpapplication.ftppassive");
my $action = $ARGV{'action'} ? $ARGV{'action'} : $conf->lookup_value("ftpapplication.ftpaction");
my $localfile = $ARGV{'localfile'} ? $ARGV{'localfile'} : $conf->lookup_value("ftpapplication.localfile");
my $localdir = $ARGV{'localdir'} ? $ARGV{'localdir'} : $conf->lookup_value("ftpapplication.localdir");
my $remotefile = $ARGV{'remotefile'} ? $ARGV{'remotefile'} : $conf->lookup_value("ftpapplication.remotefile");
my $remotedir = $ARGV{'remotedir'} ? $ARGV{'remotedir'} : $conf->lookup_value("ftpapplication.remotedir");
my $debug = $ARGV{'debug'} ? $ARGV{'debug'} : $conf->lookup_value("ftpapplication.debugmode");
$port ||= 21;
$timeout ||= 120;
$passive ||= 0;
$action = 1 unless ($action);
my ($ftp, $rfiles, $result) = ('') x 3; 
printf("[ACTION]:%d (%b)\n", $action, $action) if ($debug);
printf("[PASSIVE]:%d\n", $passive) if ($debug);

$ftp = Net::FTP->new (
		Host => $host,
		Port => $port,
		Timeout => $timeout,
		Passive => $passive,
		Debug => $debug,
		) or die "Cannot connect to $host: $@";
$ftp->login($user, $pass) or die "Cannot login ", $ftp->message;
# print Dumper $ftp->ls("/");
$rfiles = eval { $ftp->dir($remotedir) } if (($action & 0x01) == 1);
print Dumper $rfiles;
if ($rfiles && (scalar @$rfiles != 0 || ($action & 0x02) == 0x02)) 
{
	$ftp->cwd($remotedir) or die "Cannot change working directory ", $ftp->message;
	$result .= "cd $remotedir\n";
}
if (($action & 0x04) == 0x04) 
{
	$localdir ? ($ftp->get($remotefile, $localdir) or die "get failed " . $ftp->message)
		: ($ftp->get($remotefile) or die "get failed " . $ftp->message);
	$result .= "Download Successfully!\n";
}
if ($localfile && -f $localfile && ($action & 0x08) == 0x08) 
{
	$ftp->put($localfile) or die "put failed ", $ftp->message;
	$result .= "Upload Successfully!\n";
}
if ($remotefile && ($action & 0x10) == 0x10)
{
	$ftp->delete($remotefile) or die "delete failed ", $ftp->message;
	$rfiles = eval { $ftp->dir($remotedir) };
	print Dumper $rfiles;
	$result .= "Delete Successfully!\n";
}
$result .= 'PWD ' . $ftp->pwd() . "\n" or die "Can't get current path", $ftp->message;
$ftp->quit ();

print $result;

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

ftp.pl - Put Files To FTP Site

=head1 SYNOPSIS

ftp.pl -c <conf>

ftp.pl -c <conf> -h <host> -u <user> -w <password>
	-a <1,2,4,8,...> -lf <localfile> -ld <localdir> 
	-rf <remotefile> -rd <remotedir>

ftp.pl -help

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

Ftp port (defaults to 21).

=item B<-a|--action>

Ftp action which method do, define action as:

    # 0x01 : dir
    # 0x02 : cd
    # 0x04 : get
    # 0x08 : put
	# 0x16 : delete

=item B<-t|--timeout>

Set a timeout value (defaults to 120).

=item B<-p|--passive>

If set to a non-zero value then all data transfers will be done using passive mode. If set to zero then data transfers will be done using active mode. If the machine is connected to the Internet directly, both passive and active mode should work equally well. Behind most firewall and NAT configurations passive mode has a better chance of working. However, in some rare firewall configurations, active mode actually works when passive mode doesn't. Some really old FTP servers might not implement passive transfers. If not specified, then the transfer mode is set by the environment variable FTP_PASSIVE or if that one is not set by the settings done by the libnetcfg utility. If none of these apply then passive mode is used.

=item B<-la|--localaddr>

Local address to use for all socket connections, this argument will be passed to L<IO::Socket::INET>.

=item B<-lf|--localfile>

A local file.

=item B<-ld|--localdir>

A local directory.

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
