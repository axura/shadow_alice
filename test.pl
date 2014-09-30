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

%numcmp = (
  "<=>" => "!=",
  "<" => "<",
  ">" => ">",
  "==" => "==",
  "<=" => "<=",
  "=>" => "=>",
  "!=" => "!=",
);

%vartype = ();

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
    if ($line =~ /(\w+) = ([a-z0-9].*?)/cig){
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
  }
  return @lines;
}

#works but need to add it to somewhere where there are string comparators
sub checkcmp{
  my $check = $line;
  if ($check =~ /(\w+) ([<>=].*?) (\w+)/ig){
    $arg1 = $1;
    $comp = $2;
    $arg2 = $3;
    print "$comp\n";
    if (($arg1 =~ /\d+/) || ($arg2 =~ /\d+/)){
      print "redrum\n";
      $check =~ s/$comp/$numcmp{$comp}/ig;
    } else{
      print "test\n";
      $check =~ s/$comp/$strcmp{$comp}/ig;
    }
  }
  print "new comparator: $check \n";
  return $check;
}

#converts default functions such as while or if
sub defaultFunctions {
  my @lines = @_;
  foreach $line (@lines){
    if ($line =~ /(\w+)/ig){
      $function = $1;
      if (defined($functions{$function})and !(defined($loopfunctions{$function}))){
        $line =~ s/;$/;}/ig;
        $line =~ s/$function/$function(/ig;
	$line =~ s/;[\s]*/;\n/ig;
        $line =~ s/:/){\n/ig;
	$line = &checkcmp($line);
      }else {
        if (defined($loopfunctions{$function})){
          $line =~ s/$function/$loopfunctions{$function}/ig;
        }
      }
    }  
  }
  return @lines;
}

#sub sysmodule{
#  my @lines = @_;
#  my $sysChange = 0;
#  foreach $line (@lines){
#    if ($line =~ /import ([a-z]+)/){
#      $module = $1;
#      if ($module =~ /sys/){
#        $sysChange = 1;
#      }
#    } elsif( ($sysChange == 1) and ($line =~ /sys\.stdout\.write\([(a-z0-9].*?)\)/){
#      $var = $1;
#      $line =~ s/sys\.stdout\.write/chomp/ig
#      $line =~ s/\n/\nprint $var,"\n";\n/ig;
#    }
#  }
#}


@code = &checkPrint(@code);
@code = &semicolon(@code); #convert this at the very last
@code = &convertVar(@code);
@code = &defaultFunctions(@code);

foreach $line (@code){
  print "$line"
}
