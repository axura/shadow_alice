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
	$check = $line;
	if ($line =~ /(\w+\s.+:)\s\w+/){
		$condition = $1;
		$condition =~ s/if/if \(/ig;
		$condition =~ s/while/while \(/ig;
		$condition =~ s/:/){\n/ig;
	}
#	$check =~ s/if/if(/i;
#	$check =~ s/while/while(/i;
#	$check =~ s/:/){\n/i;
#	print "singleline: $line\n";
		$operations = $check;
		$operations =~ s/if\s.+://ig;
		$operations =~ s/while\s.+://ig;
		@lines = split(';', $operations);
		foreach $action (@lines){
			#$action =~ s/$/\n/i;
			$action =~ s/^\s*/$indentation\t/i;
		}
		$operations = join("\n", @lines);
		#print "operation: $operations\n";
		$operations = $operations."\n".$indentation."\n}";
		$operations = $condition.$operations;

	return $operations;
}


while ($line = <>) {
	chomp ($line);

	$line = &convertVar($line);
  $line = $indentation.$line;

	if (($line =~ /if\s.+:\s\w+/) || ($line =~ /while\s.+:\s\w+/)){
		print "hello\n";
		$line = &convertsingle($line);
	}

	if ($line =~ /^#!/) {	
		# translate #! line 		
		$line =~ s/python/perl -w/ig;
	} elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
		# Blank & comment lines can be passed unchanged		
		#$change = 0;
	} elsif ($line =~ /\s*print\s*"(.*)"\s*$/ || $line =~ /print/) {
		# Python's print print a new-line character by default
		# so we need to add it explicitly to the Perl print statement
		$line =~ s/\s*$/,"\\n";/ig;
	} else {
		# Lines we can't translate are turned into comments
		$line =~ s/$/;/ig;
	}

	print "$line\n";

}


=begin comment
	if ($line =~ /^#!/) {	
		# translate #! line 		
		print "#!/usr/bin/perl -w\n";
	} elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
		# Blank & comment lines can be passed unchanged		
		print $line;
	} elsif ($line =~ /\s*print\s*"(.*)"\s*$/) {
		# Python's print print a new-line character by default
		# so we need to add it explicitly to the Perl print statement
		
		print "print \"$1\\n\";\n";
	} else {
	
		# Lines we can't translate are turned into comments
		
    print "$line;\n";
	}
}
=end comment
