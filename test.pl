#!/usr/bin/perl -w
#
@code = <STDIN>;
$code[0] =~ s/python/perl -w/ig;

%functions = (
  "if" => "if",
  "else" => "else",
  "while" => "while",
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

sub semicolon{
  my @lines = @_;
  foreach $line (@lines){
    if (!($line =~ /^\s*#/ig)and !($line =~ /^\s*$/ig)){
      $line =~ s/\n/;\n/gi if($line ne $code[0]);
    }
  }
  return @lines;
}

sub checkPrint{
  my @lines = @_;
  foreach $line (@lines){
    if ($line =~ /print/cgi){
      $line =~ s/,/," ",/ig;
      $line =~ s/\n/,"\\n";/ig;
    }
  }
  return @lines;
}

sub convertVar{
  my @lines = @_;
  %var = ();
  foreach $line (@lines){
    if ($line =~ /(\w+) =/cig){
      $variable = $1;
      $var{$variable} = $variable;
      $line =~ s/$variable/\$$variable/ig;
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
  }
  return @lines;
}

#works but need to add it to somewhere where there are string comparators
sub checkcmp{
  my $check = $line;
  if ($check =~ /(\w+) ([<>=].*?) \w+\)/ig){
    #$arg1 = $1
    $comp = $2;
    print "$comp\n";
      $check =~ s/$comp/$strcmp{$comp}/ig;
  }
  print "$check \n";
}

#converts default functions such as while or if
sub defaultFunctions {
  my @lines = @_;
  foreach $line (@lines){
    if ($line =~ /(\w+)/ig){
      $function = $1;
      if (defined($functions{$function})and !(defined($loopfunctions{$function}))){
        $line =~ s/$function/$function(/ig;
        $line =~ s/:/){/ig;
        $line =~ s/;/;}/ig;
      }else {
        if (defined($loopfunctions{$function})){
          $line =~ s/$function/$loopfunctions{$function}/ig;
        }
      }
    }  
  }
  return @lines;
}

@code = &checkPrint(@code);
@code = &semicolon(@code); #convert this at the very last
@code = &convertVar(@code);
@code = &defaultFunctions(@code);

foreach $line (@code){
  print "$line"
}
