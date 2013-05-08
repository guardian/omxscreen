#!/usr/bin/perl

use JSON;
use LWP::Simple;
use Data::Dumper;

my $queryurl='http://content.guardianapis.com/search?tag=music%2Fmusic%2Ctype%2Fvideo%2Ctone%2Fperformances&format=json&show-tags=all&show-media=all&api-key=techdev-internal';

our @target_encodings=('video/mp4:720','video/3gp:large');
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

foreach(@{$record->{'mediaAssets'}}){
	if($_->{'type'} eq 'video'){
		foreach(@{$_->{'encodings'}}){
			return $_->{'file'} if($_->{'format'} eq $targetencoding);
		}	
	}
}
return undef;
}

#START MAIN
my $pagesize=10;
for(my $page=1;$page<100;++$page){
	my $jsoncontent=get($queryurl."&page=$page&page-size=$pagesize");
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
#		print Dumper($_);
		unless($url){
			print "An applicable URL was not found.\n";
			next;
		}
		system("/usr/bin/omxplayer $playerargs \"$url\"");
		$rc=$?;
		print "omxplayer returned $rc\n";
		last if($rc>0);
	}
	last if($rc>0);
}
