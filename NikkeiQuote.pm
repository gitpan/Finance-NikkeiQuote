package Finance::NikkeiQuote;
use strict;
use Carp;
use LWP::UserAgent;
use HTML::TableExtract;

use vars qw($todayUrl $infoUrl $range25Url $VERSION);

$todayUrl = 
  'http://marketsearch.nikkei.co.jp/stock/result.cfm?scode=*SCODE*';
$infoUrl =
  'http://marketsearch.nikkei.co.jp/cdb/compinfo.cfm?scode=*SCODE*';
$range25Url =
  'http://marketsearch.nikkei.co.jp/cdb/mprice.cfm?scode=*SCODE*';
$VERSION = '0.5.1';

sub new
{
  my $class = shift;
  my $scode = shift or croak "scode not specified";
  my $ua    = new LWP::UserAgent;
  $ua->agent("Finance::NikkeiQuote/$VERSION");
  my $self = {
    SCODE => $scode,
    UA    => $ua,
  };
  return bless $self, $class;
}

sub proxy
{
  my $self = shift;
  my $proxy = shift or croak "proxy not specified";
  $self->{UA}->proxy('http',$proxy);
  return $self;
}

sub _gethtml
{
  my $self = shift;
  my $url  = shift;
  my $res;
  $res = $self->{UA}->request(
    HTTP::Request->new(GET => $url));
  croak $res->status_line if ($res->is_error);
  return $res->content;
}

sub gettoday
{
  my $self = shift;
  my ($url,$html,$te,$ts,@ret);
  $url = $todayUrl;
  $url =~ s/\*SCODE\*/$self->{SCODE}/e;
  $html = $self->_gethtml($url);
  $te = new HTML::TableExtract(depth => 2);
  $te->parse($html);
  $ts = ($te->table_states)[1];
  @ret = (@{($ts->rows)[1]})[0,1,2,3,5];
  map{m/([\d,-]+)/; my $tmp = $1; $tmp =~ s/,//g; $_ = $tmp}@ret;
  return wantarray ? @ret : \@ret;
}

sub getinfo
{
  my $self = shift;
  my ($url,$html,$te,$ts,@ret);
  $url = $infoUrl;
  $url =~ s/\*SCODE\*/$self->{SCODE}/e;
  $html = $self->_gethtml($url);
  $te = new HTML::TableExtract(depth => 1);
  $te->parse($html);
  $ts = ($te->table_states)[12];
  @ret = (@{($ts->rows)[0]}[1],@{($ts->rows)[1]}[1]);
  @ret = map{s/^\s+//; s/\s+$//; $_}@ret;
  return wantarray ? @ret : \@ret;
}

sub getrange25
{
  my $self = shift;
  my ($url,$html,$te,$ts,@ret);
  $url = $range25Url;
  $url =~ s/\*SCODE\*/$self->{SCODE}/e;
  $html = $self->_gethtml($url);
  $te = new HTML::TableExtract(depth => 1);
  $te->parse($html);
  $ts = ($te->table_states)[20];
  for (0..25){
    $ret[$_] = [map{
                 s/\s+//g;
                 s/,//g;
                 $_;
               }@{($ts->rows)[$_]}];
  }
  shift @ret;
  return wantarray ? @ret : \@ret;
}
1;

__END__

=head1 NAME

Fiance::NikkeiQuote - Get a stock quote from Nihon Keizai
Shimbun, Inc. (Nikkei)

=head1 SYNOPSIS

     use Finance::NikkeiQuote;
     # For example, it's a sony ;-)
     my $sony = Finance::NikkeiQuote->new(6758);
     # Set proxy, if you need
     $sony->proxy('http://proxy.foo.co.jp:8080');
     print "Name         : ",($sony->getinfo)[1],"\n";
     print "Current Price: ",($sony->gettoday)[3],"\n";
     # 25days Range of stock prices;
     map{map{print $_,','}@$_;print "\n"}@{$sony->getrange25};

=head1 DESCRIPTION

This module gets stock quote from Nikkei. The B<new> constructor
will return a Finance::NikkeiQuote object, while the B<proxy>
method to use proxy server. The return value of B<getinfo>
method is an array, with the following elements:

   0 company name in Japanese
   1 company name in English

The return value of B<gettoday> method is an array, with
the following elements:

   0 Open Price
   1 High Price
   2 Low Price
   3 Current Price
   4 Volume

The B<getrange25> method returns an array of pointers to
arryas with the following elements:

   0 Date
   1 Open Price
   2 High Price
   3 Low Price
   4 Close Price
   5 Volume

=head1 COPYRIGHT

Copyright (c) 2001 Keiichi Daiba. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

The information that you obtain with this library may be
copyrighted by Nihon Keizai Shimbun, Inc., and is governed by
their usage license. See http://www.nikkei.co.jp/help/copy.html
for more information.

=head1 AUTHOR

Keiichi Daiba (C<keiichi@tokyo.pm.org>) Tokyo Perl Monger.

=head1 SEE ALDSO

L<LWP::UserAgent>, L<HTML::TableExtract>

=cut
