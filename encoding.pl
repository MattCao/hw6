#!/usr/usc/bin/perl

$size_of_form_info = $ENV{'CONTENT_LENGTH'};
read(STDIN, $form_info, $size_of_form_info); 
$form_info =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack ("C", hex ($1))/eg;
#s is substitute, \dA-Fa-f looks for hex number and stores it in $1
#pack and hex convert the value in $1 to ASCII, e evaluates second part 
#of the substitute command as an expression, g replaces all occurrences
($search_data, $type_data) = split (/&/, $form_info);
($itemA, $input) = split (/=/, $search_data);
($itemB, $kind) = split (/=/, $type_data);
print "Content-type: text/plain/selection", "\n\n";
print "Your $itemA is: $input, right?", "\n";
print "Your $itemB is: $kind, right?", "\n";
$kind = lc($kind);
use LWP::Simple;
use URI;
my $rel_url = "search/".$kind."/".$input;
my $url = URI->new('http://www.allmusic.com/');
$url->path($rel_url);
print "The URL is now: $url\n";

$content = LWP::Simple::get($url);
#content handling
@contents = split(/\n/, $content);
my $flag = 0;
my @result_url = {};
for ($i = 0; $i <= $#contents; $i++) {
	if($contents[$i] =~ /div class=\"name\"/) {
		$flag = 1;
		next;
	}
	if($flag) {
	    if ($contents[$i] =~ /(http[^\"]*)/) {
	        print $1."\n";
		    push(@result_url, $1);
		    
	    }
		$flag = 0;
		
	}
}
exit(0);