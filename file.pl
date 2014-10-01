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
	  if ($line =~ /(\w+) = ([a-z0-9].*)/cig){
			if(!defined($functions{$1})){
				$variable = $1;
				$type = $2;
				if (!defined($var{$variable})){
					$var{$variable} = $variable;
					$vartype{$variable} = $type;
				}
				$line =~ s/$variable/\$$variable/ig;
			}
		} else {
			@words = split(' ', $line);
			foreach $word (@words){
				if ($word =~ /(\w+)/cig){
					$word = $1;
					if (!defined($functions{$word}) && !($line =~ /print/ig)){
						$line =~ s/$word/\$$word/ig;
					}
				}
			}
		}
    print "$line\n";
  }
  return @lines;
}

@lines = &convert(@lines);


