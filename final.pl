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
			$line =~ s/\s*$/\n}/ig;
			$line =~ s/;\s*/;\n$indentation\t/ig;
		} elsif (defined($loopfunctions{$function})){
      $line =~ s/$function/$loopfunctions{$function}/ig;
		}
	}
	return $line;
}

sub convertmult{
	my $curr_indent = $indentation;
	if ($line =~ /^([\s]*)(\w+)/i){
#print "multiline: $line";
				$function = $2;
				$multiline_statement = 1;
				$pre_indlen = length($1);
				if (!($line =~ /else/) && !defined($other{$function})){ 
					$line =~ s/$function/$function(/;
					$line =~ s/:\s*$/ ){/i;
				} else {
					$line =~ s/:\s*$/ {/i;
				}
					$line =~ s/\n/;\n/ig;
			}
}

sub printfunction{
	if ($line =~ /^#!/){
		print "case1\n";
		$line =~ s/python/perl -w/ig;
	} elsif($singlestatement == 1) {
		print "case single\n";
		$line =~ s/\n/;\n/ig;
		#$line =~ s/\n/;\n/;
	}	elsif (($line =~ /^\s*print\s*"(.*)"\s*$/ || $line =~ /print/i)){	
		if (!($line =~ /[}{]/i)){ 
			print "case2\n";
     	$line =~ s/$/,"\\n";/ig;
		} else{
			print "case3\n";
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

foreach $line (@lines) {
	chomp ($line);
	$line = &convertVar($line);
  $line = $indentation.$line;
	if ($line =~ /^(\s*)/){
		$pre_indentation = length($1);
		$indentation = $1;
	}

	if (!($line =~ /:[\s]*$/)){
		#if (($line =~ /if\s[\$\w].+:\s\w+/) || ($line =~ /while\s[\$\w].+:\s\w+/)){
		$line = &convertsingle($line);
		$singlestatement = 1;
	} elsif ($line =~ /:/) {
		#$line = &convertmult($line);
	}
	
	$line = &printfunction($line);

}

foreach $line (@lines){
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
