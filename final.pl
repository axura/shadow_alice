#!/usr/bin/perl -w
#
%var = (); #hash for storing variables

%functions = (
  "if" => "if",
  "elif" => "elsif",
  "else" => "else",
  "while" => "while",
);

%loopfunctions = (
  "break" => "last",
  "continue" => "next",
  );

%other = (
  "print" => "print",
  "for" => "foreach",
  "import" => "import",
  "in" => "in",
  "range" => "range",
  "len" => "length",
	"sys" => "sys",
	"sys.stdout.write" => "sys.stdout.write",
	"sys.stdin.read" => "sys.stdin.read"
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

sub convertsingle{

	if ($line =~ /^([\w]+)\s*/){
		$function = $1;
		if (defined($functions{$function})){
			print "$functions{$function}\n";
			$line =~ s/$function/$function(/ig;					
      $line =~ s/:\s/){\n\t/ig;
			$line =~ s/;\s*/;\n$indentation\t/ig;			
			$line =~ s/\s*$/;\n}/ig;
		} elsif (defined($loopfunctions{$function})){
      $line =~ s/$function/$loopfunctions{$function}/ig;
		}

		@operations = split('\n', $line);
		foreach $op (@operations){
			if ($op =~ /print/){				
				$temp = $op;
				$op =~ s/;/,"\\n";/ig;
				$line =~ s/$temp/$op/ig;
			}
		}
		$line = join("\n",@operations);
		
	}
	return $line;
}

sub convertmult{
	if ($line =~ /^([\s]*)(\w+)/i){
			$function = $2;			
			if ($multiline_statement == 0){
				$multiline_statement = 1;
			}
			if (($line !~ /else/) && !defined($other{$function})){
				$line =~ s/$function/$function(/;
				$line =~ s/:\s*$/ ){/i;				
			} elsif ($line =~ /else/) {
				$line =~ s/:\s*$/ {/i;
			}
	}
	return $line;
}

sub checknumcmp{
	if ($line =~ /(\w+) ([<>=].*?) (\w+)/ig){
    	$arg1 = $1;
    	$comp = $2;
    	$arg2 = $3;
		if (($arg1 =~ /\d+/) || ($arg2 =~ /\d+/) || defined($numcmp{$comp})){
			$line =~ s/$comp/$numcmp{$comp}/ig;
		}
	}
}

sub checkrange{
	print"hello $line\n";
  $line =~ s/for/foreach/ig;
  $line =~ s/in //ig;
  $line =~ s/:;/{/ig;
  if ($line =~ /range\s*(\([0-9,\ ]+\))/ig){
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
	$line =~ s/in//ig;  
	return $line;
}

sub checkmodule{
	if ($module =~ /sys/){
		if ($line =~ /sys.stdout.write/){
			$line =~ s/sys.stdout.write/print /;
			$line =~ s/\)//ig;
			$line =~ s/\(//ig;
		} elsif ($line =~ /sys.stdin.read\(([0-9]*)\)/){
			$i = $1;
			if ($i !~ /\d/){
				$line =~ s/sys.stdin.read()/<STDIN>/ig;
			} 
		}
	}
	return $line;
}

sub printfunction{
	if ($line =~ /^#!/){
		print "case1\n";
		$line =~ s/python/perl -w/ig;
	}	elsif (($line =~ /^\s*print\s*"(.*)"\s*$/ || $line =~ /print/i)){	
		if (!($line =~ /[}{]/i)){ 
			print "case2\n";
     	$line =~ s/$/,"\\n";/ig;
		}
	} elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/ || $line =~ /[}{]/){
		print "case 4\n";	
	  $changed = -1;
	} else{
		print "case 5\n";
		$changed = 1;
		$line =~ s/$/;/ig;
	}
	return $line;
}

@lines = <STDIN>;
$pre_indentation = 0;
$index = 0;
$multiline_statement = 0;
foreach $line (@lines) {
	chomp ($line);
	if ($line =~ /import (\w+)/){
		$module = $1;
		$line = "";
	}
	if (defined($module)){
		$line = &checkmodule($line);
	}

	$line = &convertVar($line);
  $line = $indentation.$line;
	if ($line =~ /^(\s*)/){
		$curr_indentation = length($1);
		$indentation = $1;
	}

	print "pre: $pre_indentation curr: $curr_indentation $line\n";

	if (!($line =~ /:[\s]*$/)){
		$line = &convertsingle($line);
		$singlestatement = 1;
	} elsif ($line =~ /:/ || $multiline_statement == 1) {
		$line = &convertmult($line);
	}
	if ($pre_indentation > $curr_indentation){
		$lines[$index-1] =~ s/$/\n$indentation}/ig;
		if ($curr_indentation == 0){
			$multiline_statement = 0;
		}	 							
	}

	$line =~ s/<=>/!=/ig;

	$pre_indentation = $curr_indentation;
	$line = &printfunction($line);
	$singlestatement = 0;
	$index += 1;

	if ($pre_indentation > $curr_indentation){
		print "$line\n";
		$lines[$index-1] =~ s/$/\n$indentation}/ig;
		if ($curr_indentation == 0){
			$multiline_statement = 0;
		}	 							
	}
	
	if (defined($module) && $module =~ /sys/ && $line =~ /print\s["\$]/){
			$line =~ s/,"\\n"//ig;
	}
	if ($line =~ /for/){
		$line = &checkrange($line);
	}
}

foreach $line (@lines){
		print "$line\n";
}

