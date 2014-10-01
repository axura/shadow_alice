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

sub convertVar{
		my $check = $line;
    if ($check =~ /(\w+) = ([a-z0-9].*)/cig){
      $variable = $1;
      $type = $2;
      if ($type =~ /\w+/){
        $type = "str";
      } else {
        $type = "num";
      }
      if (!defined($var{$variable})){
      	$vartype{$variable}= $type;
        $var{$variable} = $variable;
        $check =~ s/$variable/\$$variable/ig;
      }
    } else {
      @words = split(' ',$line);
      foreach $word (@words){
        if ($word =~ /(\w+)/cig){
          $word = $1;
          if (defined($var{$word})){
          $check =~ s/$word/\$$word/ig
          }
        }
      }
    }
	return $check;
}

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
    if ($line =~ /(\w+) = ([a-z0-9].*)/cig || $line =~ /(\w+)/ig){
    	$line = &convertVar($line);
		}

  }
  return @lines;
}

@lines = &convert(@lines);


foreach $line (@lines){
	print "$line\n";
}
=begin comment
 if ($line =~ /(\w+) = ([a-z0-9].*)/cig){
      $variable = $1;
      $type = $2;
      if ($type =~ /\w+/){
        $type = "str";
      } else {
        $type = "num";
      }
      if (!defined($var{$variable})){
      	$vartype{$variable}= $type;
        $var{$variable} = $variable;
        $line =~ s/$variable/\$$variable/ig;
      }
    } else {
      @words = split(' ',$line);
      foreach $word (@words){
        if ($word =~ /(\w+)/cig){
          $word = $1;
          if (defined($var{$word})){
          $line =~ s/$word/\$$word/ig
          }
        }
      }
    }
=end comment


