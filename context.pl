use Spy;

$\ = "\n";

sub dumpcontext {
	my $c = shift;
	if ($c->kind eq 'loop') {
		print "loop ",
			(defined $c->itercur ? $c->itercur : "undef"),
			" ",
			(defined $c->iternext ? $c->iternext : "undef");
	} else {
               	print $c->kind;
	}
}

sub dumpcontexts {
        my $c = spy_context->prev or return;    # skip myself
        my $s = $c->stack;

        while () {
		dumpcontext $c;
                $c = $c->prev and next;

                print "(", $s->kind, ")";
                $s = $s->prev or return;
                $c = $s->context(-1);
        }
}

for (42..43) { dumpcontext spy_context }
print "";

my @x = (42..43);
for (@x) { dumpcontext spy_context }
print "";

for my $y ("a" .. "b") { dumpcontext spy_context }
print "";

my $y = 2;
while ($y--) { dumpcontext spy_context }
print "";

$SIG{INT} =     # eval context
    sub {       # sub context
        dumpcontexts
    };

{               # loop context (single iteration)
    eval {      # eval context
        sub {   # sub context
            kill INT => $$
        }->()
    };
}

