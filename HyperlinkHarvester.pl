#!/usr/bin/perl
#HyperlinkHarvester.pl
#@author: Baron Daugherty
#@date: 5/18/2014
use warnings;
use strict;
use LWP::Simple;
use HTML::LinkExtor;

#links we've already seen
my %checked;

#version information
print "Hyperlink Harvester v1.0\n";

#must have one URL as an argument
die "Usage: $0 <URL>\n" unless @ARGV == 1;

#grab the URL and add a "/" at the end unless it exists
my $base = $ARGV[0];
$base .= "/" unless $base =~ m|/$|;

#number of good links and array to hold them
our $num_good = 0;
our @links = ();

#open file to write links to
#open(OUT,"> links.txt") or die "Could not open file to write to";
#select OUT;

#Harvest!
harvest($base);
print("Good links: ", $num_good);

#unset write file
#select STDOUT;
#close(OUT);

#harvest rolls through each page and finds all the links therein
sub harvest{
    my $url = shift;
    
    #break circular links
    return if $checked{$url}++;
    
    #grab the page
    my $page = get($url);
    
    #write the link out if good, else return
    if ($page) {
        print "Link OK: $url\n";
        $num_good++;
    }
    else {return;}
    
    #terminate if external link
    return unless is_internal($url);
    
    #open a new LinkExtor object and parse the page
    my $p = HTML::LinkExtor->new(\&extract_links, $base);
    $p->parse($page);
    
    #recurse
    for my $link(@links){
        harvest($link);
    }
}#end harvest subroutine

sub is_internal{
    my $url = shift;
    return index($url, $base) == 0;
}#end is_internal subroutine

sub extract_links{    
    my ($tag,%attr) = @_;
    for my $value(values %attr){
        push(@links, $value);
    }
}#end extract_links subroutine