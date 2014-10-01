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
  "!=" => "ne"
);

%numcmp = (
  "<=>" => "!=",
  "<" => "<",
  ">" => ">",
  "==" => "==",
  "<=" => "<=",
  "=>" => "=>",
  "!=" => "!=",
	'=' => '='
);


sub convert {
	my @lines = @_;
	foreach $line (@lines){
	  $changed = 0;
    chomp($line);
		#initialising the variable table
		while ($line =~ /(\w+)\s*=/ig){
			$variable = $1;
			#$type = $2;
			if (!(defined($var{$variable})) && !(defined($functions{$variable}))){
				$var{$variable} = $variable;
				print "$var{$variable}\n";
			}
		}

		#comparator change for numerals:
		$line =~ s/<=>/!=/ig;

		#changing the variables
		@words = split(' ', $line);
		foreach $variable (@words){
		#while ($line =~ m/\s+([\w+])\s*/ig || $line =~ m/^([\w+])\s*/ig){
			#my $variable = $1;
			chomp($variable);
			if (defined($var{$variable})){
				if ($line =~ /\s$variable\s{1}/i){
				#	print "1\n";
					$line =~ s/ $variable / \$$variable /;
				} elsif ($line =~ /$variable[\w]{1}/i){
				#	print "2\n";
					$line =~ s/ $variable / \$$variable/i;
				} elsif (($line =~ /^$variable\s*=/i) && !($variable =~ /\$/i)){
				#	print "3\n";
					$line =~ s/$variable/\$$variable/i; 
				} else{
					$line =~ s/$variable/\$$variable/i;
				}
			}
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
				}
			}
		}else {
        if (defined($loopfunctions{$function})){
          $line =~ s/$function/$loopfunctions{$function}/ig;
				}
     }

		#check for str and numerical comparators
		if ($line =~ /(\w+) ([<>=].*?) (\w+)/ig){
    	$arg1 = $1;
    	$comp = $2;
    	$arg2 = $3;
    	if (($arg1 =~ /\d+/) || ($arg2 =~ /\d+/)){
    	  $line =~ s/$comp/$numcmp{$comp}/ig;
    	} else{
    	  $line =~ s/$comp/$strcmp{$comp}/ig;
    	}
  	}

	  if ($line =~ /^#!/){
		$line =~ s/python/perl -w/ig;
	  } elsif ($line =~ /^\s*print\s*"(.*)"\s*$/){
		  	#$variable =~ $1;
      	$line =~ s/$/,"\\n";/ig;
	  } elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/ || $line =~ /\s*}\s*/){
		  $changed = -1;
	  } else{
		  $changed = 1;
		  $line =~ s/$/;/ig;
	  }
	}
	return @lines;
}

@lines = &convert(@code);

foreach $line (@lines){
	print "$line\n";
}
