#!/usr/bin/perl

my $version='omxscreen master control script $Rev$ $LastChangedDate$';

our $omxplayer='/usr/bin/omxplayer';
#COMMENT THIS OUT TO USE REGULAR MINI-JACK ON PI
our $omxargs='-o hdmi';
our $logfile="/home/pi/omxscreen.log";

out @targetPaths=('/media','/home/pi');

sub iterateDirectory {
my $dir=shift;

my $n=0;
open $pipe,"find \"$dir\" -iname \*.mov -or -iname \*.mp4 -or -iname \*.mkv -or -iname \*.webm | grep -v \.Trashes/ | grep -v /\._ |" or die "Unable to set up search function.\n";

while(<$pipe>){
	++$n;
	chomp;
	my $cmd="\"$omxplayer\" $omxargs > $logfile 2>&1";
	print "$cmd\n";
	system("echo Going to run $cmd >> $logfile");
	system($cmd);
}
close $pipe;
return $n;
}

#START MAIN

while(1){
	my $nFiles=0;
	foreach(@targetPaths){
		$nFiles+=iterateDirectory($_);
	}
	if($nFiles==0){
		system("clear");
		print "Unable to find any MOV or MP4 files in @targetPaths.\n";
		sleep(10);
	}
}

