#!/usr/bin/perl

# Print short summary of LLVM errors for easier deduplication of mass runs.

use strict;
use warnings;

use File::Basename;
use Getopt::Long qw(:config posix_default bundling no_ignore_case);
use Data::Dumper;

# File::Slurp not installed by default...
sub read_file($) {
  my $f = $_[0];
  open FILE, $f or die "Failed to open $f";
  my @lines;
  while(<FILE>) {
    s/[\r\n]+//g;
    push @lines, $_;
  }
  close FILE;
  return @lines if(wantarray);
  return join("\n", @lines);
}

my $verbose = 0;
my $split_code_errors = 0;

sub classify($$) {
  my ($file, $log) = @_;

  # Canonize register names
  $log =~ s/(%[RVW][hl]?)[0-9]+\b/$1/g;
  $log =~ s/(%[DP])[0-9]+\b/$1/g;
  $log =~ s/(%[VW]PR)[0-9]+[_A-Z0-9]*/$1/g;
  $log =~ s/\bvreg[0-9]+/vreg/g;

  # Canonize other noisy parts
  $log =~ s/ uid:[0-9].*//g;
  $log =~ s/ mem:(LD|ST)[0-9].*//g;  # mem:LD32[%3](align=1)
  $log =~ s/tbaa=<0x[0-9a-f]+>/tbaa=<>/g;  # ch = store<ST2[%7](tbaa=<0x15aaf7c4458>)

  my $type;
  my $key = '';
  if($log =~ /error: (.*file not found)/) {
     # some-file.c:4:10: fatal error: 'some-header.h' file not found
    $type = 'code error';
    $key = $1 if $split_code_errors;
  } elsif($log =~ /\.(?:h|hpp|inc|c|C|cpp|cxx):[0-9]+(?::[0-9]+)?: error: (.*)/) {
    # some-header.h:45:27: error: other-header.h: No such file or directory
    $type = 'code error';
    $key = $1 if $split_code_errors;
  } elsif($log =~ /fatal error: error in backend: Cannot select: *(.*)/) {
    # fatal error: error in backend: Cannot select: t130: v2i16 = vselect t172, t255, t258
    $type = 'select';
    $key = $1;
    $key =~ s/\bt[0-9]+/t/g;
    $key =~ s/\bset[a-z][a-z]\b/setXX/g;  # Replace setgt, setne, etc. with "setXX"
    $key =~ s/@[a-zA-Z_][a-zA-Z_.0-9]*/\@GLOB/g;  # Use same name for all globals
  } elsif($log =~ /\*\*\* Bad machine code: (.*)/) {
    # *** Bad machine code: MBB exits via unconditional fall-through
    $type = 'bad ir';
    $key = $1;
  } elsif($log =~ /fatal error: (.*)/) {
    # fatal error: error in backend: ran out of registers during register allocation
    $type = 'assert';
    $key = $1;
  } elsif($log =~ /Assertion failed: *(.*)/) {
    # Assertion failed: I.Value && "No live-in value found", file C:\cygwin64\home\iuriig\src\llvm\lib\CodeGen\LiveRangeCalc.cpp, line 227
    $type = 'assert';
    $key = $1;
  } elsif($log =~ /(UNREACHABLE executed.*)/) {
    # UNREACHABLE executed at XXXInstrInfo.cpp
    $type = 'assert';
    $key = $1;
  } elsif($log =~ /clang frontend command failed due to signal/) {
    # ---> clang.exe: error: clang frontend command failed due to signal (use -v to see invocation)
    $type = 'clang crash';
  } else {
    print STDERR "Unknown error in file $file\n" if $verbose;
    $type = 'other';
  }

  # TODO: simulator, linker, asm errors

  return $type, $key;
}

# Parse options

my $help = 0;
my $file_list;
my $print_files;

GetOptions(
  'help|h'            => \$help,
  'verbose|v+'        => \$verbose,
  'split-code-errors' => \$split_code_errors,
  'file-list'         => \$file_list,
  'print-files|f'     => \$print_files,
);

if($help) {
  my $me = basename($0);
  print <<EOF;
Usage: $me [OPT]... [FILE]...

Print short summary of LLVM errors for easier deduplication of mass runs.
Each FILE must contain a log of LLVM test.

OPT can be one of
  --help, -h            Print this help and exit.
  --verbose, -v         Print diagnostic info
                        (can be specified more than once).
  --split-code-errors   Classify errors in source code.
  --file-list LST       Read FILEs from LST.

Examples:
  \$ perl llvm-classify-error.pl --split-code-errors test10.log
EOF
  exit(0);
}

my @files = @ARGV;
if (defined $file_list) {
  my @ff = read_file($file_list);
  push @files, @ff;
}
unshift @files, '-' unless @files;

# Collect stats

my %errors;
for my $file (@ARGV) {
  my $log = read_file($file);
  my ($type, $key) = classify($file, $log);

  my $hash_key = "$type $key";
  $errors{$hash_key} = { type => $type, key => $key, count => 0, files => [] } if ! exists $errors{$hash_key};
  ++$errors{$hash_key}->{count};
  push @{$errors{$hash_key}->{files}}, $file;

  $errors{total} = { type => 'total', key => '', count => 0, files => [] } if ! exists $errors{total};
  ++$errors{total}->{count};
}

# Print report

my @sorted_errors = sort {$b->{count} <=> $a->{count}} values %errors;
for (@sorted_errors) {
  print "$_->{type}: $_->{key}: $_->{count}\n";
  if ($print_files) {
    print "  $_\n" for @{$_->{files}};
    print "\n";
  }
} 
