use Test::More;
use strict;
use warnings;
use Test::Mojo;
use Mojolicious;

my $app = Mojolicious->new;
$app->secrets(['sadfasf']);
$app->plugins->register_plugin('RedisHandler', $app, { helper => 'redis',
        server => 'localhost:6379',
        database => 0,
});
$app->plugins->register_plugin('RedisAdmin', $app, { redis => $app->redis });

isa_ok $app, 'Mojolicious';

done_testing;