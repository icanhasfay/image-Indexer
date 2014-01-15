#Eric Fay
#2/1/11
#This script given a url, obtains all of the images that have alt text definied for them. Then 
#creates an index for each unique word in that alt text. Each entry in the index links to which
#images contain that given word. You can then search for terms in the command line to see if they
#are found in any of the alt texts for the images.

#!/usr/bin/perl
#use strict;
use warnings;
use WWW::Mechanize;
use WWW::Mechanize::Image;

%iindex=();
#change to the webpage you want to crawl
my $some_url = "hxxp://www.examplewebsite.com";
my $mech = WWW::Mechanize->new();
#Getting the url
$mech->get( $some_url );
#Fetching the images from the give URL
my @image_links = $mech->find_all_images();

#Runs through each image_link object
foreach(@image_links){
	#Checks to see if the link is valid and that it has alt text
	next if !defined($_);
	next if !defined($_->alt);

	my $tempLinkObject = $_;
	#The array holds the words from the alt text of the link object(split on spaces)
	my @alt_tokens = split(' ',$tempLinkObject ->alt);
	#for each token in the specific alt text
	foreach(@alt_tokens){
		$absURLOfLink = $tempLinkObject->url_abs;
		#The case in which the word is new to the hash
		if(!exists $iindex{$_}){
			$iindex{$_}= $tempLinkObject->url_abs;
		}
		#The case in which the word has already been seen
		if(exists $iindex{$_} && $iindex{$_}!~/$absURLOfLink/){
			$iindex{$_}= join "\n" , $iindex{$_}, $tempLinkObject->url_abs;
		}
	}


}


#Search
print "Enter the terms that you would like to search for with spaces inbetween each word: \n";
while(<STDIN>){
	$_=~s/^\s+//;
	@queryTerms = split(/\s+/,$_);
	foreach(@queryTerms){
		$currentQueryTerm = $_;
		while ( ($k,$v) = each %iindex) {
			if($k=~m/$currentQueryTerm/i ){
				print "\n";
				print $k ," ", => $v,"\n";
				print "\n";
			}	
		}
	}
}