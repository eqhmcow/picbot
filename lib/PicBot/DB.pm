package PicBot::DB;
use Moose;
use PicBot::DB::Main;

has 'dsn' => (
    is => 'rw',
    isa => 'Str',
    # FIXME
    default => 'dbi:SQLite:dbname=/home/ian/picbot/pics.db',
);

has user => ( is => 'rw', isa => 'Str', default => '' );
has pass => ( is => 'rw', isa => 'Str', default => '' );

has 'schema' => (
    is => 'rw',
    isa => 'PicBot::DB::Main',
    builder => '_schema',
    lazy => 1,
);

sub _schema {
    my ($self) = @_;
    return PicBot::DB::Main->connect($self->dsn, $self->user, $self->pass);
}

sub pdb {
    my ($self) = @_;
    return $self->schema->resultset('Pdb');
}

sub insert {
    my ($self, $who, $what, $channel, $network) = @_;

    my $row = $self->pdb->find_or_create({
        said => $who,
        url => $what,
        channel => $channel,
        network => $network,
        fails => 0,
    });
}

sub fail {
    my ($self, $id) = @_;

    my $pic = $self->pdb->find($id);
    $pic->fails($pic->fails + 1) if defined $pic;
    $pic->update();
}

sub fetchrand {
    my ($self) = @_;
    my $p = $self->pdb->slice(int rand $self->pdb->count)->first();
    return { id => $p->pid, url => $p->url,
             said => $p->said, channel => $p->channel,
             network => $p->network };
}

1
