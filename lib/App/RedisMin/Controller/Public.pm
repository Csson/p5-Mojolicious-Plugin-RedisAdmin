use strict;
use warnings;

package App::RedisMin::Controller::Public {
    use Mojo::Base 'Mojolicious::Controller';
    use experimental qw/postderef signatures/;

    sub home($self) {
        $self->render;
    }

}

1;


__END__
