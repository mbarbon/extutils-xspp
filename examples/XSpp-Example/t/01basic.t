use strict;
use warnings;

use Test::More tests => 18;
use XSpp::Example;

$| = 1; # autoflush

my $dog = Dog->new("Skip");
isa_ok($dog, 'Dog');
isa_ok($dog, 'Animal');

can_ok($dog, 'Bark');
can_ok($dog, 'MakeSound');
can_ok($dog, 'GetName');
can_ok($dog, 'SetName');

is($dog->GetName(), "Skip");

$dog->SetName("Brutus");
is($dog->GetName(), "Brutus");

my $animal = Animal->new("Tweety");
isa_ok($animal, 'Animal');
ok(!$animal->isa('Dog'), "Animal isn't a dog");

can_ok($animal, 'GetName');
can_ok($animal, 'SetName');
can_ok($animal, 'MakeSound');
ok(!$animal->can('Bark'));

eval { $animal->MakeSound() };
my $exception = $@;
ok($exception && $exception =~ /does not make sound/);

my $clone = $dog->Clone();
isa_ok($clone, 'Dog');
isa_ok($clone, 'Animal');
is($clone->GetName(), $dog->GetName());

print "# "; # comment the bark output
Dog::MakeDogBark($clone);

