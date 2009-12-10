package PicBot;
use strict;
use warnings;

use Robit;
use PicBot::DB;
use LWP::UserAgent::POE;

use feature ':5.10';

my $extensions = 'jpe?g|png|p.m|gif|svg|bmp|tiff';

sub spawn {
    my ($nick,$server,@channels) = @_;
    die "Need nick/server/etc\n" unless @channels;
    my ($s,$p) = split /:/, $server;
    $p //= 6667;

    my $r = Robit->new(
        nick => $nick,
        server => $s,
        port => $p,
        channels => [ @channels ],
        ignores => [ qr/bot\d*_*$/, 'qq', 'botse', 'Redundant', 'TylerDurden', 'Bit', 'DeepTime', 'Madeline', 'cubert'],
        heap => {
            db => PicBot::DB->new(),
            ua => LWP::UserAgent::POE->new(timeout => 7),
            last => {},
        },
    );

    $r->add_handler('public', \&capture_img);
    $r->add_handler('action', \&capture_img);

    $r->add_handler('addressed', \&source);
    $r->add_handler('addressed', \&fail);

    $r->add_handler('addressed', \&stats);
    $r->add_handler('addressed', \&whosaid);
    $r->add_handler('addressed', \&img); # catchall, must be last
    $r->spawn();
}

sub whosaid {
    my ($robit,$what,$where,$who) = @_;
    my $last = $robit->heap->{last};
    if ($what =~ /^whosaid/) {
        return unless exists $last->{$where};
        $robit->irc->yield(privmsg => $where => "$who: " . $last->{$where}->{said}
            . ' in ' . $last->{$where}->{channel} . ' on ' . $last->{$where}->{network});
        return 1;
    }
}

sub stats {
    my ($robit, $what, $where, $who) = @_;
    if ($what =~ /^stats?/) {
        my $reply = "$who: " . $robit->heap->{db}->pdb->count();
        $robit->irc->yield(privmsg => $where => $reply);
        return 1;
    }
}

# This should be addressed, and be the last on the chain
sub img {
    my ($robit,$what,$where,$who) = @_;
    my $last = $robit->heap->{last};
    $last->{$where} = $robit->heap->{db}->fetchrand();
    # Quit your whining: if there's no data, crashing is like a feature
    $robit->irc->yield(privmsg => $where => "$who: " . $last->{$where}->{url});
    return 1;
}

sub source {
    my ($robit,$what,$where,$who) = @_;
    if ($what =~ /^source/) {
        $robit->irc->yield(privmsg => $where => "http://github.com/iank/picbot");
        return 1;
    }
}

sub fail {
    my ($robit,$what,$where,$who) = @_;
    my $last = $robit->heap->{last};
    if ($what =~ /404/) {
        if (exists $last->{$where}) {
            $robit->heap->{db}->fail($last->{$where}->{id});
            delete $last->{$where};
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
