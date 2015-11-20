use strict;
use warnings;

package Mojolicious::Plugin::RedisAdmin::Controller::Public {
    use Mojo::Base 'Mojolicious::Controller';
    use experimental qw/postderef signatures/;

    sub home($self) {
        $self->renderin('public/home');
    }


    sub renderin($self, $template, @args) {
        my %layout = (layout => 'plugin-redis-admin/plugin-redis-admin-default');
        $self->render(%layout, template => join ('/' => ('plugin-redis-admin', $template)), @args);
    }
}

1;


__END__
