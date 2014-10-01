#!/usr/bin/perl -w

@code = <STDIN>;
%var = ();

%functions = (
	"if" => "if",
	"else" => "else",
	"while" => "while",
	"elif" => "elsif"
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
			if ((!defined($var{$variable})) && !(defined($functions{$variable}))){
				print "$variable\n";
				$var{$variable} = $variable;
			}
		}

		#changing the variables
		@words = split(' ', $line);
		foreach $variable (@words){
		#while ($line =~ m/\s+([\w+])\s*/ig || $line =~ m/^([\w+])\s*/ig){
			#my $variable = $1;
			chomp($variable);
			if (defined($var{$variable})){
				print "hello\n";
				if ($line =~ / $variable /ig){
					print "1\n";
					$line =~ s/ $variable / \$$variable /g;
				} elsif ($line =~ /$variable[\w]{1}/ig){
					print "2\n";
					$line =~ s/ $variable / \$$variable/ig;
				} elsif ($line =~ /^$variable\s*=/ig){
					print "3\n";
					$line =~ s/$variable/\$$variable/ig; 
				} else{
					$line =~ s/$variable/\$$variable/ig;
				}
			}
		}


	  if ($line =~ /^#!/){
		$line =~ s/python/perl -w/ig;
	  } elsif ($line =~ /^\s*print\s*"(.*)"\s*$/){
		  	#$variable =~ $1;
      	$line =~ s/$/,"\\n";/ig;
	  } elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/){
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
