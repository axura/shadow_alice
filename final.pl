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
	my $curr_indent = $indentation;
	if ($line =~ /^([\s]*)(\w+)/i){
			$curr_indlen = length($1);
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

	if ($pre_indentation > $curr_indlen){
			print "$line\n";
			#$lines[$index-1] =~ s/$/\n$indentation}/ig;
			$line =~ s/^/\n$indentation}/ig;
			if ($curr_indlen == 0){
				#print "end of nested loop\n";
				$multiline_statement = 0;
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
	$line = &convertVar($line);
  $line = $indentation.$line;
	if ($line =~ /^(\s*)/){
		$curr_indentation = length($1);
		$indentation = $1;
	}

	print "pre: $pre_indentation curr: $curr_indentation $line\n";

	if (!($line =~ /:[\s]*$/)){
		#if (($line =~ /if\s[\$\w].+:\s\w+/) || ($line =~ /while\s[\$\w].+:\s\w+/)){
		$line = &convertsingle($line);
		$singlestatement = 1;
	} elsif ($line =~ /:/ || $multiline_statement == 1) {
		$line = &convertmult($line);
	}

	$pre_indentation = $curr_indentation;
	$line = &printfunction($line);
	$singlestatement = 0;
	$index += 1;
}

foreach $line (@lines){
		print "$line\n";
}

