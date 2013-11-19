#!/usr/bin/perl

use JSON;
use LWP::Simple;
use Data::Dumper;
use File::Slurp;

my $keydata;
foreach(('/usr/local/share/guardian','/usr/share/guardian','/usr/local/share','/Library/Preferences/Guardian','/Library/Preferences','.')){
	print "Looking for key data in $_...\n";
	eval {
	$keydata=read_file("$_/api.key");
	};
	if($keydata){
		print "Found it\n";
		last;
	}
}
chomp $keydata;

unless($keydata){
	print "Unable to find an api key for the open platform.\n";
	exit 1;
}

my $queryurl='http://content.guardianapis.com/search?tag=music%2Fmusic%2Ctype%2Fvideo%2Ctone%2Fperformances&format=json&show-tags=all&show-elements=all';

#our @target_encodings=('video/mp4:720','video/3gpp:large','video/mp4','mp4');
our @target_encodings=('video/mp4:720','video/mp4','mp4');

our $playerargs='-o hdmi';

sub find_best_encoding {
my $record=shift;

my $result;

foreach(@target_encodings){
	$result=find_encoding($_,$record);
	return $result if($result);
}
return undef;
}

sub find_encoding {
my($targetencoding,$record)=@_;

foreach(@{$record->{'elements'}->[0]->{'assets'}}){
	print Dumper($_);
	if($_->{'type'} eq 'video'){
#		foreach(@{$_->{'encodings'}}){
#			return $_->{'file'} if($_->{'mimeType'} eq $targetencoding);
#		}	
	return $_->{'file'} if($_->{'mimeType'} eq $targetencoding);
	}
}
return undef;
}

#START MAIN
my $pagesize=10;
for(my $page=1;$page<20;++$page){
	print $queryurl."&api-key=$keydata&page=$page&page-size-$pagesize";
	my $jsoncontent=get($queryurl."&api-key=$keydata&page=$page&page-size-$pagesize");
	unless($jsoncontent){
		print "Unable to retrieve from the content api at $queryurl.\n";
		exit 1;
	}

	my $data=from_json($jsoncontent);
#print Dumper($data);
	my $rc;
	foreach(@{$data->{'response'}->{'results'}}){
		#print find_encoding('video/mp4:720',$_);
		my $url=find_best_encoding($_);
		print $url;
		print $_->{'webTitle'}."\n----------------------------\n";
		#print Dumper($_);
		unless($url){
			print "An applicable URL was not found.\n";
			next;
		}
		system("/usr/bin/omxplayer $playerargs \"$url\"");
		$rc=$?;
		print "omxplayer returned $rc\n";
		last if($rc>0 && $rc!=256);
	}
	last if($rc>0);
}
