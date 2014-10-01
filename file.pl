#!/usr/bin/perl

@lines = <>;
%var = ();			#keeps track of variables
%vartype = ();	#keeps track of variable types

%functions = (
	"if" => "if",
	"else" => "else",
	"while" => "while",
	"elif" => "elsif"
);

#need to fix for subset 1, answer3.py
sub convertVar{
		my $check = $line;
    if ($check =~ /(\w+) = ([a-z0-9].*)/cig){
      $variable = $1;
      $type = $2;
      if ($type =~ /\w+/){
        $type = "str";
      } elsif ($type =~ /\d+/) {
        $type = "num";
      }
			
			#printf"hash var\n";
			#foreach $variable (keys %var){
			#	printf "%s\n", $var{$variable};
			#} 
      if (!defined($var{$variable})){
      	$vartype{$variable}= $type;
        $var{$variable} = $variable;
			}
			@words = split(' ', $check);
			foreach $word (@words){
				if (defined($var{$word})){
					$check =~ s/$word/\$$word/cig;
				}
			#$check =~ s/$word/\$$word/cig;
			}
    } else {
      @words = split(' ',$line);
      foreach $word (@words){
        if ($word =~ /(\w+)/cig){
          $word = $1;
          if (defined($var{$word})){
          $check =~ s/$word/\$$word/ig
          }
        }
      }
    }
	return $check;
}

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

		#check for variables	  
    if ($line =~ /(\w+) = ([a-z0-9].*)/cig || $line =~ /(\w+)/ig){
			$word = $1;
			if (!defined($functions{$word})){
    		$line = &convertVar($line);
			}
		}

  }
  return @lines;
}

@lines = &convert(@lines);


foreach $line (@lines){
	print "$line\n";
}

