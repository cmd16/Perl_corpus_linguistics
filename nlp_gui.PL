#!/Users/cat/perl
use strict;
use warnings;
use Wx qw(:everything);
use Tokenize;
use FreqDist;  # do i need this too?
use Lingua::EN::Segmenter::TextTiling qw(segments);
use NlpGuiClass;

$app = Wx::App->new();
$frame = NlpGuiClass->new(undef, -1, "nlp_gui");
$frame->SetSize(0, 0, 200, 50);
$frame->Show();
$app->MainLoop();
