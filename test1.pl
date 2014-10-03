#!/usr/bin/perl -w

@code = <STDIN>;
%var = ();

%functions = (
	"if" => "if",
	"elif" => "elsif",
	"else" => "else",
	"while" => "while"
);

%loopfunctions = (
	"break" => "last",
	"continue" => "next",
);

%strcmp = (
  "<>" => "ne",
  "<" => "lt",
  ">" => "gt",
  "<=" => "le",
  ">=" => "ge",
  "==" => "eq",
  "!=" => "ne",
	"<=>"	=> "ne",
);

%numcmp = (
  "<=>" => "!=",
  "<" => "<",
  ">" => ">",
  "==" => "==",
  "<=" => "<=",
  "=>" => "=>",
  "!=" => "!=",
	"=" => "="
);

#other keywords that cannot be used as variables
%other = (
  "print" => "print",
  "for" => "foreach",
  "sys" => "sys",
  "import" => "import",
	"in" => "in",
  "range" => "range",
  "len" => "length"
);

sub convertVar{
	my $check = $line;
	$check =~ s/:/ :/ig;
  $check =~ s/\)/ \) /ig;
  $check =~ s/\(/ \( /ig;
# $check =~ s/[\+\*\/\-]/ [\+\*\/\-] /ig;
  if ($line =~ /^(\s*)/i){
    $indentation = $1;
  }
	my @words = split(' ',$check);
  foreach my $word (@words){
    if (($word =~ /\w+/i) && ($word =~ /^[a-z]/i)){
      if(!defined($functions{$word}) && !defined($loopfunctions{$word}) && !defined($other{$word})){
        $var{$word} = $word;
        $word = '$'.$word;
      }
    }
  }
  $check = join(' ', @words);
  $check = $indentation.$check;
	return $check;
}


sub convert {
	my @lines = @_;
	my $index = 0;
	my $multiline_statement = 0;
	my $pre_indlen = 0;
	foreach $line (@lines){
	  $changed = 0;
    chomp($line);
    
    if ($line =~ /^#!/ig){
      $line =~ s/python/perl -w/;
      next;
    }

		#read the current indentation
		if ($line =~ /^(\s*)/){
			$curr_indentation = length($1);
			$indentation = $1;
		}

		#remove the module
		if ($line =~ /import ([a-z]+)/){
			$line = "";
			my $module = $1;
		}
		if ($line =~ /sys.stdout.write/){
			$module = "sys.stdout";
		} elsif ($line =~ /sys.stdin.readline/){
			$module = "sys.stdin";
		}

    if ($line =~ /len\(/){
        $line =~ s/len\(/length\(/ig;
    }

		#comparator change for numerals:
		$line =~ s/<=>/!=/ig;

		$line = &convertVar($line);
		$line = $indentation.$line;

		#differentiating if and while loops
		#for single line loops only
		if (!($line =~ /:[\s]*$/)){
			if ($line =~ /^([\w]+)\s*/){
				$function = $1;
				if (defined($functions{$function})){
					print "$functions{$function}\n";
					$line =~ s/$function/$function(/ig;					
        	$line =~ s/:\s/){\n\t/ig;
					$line =~ s/\s*$/\n}/ig;
				} elsif (defined($loopfunctions{$function})){
          $line =~ s/$function/$loopfunctions{$function}/ig;
				}
			}
		}

		#checking for multiline
#print "curr: $curr_indentation pre: $pre_indlen\n";
		#case: enters mutliline if/while loop
		if ($pre_indlen < $curr_indentation){
			$multiline_statement = 1;
		}
		#case: still in a multiline loop
		elsif ($pre_indlen > $curr_indentation){
			$line =~ s/^/$indentation}\n/i;
		}

		if ($line =~ /:}*\s*$/i){
			if ($line =~ /^([\s]*)(\w+)/i){
#print "multiline: $line";
				$function = $2;
				$multiline_statement = 1;
				$pre_indlen = length($1);
				if (!($line =~ /else/)){ 
					$line =~ s/$function/$function(/;
					$line =~ s/:\s*$/ ){/i;
				} else {
					$line =~ s/:\s*$/ {/i;
				}
			}
		}
		$pre_indlen = $curr_indentation; #update the indentation

    #check for range() foreach function
    if ($line =~ /for/){
      $line =~ s/for\(/foreach/ig;
      $line =~ s/in //ig;
      $line =~ s/\){/{/ig;
      if ($line =~ /range\(([0-9,\ ]+)\)/ig){
        $range_expr = $1;
        if ($range_expr =~ /([0-9]+)\s*,\s*([0-9]+)/i){
          $min = int($1);
          $max = int($2)-1;
          $line =~ s/$range_expr/$min..$max/i;
          $line =~ s/range//ig;
        } elsif ($range_expr =~ /([0-9]+)/i){
          $max = int($1)-1;
          $line =~ s/$range_expr/0..$max/i;
          $line =~ s/range//ig;
        }
      }
    }

		#check for imported modules like sys. 
		if ($line =~ /import sys/i){
			print "sys module imported\n";			
		}

		#check for str and numerical comparators
		if ($line =~ /(\w+) ([<>=].*?) (\w+)/ig){
    	$arg1 = $1;
    	$comp = $2;
    	$arg2 = $3;
    	if (($arg1 =~ /\d+/) || ($arg2 =~ /\d+/) && defined($numcmp{$comp})){
    	  $line =~ s/$comp/$numcmp{$comp}/ig;
    	} elsif (defined($strcmp{$comp})){
    	  $line =~ s/$comp/$strcmp{$comp}/ig;
    	}
  	}

	  if ($line =~ /^#!/){
			$line =~ s/python/perl -w/ig;
	  } elsif (($line =~ /^\s*print\s*"(.*)"\s*$/ || $line =~ /print/i)){	
			if (!($line =~ /[}{]/i)){ 
     		$line =~ s/$/,"\\n";/ig;
			} else{
				$line =~ s/$/,"\\n";/ig; 
			}
	  } elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/ || $line =~ /[}{]/){
		  $changed = -1;
		} elsif ($module = "sys.stdout"){
#			$temp = $line;
#			$temp =~ s/sys.stdout.write/chomp/ig;
			$line =~ s/[\)\(]//ig;
			$line =~ s/sys.stdout.write/print /ig;
			$line =~ s/\s*$/;/ig;
		} elsif ($module = "sys.stdin"){
			
	  } else{
		  $changed = 1;
		  $line =~ s/$/;/ig;
	  }

		$index += 1; #increment the index tracker
	}
	return @lines;
}

@lines = &convert(@code);

foreach $line (@lines){
	print "$line\n";
}
