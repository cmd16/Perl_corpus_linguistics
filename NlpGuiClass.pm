#!/Users/cat/perl
use strict;
use warnings;
use Wx qw(:everything);
use Tokenize;
use FreqDist;  # do i need this too?
use Lingua::EN::Segmenter::TextTiling qw(segments);
use List::MoreUtils;
package NlpGuiClass;
use base qw(Wx::Frame);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->{$file_menu} = Wx::Menu();
    $self->{$setting_menu} = Wx::Menu();
    $self->{$menubar} = undef;
    $self->{$filenames} = ();
    $self->{$text_bodies} = {};

    $self->{$open_file_item} = undef;
    $self->{$open_dir_item} = undef;
    $self->{$open_clipboard_item} = undef;
    $self->{$close_files_item} = undef;
    $self->{$close_text_item} = undef;
    $self->{$close_all_files_item} = undef;
    $self->{$save_item} = undef;
    $self->{$about_item} = undef;

    $self->createFileMenu();

    $self->{$global_settings_item} = undef;
    $self->{$global_settings_frame} = undef;
    $self->{$global_settings_listbook} = undef;

    $self->{$global_settings_file_window} = undef;
    $self->{$global_file_vbox} = undef;
    $self->{$global_show_full_pathname_checkbox} = undef;
    $self->{$global_default_extension_label} = undef;
    $self->{$global_default_extsension_hbox} = undef;
    $self->{$global_save_intermediate_hbox} = undef;
    $self->{$global_save_intermediate_choice} = undef;
    $self->{$global_savePintermediate_txt} = undef;
    $self->{$global_save_intermediate_dirpick_button} = undef;
    $self->{$global_save_intermediate_txtctrl} = undef;
    $self->{$global_file_apply_button} = undef;

    $self->{$show_full_pathname} = 1;
    $self->{$global_default_extension} = ".txt";
    $self->{$global_save_intermediate} = 0;
    $self->{$global_save_intermediate_dir} = "";

    $self{$global_settings_token_window} = undef;
    $self{$global_token_vbox} = undef;
    $self{$global_regex_hbox} = undef;
    $self{$global_regex_statictext} = undef;
    $self{$global_regex_txtctrl} = undef;
    $self{$global_case_sensitive_checkbox} = undef;
    $self{$global_stop_words_hbox} = undef;
    $self{$global_stop_words_statictext} = undef;
    $self{$global_stop_words_txtctrl} = undef;
    $self{$global_stop_words_file_button} = undef;
    $self{$global_token_apply_button} = undef;

    $self{$global_regex} = "[a-zA-Z]+";
    $self{$global_case_sensitive} = 0;
    $self{$global_stop_words} = ();
    $self{$global_stop_words_modified} = 0;

    $self{$tool_settings_item} = undef;
    $self{$tool_settings_frame} = undef;
    $self{$tool_settings_listbook} = undef;

    $self{$tool_settings_wordlist_window} = undef;
    $self{$tool_wordlist_vbox} = undef;
    $self{$tool_wordlist_case_choice} = undef;
    $self{$tool_wordlist_regex_hbox} = undef;
    $self{$tool_wordlist_regex_checkbox} = undef;
    $self{$tool_wordlist_regex_txtctrl} = undef;
    $self{$tool_wordlist_target_corpus_choice} = undef;
    $self{$tool_load_wordlist_hbox} = undef;
    $self{$tool_load_wordlist_button} = undef;
    $self{$tool_wordlist_filename_txtctrl} = undef;
    $self{$tool_wordlist_apply_button} = undef;

    $self{$tool_wordlist_case} = 0;  # in this case means (match whatever global is)
    $self{$tool_wordlist_regex_checkval = 1;  # match whatever global is
    $self{$tool_wordlist_regex} = "";
    $self{$tool_wordlist_target_corpus} = 0; # everything
    $self{$tool_wordlist_wordlists} = ();

    $self{$tool_settings_concordance_window} = undef;
    $self{$tool_concordance_vbox} = undef;
    $self{$tool_concordance_target_corpus_choice} = undef;
    $self{$tool_concordance_displaywindow_hbox} = undef;
    $self{$tool_concordance_displaywindow_txt} = undef;
    $self{$tool_concordance_displaywindow_spinctrl} = undef;
    $self{$tool_concordance_apply_button} = undef;

    $self{$tool_concordance_target_corpus} = 0;  # everything
    $self{$tool_concordance_case} = 0;  # same as global settings
    $self{$tool_concordance_win_length} = 7;

    $self{$tool_settings_ngram_window} = undef;
    $self{$tool_ngram_vbox} = undef;
    $self{$tool_ngram_case_choice} = undef;
    $self{$tool_ngram_regex_hbox} = undef;
    $self{$tool_ngram_regex_vbox} = undef;
    $self{$tool_ngram_regex_checkbox} = undef;
    $self{$tool_ngram_regex_button} = undef;
    $self{$tool_ngram_regex_txtctrl} = undef;
    $self{$tool_ngram_nontoken_hbox} = undef;
    $self{$tool_ngram_nontoken_checkbox} = undef;
    $self{$tool_ngram_nontoken_button} = undef;
    $self{$tool_ngram_nontoken_txtctrl} = undef;
    $self{$tool_ngram_stop_hbox} = undef;
    $self{$tool_ngram_stop_checkbox} = undef;
    $self{$tool_ngram_stop_button} = undef;
    $self{$tool_ngram_stop_txtctrl} = undef;
    $self{$tool_ngram_freq_hbox} = undef;
    $self{$tool_ngram_freq_checkbox} = undef;
    $self{$tool_ngram_freq_spinctrl} = undef;
    $self{$tool_ngram_ufreq_checkbox} = undef;
    $self{$tool_ngram_ufreq_spinctrl} = undef;
    $self{$tool_ngram_newline_checkbox} = undef;
    $self{$tool_ngram_precision_hbox} = undef;
    $self{$tool_ngram_precision_txt} = undef;
    $self{$tool_ngram_precision_spinctrl} = undef;
    $self{$tool_ngram_2d_hbox} = undef;
    $self{$tool_ngram_2d_txt} = undef;
    $self{$tool_ngram_2d_choice} = undef;
    $self{$tool_ngram_3d_hbox} = undef;
    $self{$tool_ngram_3d_txt} = undef;
    $self{$tool_ngram_3d_choice} = undef;
    $self{$tool_ngram_4d_hbox} = undef;
    $self{$tool_ngram_4d_txt} = undef;
    $self{$tool_ngram_4d_choice} = undef;
    $self{$tool_ngram_button} = undef;

    $self{$tool_ngram_case} = 0;
    $self{$tool_ngram_regex_checkval} = 1;  # match whatever global is
    $self{$tool_ngram_regex} = "";
    $self{$tool_ngram_nontoken_checkval} = 1;
    $self{$tool_ngram_nontokens} = ();
    $self{$tool_ngram_stop_checkval} = 1;
    $self{$tool_ngram_stopwords} = ();
    $self{$tool_ngram_freq_checkval} = 0;
    $self{$tool_ngram_freq} = 1;
    $self{$tool_ngram_ufreq_checkval} = 0;
    $self{$tool_ngram_ufreq} = 1;
    $self{$tool_ngram_newline_checkval} = 1;
    $self{$tool_ngram_precision} = 6;

    $self{$ngram_measures_2} = ("CHI phi", "CHI tscore", "CHI squared", "Dice dice", "Dice jaccard", "Fisher left",
                       "Fisher right",
                       "Fisher twotailed", "Mutual information log likelihood",
                       "Mutual information pointwise mutual information", "Mutual information poisson stirling",
                       "Mutual information true mutual information", "Odds");
    $self{$ngram_measures_2_tups} = ();
    # TODO: fix this
    # for measure in $self{$ngram_measures_2:
    #     if measure == "Odds":
    #         $self{$ngram_measures_2_tups.append((measure, "odds.pm"))
    #     elif measure == "CHI squared":
    #         $self{$ngram_measures_2_tups.append((measure, "x2.pm"))
    #     elif not measure.startswith("Mutual"):
    #         if "log" in measure:
    #             $self{$ngram_measures_2_tups.append((measure, "ll.pm"))
    #         elif "pointwise" in measure:
    #             $self{$ngram_measures_2_tups.append((measure, "pmi.pm"))
    #         elif "poisson" in measure:
    #             $self{$ngram_measures_2_tups.append((measure, "ps.pm"))
    #         else:
    #             $self{$ngram_measures_2_tups.append((measure, "tmi.pm"))
    #     else:
    #         $self{$ngram_measures_2_tups.append((measure, measure.split()[1] + ".pm"))
    # TODO: see if this is right
    $self{$tool_ngram_2d_idx} = List::MoreUtils::first_index {$_ eq "Mutual information log likelihood"} $self{$ngram_measures_2};
    $self{$ngram_measures_3} = ("Mutual information log likelihood", "Mutual information pointwise mutual information",
                       "Mutual information poisson stirling", "Mutual information true mutual information");
    $self{$ngram_measures_3_tups} = ();
    # TODO: this thing
    # for measure in $self{$ngram_measures_3:
    #     if "log" in measure:
    #         $self{$ngram_measures_3_tups.append((measure, "ll.pm"))
    #     elif "pointwise" in measure:
    #         $self{$ngram_measures_3_tups.append((measure, "pmi.pm"))
    #     elif "poisson" in measure:
    #         $self{$ngram_measures_3_tups.append((measure, "ps.pm"))
    #     else:
    #         $self{$ngram_measures_3_tups.append((measure, "tmi.pm"))
    $self{$tool_ngram_3d_idx} = {$_ eq "Mutual information log likelihood"} $self{$ngram_measures_3};
    $self{$ngram_measures_4} = ("Mutual information log likelihood");
    $self{$ngram_measures_4_tups} = (($self{$ngram_measures_4[0]}, "ll.pm"));
    $self{$tool_ngram_4d_idx} = 0;

    $self{$tool_settings_keyword_window} = undef;
    $self{$tool_keyword_vbox} = undef;
    $self{$tool_keyword_p_choice} = undef;
    $self{$tool_keyword_reference_choice} = undef;
    $self{$tool_keyword_load_hbox} = undef;
    $self{$tool_keyword_reference_button} = undef;
    $self{$tool_keyword_swap_button} = undef;
    $self{$tool_keyword_reference_txtctrl} = undef;
    $self{$tool_keyword_button} = undef;

    $self{$p_values = (0.05, 0.01, 0.001, 0.0001, 0);
    $self{$tool_keyword_p_choices = ("p = 0.05 (exclude keywords with log likelihood < 3.84)",
                                   "p = 0.01 (exclude keywords with log likelihood < 6.63)",
                                   "p = 0.001 (exclude keywords with log likelihood < 10.83",
                                   "p = 0.0001 (exclude keywords with log likelihood < 15.13",
                                   "include all keywords");
    $self{$tool_keyword_p_idx} = 1;
    $self{$tool_keyword_reference_idx} = 0;
    $self{$tool_keyword_reference_filenames} = ();

    $self{$main_window} = undef;
    $self{$main_listbook} = undef;
    $self{$listbook_idx} = 0;

    $self{$main_wordlist_window} = undef;
    $self{$main_wordlist_vbox} = undef;
    $self{$main_wordlist_info_hbox} = undef;
    $self{$main_wordlist_info_hbox} = undef;
    $self{$main_wordlist_types_txt} = undef;
    $self{$main_wordlist_tokens_txt} = undef;
    $self{$main_wordlist_flexgrid} = undef;
    $self{$main_wordlist_start_hbox} = undef;
    $self{$main_wordlist_start_button} = undef;
    $self{$main_wordlist_page_spinctrl} = undef;
    $self{$main_wordlist_page_button} = undef;
    $self{$main_wordlist_search_txt} = undef;
    $self{$main_wordlist_search_hbox} = undef;
    $self{$main_wordlist_search_term_txt} = undef;
    $self{$main_wordlist_search_exact_checkbox} = undef;
    $self{$main_wordlist_search_case} = undef;
    $self{$main_wordlist_search_regex} = undef;
    $self{$main_wordlist_searchbar_hbox} = undef;
    $self{$main_wordlist_searchbar_txtctrl} = undef;
    $self{$main_wordlist_searchbar_button} = undef;
    $self{$main_wordlist_sort_hbox} = undef;
    $self{$main_wordlist_sort_choice} = undef;
    $self{$main_wordlist_sort_reverse_checkbox} = undef;
    $self{$main_wordlist_sort_button} = undef;

    $self{$freqdist} = undef;
    $self{$wordlist_files_dirty} = 0;  # tracks when a new freqdist needs to be made
    $self{$page_len} = 20;
    $self{$main_wordlist_boxes} = ();
    $self{$freqdist_pages} = ();

    $self{$main_concordance_window} = undef;
    $self{$main_concordance_vbox} = undef;
    $self{$main_concordance_hits_txt} = undef;
    $self{$main_concordance_flexgrid} = undef;
    $self{$main_concordance_page_hbox} = undef;
    $self{$main_concordance_page_spinctrl} = undef;
    $self{$main_concordance_page_button} = undef;
    $self{$main_concordance_search_hbox} = undef;
    $self{$main_concordance_search_term_txt} = undef;
    $self{$main_concordance_search_regex} = undef;
    $self{$main_concordance_search_exact_checkbox} = undef;
    $self{$main_concordance_searchbar_hbox} = undef;
    $self{$main_concordance_searchbar_txtctrl} = undef;
    $self{$main_concordance_searchbar_button} = undef;

    $self{$main_concordance_boxes} = ();
    $self{$concordance_pages} = ();

    $self{$main_ngram_window} = undef;
    $self{$main_ngram_vbox} = undef;
    $self{$main_ngram_info_hbox} = undef;
    $self{$main_ngram_types_txt} = undef;
    $self{$main_ngram_size_txt} = undef;
    $self{$main_ngram_tokens_txt} = undef;
    $self{$main_ngram_search_txt} = undef;
    $self{$main_ngram_search_txt} = undef;
    $self{$main_ngram_flexgrid} = undef;
    $self{$main_ngram_size_spinctrl} = undef;
    $self{$main_ngram_start_hbox} = undef;
    $self{$main_ngram_start_button} = undef;
    $self{$main_ngram_page_spinctrl} = undef;
    $self{$main_ngram_page_button} = undef;
    $self{$main_ngram_search_exact_checkbox} = undef;
    $self{$main_ngram_search_hbox} = undef;
    $self{$main_ngram_search_term_txt} = undef;
    $self{$main_ngram_search_regex} = undef;
    $self{$main_ngram_searchbar_hbox} = undef;
    $self{$main_ngram_searchbar_txtctrl} = undef;
    $self{$main_ngram_searchbar_button} = undef;
    $self{$main_ngram_sort_hbox} = undef;
    $self{$main_ngram_sort_choice} = undef;
    $self{$main_ngram_sort_reverse_checkbox} = undef;
    $self{$main_ngram_sort_button} = undef;

    $self{$ngram_freqdist} = undef;
    $self{$ngram_files_dirty} = 0;
    $self{$main_ngram_boxes} = ();
    $self{$ngram_freqdist_pages} = ();

    $self{$main_keyword_window} = undef;
    $self{$main_keyword_vbox} = undef;
    $self{$main_keyword_info_hbox} = undef;
    $self{$main_keyword_types0_txt} = undef;
    $self{$main_keyword_tokens0_txt} = undef;
    $self{$main_keyword_types1_txt} = undef;
    $self{$main_keyword_tokens1_txt} = undef;
    $self{$main_keyword_search_txt} = undef;
    $self{$main_keyword_flexgrid} = undef;
    $self{$main_keyword_start_hbox} = undef;
    $self{$main_keyword_start_button} = undef;
    $self{$main_keyword_page_spinctrl} = undef;
    $self{$main_keyword_page_button} = undef;
    $self{$main_keyword_search_hbox} = undef;
    $self{$main_keyword_search_term_txt} = undef;
    $self{$main_keyword_search_regex} = undef;
    $self{$main_keyword_search_exact_checkbox} = undef;
    $self{$main_keyword_searchbar_hbox} = undef;
    $self{$main_keyword_searchbar_txtctrl} = undef;
    $self{$main_keyword_searchbar_button} = undef;
    $self{$main_keyword_sort_hbox} = undef;
    $self{$main_keyword_sort_choice} = undef;
    $self{$main_keyword_sort_reverse_checkbox} = undef;
    $self{$main_keyword_sort_button} = undef;

    $self{$keyword_freqdist} = undef;
    $self{$keyword_dict} = undef;
    $self{$keyword_files_dirty} = 0;
    $self{$main_keyword_boxes} = ();
    $self{$keyword_pages} = ();

    $self->createSettingsMenu();
    $self->createMenuBar();

    $self->CreateStatusBar();
    $self->SetStatusText("Corpus linguistics in Python");

    $self->createMainWindow();
}

sub createFileMenu {
    my $self = shift;
}

sub createSettingsMenu {
    my $self = shift;
}

sub createMenuBar {
    my $self = shift;
}

sub open_files {
    my ($self, $event) = @_;
}

sub open_dir {
    my ($self, $event) = @_;
}

sub open_clipboard {
    my ($self, $event) = @_;
}

sub open_text {
    my ($self, $event) = @_;
}

sub close_files {
    my ($self, $event) = @_;
}

sub close_text {
    my ($self, $event) = @_;
}

sub close_everything {
    my ($self, $event) = @_;
}

sub save_results {
    my ($self, $event) = @_;
}

sub openGlobalSettings {
    my ($self, $event) = @_;
}

sub global_save_intermediate_enable {
    my ($self, $event) = @_;
}

sub global_save_intermediate_dirpick {
    my ($self, $event) = @_;
}

sub apply_global_file_settings {
    my ($self, $event) = @_;
}

sub global_token_open_stoplist {
    my ($self, $event) = @_;
}

sub global_token_stop_words_modify {
    my ($self, $event) = @_;
}

sub apply_global_token_settings {
    my ($self, $event) = @_;
}

sub openToolSettings {
    my ($self, $event) = @_;
}

sub tool_wordlist_enable_regex {
    my ($self, $event) = @_;
}

sub tool_wordlist_enable_target_corpus {
    my ($self, $event) = @_;
}

sub tool_wordlist_load_wordlist {
    my ($self, $event) = @_;
}

sub apply_tool_wordlist_settings {
    my ($self, $event) = @_;
}

sub apply_tool_concordance_settings {
    my ($self, $event) = @_;
}

sub tool_ngram_enable_regex {
    my ($self, $event) = @_;
}

sub tool_ngram_open_regex {
    my ($self, $event) = @_;
}

sub tool_ngram_enable_nontoken {
    my ($self, $event) = @_;
}

sub tool_ngram_open_nontoken {
    my ($self, $event) = @_;
}

sub tool_ngram_enable_stop {
    my ($self, $event) = @_;
}

sub tool_ngram_open_stop {
    my ($self, $event) = @_;
}

sub tool_ngram_enable_freq {
    my ($self, $event) = @_;
}

sub tool_ngram_update_freq {
    my ($self, $event) = @_;
}

sub tool_ngram_update_ufreq {
    my ($self, $event) = @_;
}

sub apply_tool_ngram_settings {
    my ($self, $event) = @_;
}

sub tool_keyword_load {
    my ($self, $event) = @_;
}

sub tool_keyword_swap {
    my ($self, $event) = @_;
}

sub apply_tool_keyword_settings {
    my ($self, $event) = @_;
}

sub create_main_window {
    my ($self) = @_;
}

sub main_wordlist_get_wordlist {
    my ($self, $event) = @_;
}

sub main_wordlist_display_wordlist {
    my ($self, $event) = @_;
}

sub main_wordlist_display_page {
    my ($self, $event, $num) = @_;
}

sub main_wordlist_search {
    my ($self, $event) = @_;
}

sub main_concordance_display_page {
    my ($self, $event, $num) = @_;
}

sub main_concordance_search {
    my ($self, $event) = @_;
}

sub main_ngram_get_ngrams {
    my ($self, $event) = @_;
}

sub main_ngram_display_ngram {
    my ($self, $event) = @_;
}

sub main_ngram_display_page {
    my ($self, $event, $num) = @_;
}

sub main_ngram_search {
    my ($self, $event) = @_;
}

sub main_keyword_get_keywords {
    my ($self, $event) = @_;
}

sub main_keyword_display_keyword {
    my ($self, $event) = @_;
}

sub main_keyword_display_page {
    my ($self, $event, $num) = @_;
}

sub main_keyword_search {
    my ($self, $event) = @_;
}
