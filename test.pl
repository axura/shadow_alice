#!/usr/bin/perl -w
#
@code = <STDIN>;
$code[0] =~ s/python/perl -w/ig;

#%function = {
#  "print" => "print",
#  "if" => "if",
#  "else" => "else",
#  "while" => "while",
#};

sub semicolon{
  my @lines = @_;
  foreach $line (@lines){
    $line =~ s/\n/;\n/gi if ($line ne "\n")&&($line ne $code[0]);
  }
  return @lines;
}

sub checkPrint{
  my @lines = @_;
  foreach $line (@lines){
    if ($line =~ /print/cgi){
      $line =~ s/,/," ",/ig;
      $line =~ s/\n/,"\\n"/ig;
    }
  }
  return @lines;
}

sub convertVar{
  @lines = @_;
  my %var = ();
  foreach $line (@lines){
    if ($line =~ /(\w+) =/cig){
      $variable = $1;
      print "$1\n";
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

@code = &checkPrint(@code);
@code = &semicolon(@code); #convert this at the very last
@code = &convertVar(@code);

foreach $line (@code){
  print "$line"
}
