#!/opt/local/bin/perl
use strict;
use warnings;
use URI;
use utf8;
use LWP::UserAgent;
use JSON qw(decode_json);
#use Encode qw(encode_utf8);
use Encode ;
use Data::Dumper;

if(@ARGV == 0){
  print "help\n"
}

foreach my $arg (@ARGV){
  my $zipcode = $arg;
  $zipcode =~ s/-//;
  if($zipcode !~ /[0-9]{7}/){
    die "help\n"
  }
  my $uri =
  URI->new('http://zipcloud.ibsnet.co.jp/api/search');
  my $params= {
    zipcode => $zipcode,
  };
  $uri->query_form(%$params);
  my $ua = LWP::UserAgent->new();
  # return type is HTTP:Response
  my $res = $ua->get($uri);
  my $decoded = decode_json($res->content);
  if($res->is_error){
    my $message = $decoded->{'message'};
    die encode("utf-8", $message);
  }
  my $message = $decoded->{'results'};
  if(!$message){
    die "hogehoge";
  }
  &print_address($message);
}


sub print_address{
  my ($message) = @_;
  print "zipcode " . $message->[0]->{'zipcode'} . "\n";
  print encode("utf-8","address " . $message->[0]->{'address1'} . $message->[0]->{'address2'} . $message->[0]->{'address3'} . "\n");
  print encode("utf-8", "kana    " . $message->[0]->{'kana1'} . $message->[0]->{'kana2'} . $message->[0]->{'kana3'} . "\n");

}
