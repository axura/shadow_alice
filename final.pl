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

%logic = (
  "or" => "or",
  "not" => "not",
  "and" => "and",
	"^" => "xor"
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
	"sys.stdin.read" => "sys.stdin.read",
	"return" => "return",
	"dict" => "dict"
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
  if ($line =~ /^(\s*)/i){
    $indentation = $1;
  }
	if ($line =~ /(\w+)\s*=\s*{/ig){
		$variable = $1;
		if ($line =~ /}\s*$/ && $dict == 0){
			$line =~ s/{\s*/\(\n\t/ig;
			$line =~ s/$variable =/\%$variable =/i;
			$line =~ s/\s*:/ =>/ig;
			$line =~ s/,\s*/,\n\t/ig;
			$line =~ s/}\s*/\n\)/ig;
		} elsif ($dict == 1){
			$line =~ s/\s*:/ =>/ig;
			$line =~ s/,/,\n/ig;
			if ($line =~ /}\s*$/){
				$dict = 0;
			}
		}

		return $line;
	}

	my @words = split(' ',$check);
  foreach my $word (@words){
    if (($word =~ /\w+/i) && ($word =~ /^[a-z]/ig || $word =~ /^["']/) ){
			if ($word =~ /^["']/){
				$quotes = 1;
			} elsif ($word =~ /["']$/){
				$quotes = 0;
				next;
			}
			if (!defined($logic{$word}) && ($quotes == 0)){
      	if(!defined($functions{$word}) && !defined($loopfunctions{$word}) && !defined($other{$word})){
        	$var{$word} = $word;
        	$word = '$'.$word;
      	}
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
				$line =~ s/sys.stdin.read\(\)/<STDIN>/ig;
			} 
		} 
	}
	return $line;
}

sub printfunction{
	if ($line =~ /^#!/){
		$line =~ s/python/perl -w/ig;
	}	elsif (($line =~ /^\s*print\s*"(.*)"\s*$/ || $line =~ /print/i)){	
		if (!($line =~ /[}{]/i)){ 
		 	$line =~ s/$/,"\\n";/ig;
		}
	} elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/ || $line =~ /[}{]/){
		 $changed = -1;
	} else{
		$changed = 1;
		$line =~ s/$/;/ig;
	}
	return $line;
}

@lines = <STDIN>;
$pre_indentation = 0;
$index = 0;
$multiline_statement = 0;
$quotes = 0;
$dict = 0;

foreach $line (@lines) {
	chomp ($line);
	if ($line =~ /import (\w+)/){
		$module = $1;
		$line = "";
	}
	if (defined($module)){
		$line = &checkmodule($line);
	}

	if ($line =~ /^(\s*)/){
		$curr_indentation = length($1);
		$indentation = $1;
		if (!defined($pre_indent)){
			$pre_indent = $indentation;
		}
	}

	if ($line !~ /^\s*#/){
		$line = &convertVar($line);
  	$line = $indentation.$line;
	}

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
	$pre_indent = $indentation;

	if ($pre_indentation > $curr_indentation){
		$lines[$index-1] =~ s/$/$pre_indent}/ig;
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

