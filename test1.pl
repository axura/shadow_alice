#!/usr/bin/perl -w

@code = <STDIN>;
%var = ();

%functions = (
	"if" => "if",
	"else" => "else",
	"while" => "while",
	"elif" => "elsif"
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


sub convert {
	my @lines = @_;
	my $index = 0;
	my $multiline_statement = 0;
	my $pre_indlen = 0;
	foreach $line (@lines){
	  $changed = 0;
    chomp($line);
		#initialising the variable table
		while ($line =~ /(\w+)\s*=/ig){
			$variable = $1;
			#$type = $2;
			if (!(defined($var{$variable})) && !(defined($functions{$variable}))){
				$var{$variable} = $variable;
			}
		}

		#read the current indentation
		if ($line =~ /^(\s*)/){
			$curr_indentation = length($1);
			$indentation = $1;
		}

		#comparator change for numerals:
		$line =~ s/<=>/!=/ig;

		#changing the variables
		@words = split(' ', $line);
		foreach $variable (@words){
		#while ($line =~ m/\s+([\w+])\s*/ig || $line =~ m/^([\w+])\s*/ig){
			chomp($variable);
			if (defined($var{$variable})){
				if($line =~ /^(\s*)/){
					$indentation = $1;
				}
				$variable = '$'.$variable;
			}
		}

		$line = join(' ', @words);
		$line = $indentation.$line;

		#checking for range()
		if ($line =~ /range\(([0-9,]*)\)/){
			$range_expr = $1;
			print "$range_expr\n";
		}

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


		if ($line =~ /:\s*$/i){
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
		$pre_indlen = $curr_indentation; 
	

		#check for imported modules like sys. 
		if ($line =~ /import sys/i){
			print "sys module imported\n";			
		}

		#check for str and numerical comparators
		if ($line =~ /(\w+) ([<>=].*?) (\w+)/ig){
    	$arg1 = $1;
    	$comp = $2;
    	$arg2 = $3;
    	if (($arg1 =~ /\d+/) || ($arg2 =~ /\d+/)){
    	  $line =~ s/$comp/$numcmp{$comp}/ig;
    	} elsif (defined($strcmp{$comp})){
    	  $line =~ s/$comp/$strcmp{$comp}/ig;
    	}
  	}

	  if ($line =~ /^#!/){
			$line =~ s/python/perl -w/ig;
	  } elsif (($line =~ /^\s*print\s*"(.*)"\s*$/ || $line =~ /print/i) && !($line =~ /[}{]/)){	
     	$line =~ s/$/,"\\n";/ig;
	  } elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/ || $line =~ /[}{]/){
		  $changed = -1;
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
