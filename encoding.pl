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
$kind =~ s/s$//;
	my @result_image = {};
	my @result_url = {};
	my @result_name = {};
	my @result_comp = {};
	my @result_genre = {};
	my @result_year = {};
	my @result_title = {};
if($kind eq "artist") {
	doArtist();
} elsif($kind eq "album") {
	doAlbum();
} else {
	doSong();
}

sub doArtist() {
 	@contents = split(/class="search-result artist"/, $content);
	my $flag = 0;
	
	for (my $i = 1; $i <= $#contents || $i < 6; $i++) {
		my @contentLine = split(/\n/, $contents[$i]);
		for(my $j = 0; $j <= $#contentLine; $j++) {
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
			    if ($contentLine[$j - 1] =~ /(http[^\"]*)/) {
			        #print $1." for Image URL\n";
				    $result_image[$i] = $1;
			    }
			$flag = 0;
	
			} elsif($flag == 2) {
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
				if($contentLine[$j] =~ /([A-Za-z][^1-9]+[A-Za-z])/) {
					#print $1." for Genre\n";
					#push(@result_genre, $1);
					$result_genre[$i] = $1;
				} 
				elsif($contentLine[$j] =~ /([1-9].*[1-9s])/) {
				    #print $1." for year\n";
				    #push(@result_year, $1);
				    $result_year[$i] = $1;
				}
				if($contentLine[$j + 1] =~ /div/) {
				    $flag = 0;
				}	
			} 	
		}
	}
	printTable();
}

sub doAlbum() {
	@contents = split(/class="search-result album"/, $content);
	my $flag = 0;
	
	for (my $i = 1; $i <= $#contents || $i < 6; $i++) {
		my @contentLine = split(/\n/, $contents[$i]);
		for(my $j = 0; $j <= $#contentLine; $j++) {
			if($contentLine[$j] =~ /div class=\"cropped-image\"/) {
				$flag = 1;
				next;
			} elsif($contentLine[$j] =~ /div class=\"artist\"/) {
				$flag = 2;
				next;
			} elsif($contentLine[$j] =~ /div class=\"info\"/) {
				$flag = 3;
				next;
			} elsif($contentLine[$j] =~ /div class=\"title\"/) {
			    $flag = 4;
				next;
			}
			if($flag == 1) {
			    if ($contentLine[$j - 1] =~ /(http[^\"]*)/) {
			        #print $1." for Image URL\n";
				    $result_image[$i] = $1;
			    }
			$flag = 0;
	
			} elsif($flag == 2) {
		    if ($contentLine[$j] =~ /(http[^\"]*)/) {
		        #print $1." for URL link\n";
			    #push(@result_url, $1);
			    #$result_url[$i] = $1;
			    my @stuff = $contentLine[$j] =~ />([^<]+)</g;
			    #push(@result_name, $1);
			    $result_name[$i] = $stuff[0];
			    #print $stuff[0]." for Artist\n";
		    }
			$flag = 0;
	
			} elsif($flag == 3) {
				#print "_".$contents[$i]."_\n";
				if($contentLine[$j] =~ /([A-Za-z][^1-9]+[A-Za-z])/) {
					#print $1." for Genre\n";
					#push(@result_genre, $1);
					$result_genre[$i] = $1;
				} 
				elsif($contentLine[$j] =~ /([1-9].*[1-9s])/) {
				    #print $1." for year\n";
				    #push(@result_year, $1);
				    $result_year[$i] = $1;
				}
				if($contentLine[$j + 1] =~ /div/) {
				if($contentLine[$j + 1] =~ /([A-Za-z][^1-9]+[A-Za-z])/) {
					#print $1." for Genre\n";
					#push(@result_genre, $1);
					$result_genre[$i] = $1;
				} 
				elsif($contentLine[$j + 1] =~ /([1-9].*[1-9s])/) {
				    #print $1." for year\n";
				    #push(@result_year, $1);
				    $result_year[$i] = $1;
				}
				    $flag = 0;
				}	
			}  elsif($flag == 4) {
			    if ($contentLine[$j] =~ /(http[^\"]*)/) {
			        #print $1." for URL link\n";
				    #push(@result_url, $1);
				    $result_url[$i] = $1;
				    my @stuff = $contentLine[$j] =~ />([^<]+)</g;
				    #push(@result_name, $1);
				    $result_title[$i] = $stuff[0];
				    #print $stuff[0]." for Artist\n";
			    }
				$flag = 0;
	
			}	
		}
	}
	printTable();
}

sub doSong() {
	@contents = split(/class="search-result song"/, $content);
	my $flag = 0;
	
	for (my $i = 1; $i <= $#contents || $i < 6; $i++) {
		my @contentLine = split(/\n/, $contents[$i]);
		for(my $j = 0; $j <= $#contentLine; $j++) {
			if($contentLine[$j] =~ /title=\"play\ssample\"/) {
				$flag = 1;
				next;
			} elsif($contentLine[$j] =~ /div class=\"title\"/) {
				$flag = 2;
				#next;
			} elsif($contentLine[$j] =~ /span class=\"performer\"/) {
				$flag = 3;
				#next;
			} elsif($contentLine[$j] =~ /div class=\"info\"/) {
			    $flag = 4;
				next;
			}
			else {
				
			}
			
			if($flag == 1) {
			    if ($contentLine[$j - 1] =~ /(http[^\"]*)/) {
			        #print $1." for Image URL\n";
				    $result_image[$i] = $1;
				    $flag = 0;
			    }
	
			} elsif($flag == 2) {
		    if ($contentLine[$j+1] =~ /(http[^\"]*)">([^<]+)</) {
		        $contentLine[$j+1] = $';
		        #print "$1\t$2\n";
		        #print $1." for URL link\n";
			    #push(@result_url, $1);
			    $result_url[$i] = $1;
			    #my @stuff = $contentLine[$j] =~ />([^<]+)</g;
			    #push(@result_name, $1);
			    #$result_title[$i] = $stuff[0];
			    $result_title[$i] = $2;
			    #print $stuff[0]." for Artist\n";
			    $flag = 0;
		    }
	
			} elsif($flag == 3) {
			    $result_name[$i] = "";
			    while($contentLine[$j] =~ /http[^\"]*">([^<]+)</) {
			        $result_name[$i] = $result_name[$i]."$1 / ";
			        $contentLine[$j] = $';
			    }
		     	$result_name[$i] =~ s/\s\/\s$//;
		     	#print $result_name[$i]."\n";
		     	$flag = 0;
				#if ($contentLine[$j] =~ /http[^\"]*">([^<]+)</) {
			        #print $1." for URL link\n";
				    #push(@result_url, $1);
				    #$result_url[$i] = $1;
				    #my @stuff = $contentLine[$j] =~ />([^<]+)</g;
				    #push(@result_name, $1);
				    #$result_name[$i] = $result_name[$i].$1;
				    #print $stuff[0]." for Performer\n";
				    #if($contentLine[$j + 1] =~ /span/) {
				    #	$flag = 0;
				    #}	
			   # }
			}  elsif($flag == 4) {
			    $result_comp[$i] = "";
			    while($contentLine[$j] =~ /http[^\"]*">([^<]+)</) {
			        $result_comp[$i] = $result_comp[$i]."$1 / ";
			        $contentLine[$j] = $';
			    }
		     	$result_comp[$i] =~ s/\s\/\s$//;
				$flag = 0;
			}
		}
	}
	printTable();
}

	
sub printTable(){
	my $rows = 0;
	if(5 > $#contents) {
		$rows = $#contents;
	}else {
		$rows = 5;
	}
	for(my $t = 1; $t <= $rows; $t++) {
		if($result_year[$t] eq "") {
			$result_year[$t] .= "NA";
		}
		if($result_url[$t] eq "") {
			$result_url[$t] .= "NA";
		}
		if($result_image[$t] eq "") {
			$result_image[$t] .= "NA";
		}
		if($result_comp[$t] eq "") {
			$result_comp[$t] .= "NA";
		}
		if($result_genre[$t] eq "") {
			$result_genre[$t] .= "NA";
		}
		if($result_year[$t] eq "") {
			$result_year[$t] .= "NA";
		}
		if($result_title[$t] eq "") {
			$result_title[$t] .= "NA";
		}
	}
	$input =~ s/\+/ /;
	print "Content-Type: text/html\n\n";
	my $title = "Search Result";
	
	my $body = qq{<HTML>\n<HEAD>\n<title>$title</title></head>};
	$body .= qq{
				<BODY>
				    <center>
				        <p><h2><b>Search Result</b></h2></p>
				        <p><h3><b>"$input" of type "$kind"</b></h3></p>
				    </center>
				<div align="center">
				<P>
				<table border="1">
				};
	if($rows <= 0) {
		$body .= qq{
					<p><h1><b>No discography found!</b></h1></p>
					</div>
					</BODY>
					</HTML>};
	} else {
		if($kind eq "artist") {
		$body .= qq{<tr><th>Image</th><th>Artist</th><th>Genre(s)</th><th>Year</th><th>Details</th>};
		} elsif ($kind eq "album") {
			$body .= qq{<tr><th>Image</th><th>Title</th><th>Artist</th><th>Genre(s)</th><th>Year</th><th>Details</th>};
		} else {
			$body .= qq{<tr><th>Iink to Song</th><th>Title</th><th>Performer</th><th>Composer</th><th>Details</th>};
		}
		for $i ( 1 .. $rows ) {
		if($kind eq "song") {
			$body .= qq{<tr><td align="middle"><a href="$result_image[$i]">Song Link</a></td>};
		} else {
			$body .= qq{<tr><td align="middle"><img scr="$result_image[$i]" width = "70" height = "70"</td>};
		}
		if($kind eq "album" || $kind eq "song") {
			$body .= qq{<td align="middle">$result_title[$i]</td>};
		}
		$body .= qq{<td align="middle">$result_name[$i]</td>};
		if($kind eq "song") {
			$body .= qq{<td align="middle">$result_comp[$i]</td>};
		} else {
			$body .= qq{<td align="middle">$result_genre[$i]</td>};
			$body .= qq{<td align="middle">$result_year[$i]</td>};
	
		}
		$body .= qq{<td align="middle"><a href="$result_url[$i]">Details</a></td>};
		$body .= qq{</tr>\n};
		}
		
		$body .= qq{
					</table>
					</div>
					</BODY>
					</HTML>};
	}		
	print $body;
}

exit(0);