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

#converts the variables
sub convertVariables{
  my @lines = @_;
  foreach $line (@lines){
    if($line =~ /([a-z_0-9]).*? =/){
      $line =~ s/^/\$/gi;
    }
    elsif($line =~ /print/ig) {
        if ($line =~ /([a-z_0-9].*?)/cig){        
          $variable = $1;
          $line =~ s/$variable/\$$variable/gi;
        }
      }
    }
  return @lines;
}

@code = &checkPrint(@code);
@code = &semicolon(@code); #convert this at the very last
@code = &convertVariables(@code);



foreach $line (@code){
  print "$line"
}

