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
#print "Content-type: text/plain/selection", "\n\n";
#print "Your $itemA is: $input, right?", "\n";
#print "Your $itemB is: $kind, right?", "\n";
$kind = lc($kind);
use LWP::Simple;
use URI;
my $rel_url = "search/".$kind."/".$input;
my $url = URI->new('http://www.allmusic.com/');
$url->path($rel_url);
#print "The URL is now: $url\n";

$content = LWP::Simple::get($url);
#content handling
@contents = split(/class="search-result artist"/, $content);
my $flag = 0;
my @result_image = {};
my @result_url = {};
my @result_name = {};
my @result_genre = {};
my @result_year = {};
for ($i = 1; $i <= $#contents || $i < 6; $i++) {
	my @contentLine = split(/\n/, $contents[$i]);
	for($j = 0; $j <= $#contentLine; $j++) {
		if($contentLine[$j] =~ /div class=\"cropped-image\"/) {
			$flag = 1;
			next;
		} elsif($contentLine[$j] =~ /div class=\"name\"/) {
			$flag = 2;
			next;
		} elsif($contentLine[$j] =~ /div class=\"info\"/) {
			$flag = 3;
			next;
		}
		
		if($flag == 1) {
	    if ($contentLine[$j] =~ /(http[^\"]*)/) {
	        #print $1." for Image URL\n";
		    $result_image[$i] = $1;
	    }
		$flag = 0;
		
		} 
		if($flag == 2) {
	    if ($contentLine[$j] =~ /(http[^\"]*)/) {
	        #print $1." for URL link\n";
		    #push(@result_url, $1);
		    $result_url[$i] = $1;
		    my @stuff = $contentLine[$j] =~ />([^<]+)</g;
		    #push(@result_name, $1);
		    $result_name[$i] = $stuff[0];
		    #print $stuff[0]." for Name\n";
	    }
		$flag = 0;
		
		} elsif($flag == 3) {
			#print "_".$contents[$i]."_\n";
			if($contentLine[$j] =~ /([A-Za-z].+[A-Za-z])/) {
				#print $1." for Genre\n";
				#push(@result_genre, $1);
				$result_genre[$i] = $1;
			} 
			elsif($contentLine[$j] =~ /(\d+s?)/) {
			    print $1." for year\n";
			    #push(@result_year, $1);
			    $result_year[$i] = $1;
			}
			if($contents[$i] =~ /\/div/) {
			    $flag = 0;
			}
		}

	}
	
}
my $rows = 0;
if(5 > $#contents) {
	$rows = $#contents;
}else {
	$rows = 5;
}

print "Content-Type: text/html\n\n";
my $title = "Search Result";
print header();
print body();

sub header() {

return qq{<HTML>\n<HEAD>\n<title>$title</title></head>};

}

sub body() {

$body = qq{
<BODY>
    <center>
        <p><h2><b>Search Result</b></h2></p>
    </center>
<div align="center">
<P>
<table border="1">
};
$body .= qq{<tr><th>Image</th><th>Name</th><th>Genre(s)</th><th>Years</th><th>Details</th>};
for $i ( 1 .. $rows ) {
$body .= qq{<tr><td>$result_image[$i]</td>};
$body .= qq{<td>$result_name[$i]</td>};
$body .= qq{<td>$result_genre[$i]</td>};
$body .= qq{<td>$result_year[$i]</td>};
$body .= qq{<td>$result_url[$i]</td>};
$body .= qq{</tr>\n};
}

$body .= qq{
</table>
</div>
</BODY>
</HTML>};

return $body;
}


exit(0);