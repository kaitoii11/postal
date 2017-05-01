package Postal;
use strict;
use warnings;
use URI;
use utf8;
use LWP::UserAgent;
use JSON qw(decode_json);
use Encode;

use Exporter qw(import);
our @EXPORT_OK = qw(get_address);

sub get_address{
  @_ > 0 or die "no arguments passed\n";

  foreach my $arg (@_){
    my $zipcode = $arg;
    $zipcode =~ s/-//;
    if($zipcode !~ /[0-9]{7}/){
      die "malformed postal code " . $zipcode . "\n"
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
    my $result = $decoded->{'results'};

    if($res->is_error){
      my $message = $decoded->{'message'};
      die encode("utf-8", $message);
    } elsif(!$result){
      die "The postal code " . $zipcode  . " does not exist\n";
    } else {
      &print_address($result);
    }
  }
}

sub print_address{
  my ($message) = @_;
  print "zipcode " . $message->[0]->{'zipcode'} . "\n";
  print encode("utf-8","address " . $message->[0]->{'address1'} . $message->[0]->{'address2'} . $message->[0]->{'address3'} . "\n");
  print encode("utf-8", "kana    " . $message->[0]->{'kana1'} . $message->[0]->{'kana2'} . $message->[0]->{'kana3'} . "\n\n");
}
