#!/usr/bin/perl

my $version='omxscreen master control script $Rev$ $LastChangedDate$';

our $omxplayer='/usr/bin/omxplayer';
#COMMENT THIS OUT TO USE REGULAR MINI-JACK ON PI
our $omxargs='-o hdmi';
our $logfile="/home/omxscreen/omxscreen.log";

our @targetPaths=('/media');
#our @targetPaths=('/media','/home/pi');
#our @targetPaths=('/media/sda1/testvid','/home/pi');

sub iterateDirectory {
my $dir=shift;

my $n=0;
open PIPE,"find \"$dir\" -iname \*.mov -or -iname \*.mp4 -or -iname \*.mkv -or -iname \*.webm | grep -v \.Trashes/ | grep -v /\._ |" or die "Unable to set up search function.\n";

while(<PIPE>){
	++$n;
	chomp;
	my $cmd="\"$omxplayer\" $omxargs \"$_\">> $logfile 2>&1";
	#print "$cmd\n";
	system('/usr/bin/clear');
	system("/bin/echo Going to run $cmd >> $logfile");
	system($cmd);
}
close PIPE;
return $n;
}

#START MAIN

#print "@targetPaths\n";
#sleep(5);
system("/usr/bin/clear");

while(1){
	my $nFiles=0;
	my @pathList=@targetPaths;
	foreach(@pathList){
		#print "@targetPaths\n";
		#sleep(5);
		$nFiles+=iterateDirectory($_);
	}
	#print "@targetPaths\n";
	#sleep(5);
	if($nFiles==0){
		system("clear");
		print "Unable to find any MOV or MP4 files in @targetPaths.\n";
		sleep(10);
	}
}

