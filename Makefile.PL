use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Finance::NikkeiQuote',
    'VERSION_FROM'	=> 'NikkeiQuote.pm',
    'PREREQ_PM'		=> {"LWP::UserAgent" => 0,
                            "HTML::TableExtract" => 0,
                           },
);
