#!/usr/bin/perl

@lines = <>;

sub convert {
  my @lines = @_;
    
  foreach $line (@lines){
	  $changed = 0;
    	  chomp($line);
	  if ($line =~ /^#!/){
		$line =~ s/python/perl -w/ig;
	  } elsif ($line =~ /^\s*print\s*"(.*)"\s*$/){
		  $variable =~ $1;
      		  $line =~ s/$/,"\\n";/ig;
	  } elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/){
		  $changed = -1;
	  } else{
		  $changed = 1;
		  $line =~ s/$/;/ig;
	  }
    print "$line\n";
  }
  return @lines;
}

@lines = &convert(@lines);
