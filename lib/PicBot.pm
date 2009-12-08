package PicBot;
use strict;
use warnings;

use Robit;
use PicBot::DB;
use LWP::UserAgent::POE;

my $extensions = 'jpe?g|png|p.m|gif|svg|bmp|tiff';
my %last;

sub spawn {
    my ($nick,$pass,$server,@channels) = @_;
    $nick    //= 'picbot';
    $server  //= 'irc.freenode.net';
    $pass    //= '';

    my $r = Robit->new(
        nick => $nick,
        server => $server,
        channels => [ @channels ],
        pass => $pass,
        heap => {
            db => PicBot::DB->new(),
            ua => LWP::UserAgent::POE->new(timeout => 7)
        },
    );

    $r->add_handler('public', \&capture_img);
    $r->add_handler('action', \&capture_img);

    $r->add_handler('addressed', \&source);
    $r->add_handler('addressed', \&fail);

    $r->add_handler('addressed', \&img);
    $r->spawn();
}

# This should be addressed, and be the last on the chain
sub img {
    my ($robit,$what,$where,$who) = @_;
    $last{$where} = $robit->heap->{db}->fetchrand();
    # Quit your whining: if there's no data, crashing is like a feature
    $robit->irc->yield(privmsg => $where => "$who: " . $last{$where}->{url});
    return 1;
}

sub source {
    my ($robit,$what,$where,$who) = @_;
    if ($what =~ /\bsource\b/) {
        $robit->irc->yield(privmsg => $where => "http://github.com/iank/picbot");
        return 1;
    }
}

sub fail {
    my ($robit,$what,$where,$who) = @_;
    if ($what =~ /404/) {
        if (exists $last{$where}) {
            $robit->heap->{db}->fail($last{$where}->{id});
            delete $last{$where};
            $robit->irc->yield(privmsg => $where => "$who: 10-4");
        }
        return 1;
    }
}

sub capture_img {
    my ($robit,$what,$where,$who) = @_;
    my $db = $robit->heap->{db};
    my $ua = $robit->heap->{ua};

    if ($what =~ m!(http://\S+\.(?:$extensions))(?:\s|$)!i) {
        my $url = $1;
        my $r = $ua->head($url);
        if ($r->is_success) {
            print "$url\n";
            $db->insert($who,$url,$where,$robit->server);
            return 1;
        }
    }
}

1
