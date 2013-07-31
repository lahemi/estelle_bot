#!/usr/bin/awk -f
# Self-contained "fortune" teller, no need for external fortunes file.

BEGIN {
    fortunes =\
"And on the seventh day, God exited append mode.;;\
No beard grows on either the evil or the lazy.;;\
Emacs is good, but with Vim you can wash your clothes.;;\
Plan9 - more Unix than Unix itself.;;\
/sbin over /bin - static is the way to go. ;;\
Tables almighty.;;\
They say evil never sleeps. I sure am getting tired, though.;;\
You can get more with a kind word and a gun than just with a gun. -Not quite Al Capone;;\
IDEs are the new opiatic religion for the masses.;;\
/^[+-]?([0-9]+[.]?[0-9]*|[.][0-9]+)([eE][+-]?[0-9]+)?$/ - numbers, you have been matched!;;\
xp for letters, dwElp for words.;;\
:w<cr>:! chmod 700 %<cr><cr> do them permissions.;;\
:w<cr>:!%:p<cr> IDE, what IDE?;;\
Awk and Lua are the king and queen of scripting.;;\
Blessed be properly used goto!;;\
awk 'NR' == cat ;;\
awk '/pattern/ {print}' == grep;;\
awk 'BEGIN{for(i=1;i<ARGC;i++) printf(ARGV[i] " "); print}' == echo;;\
awk '{if(NR<=n) print; else exit}' n=5 == head -n5 ;;\
Society that would give up a little liberty to gain a little security deserves neither and will lose them both. -Benjamin Franklin;;\
Ever tried, ever failed. No matter. Try again, fail again. Fail better. -Samuel Beckett;;\
You cannot get a simple system by adding simplicity to a complex system."

    # ;; arbitrary "line breaker".
    split(fortunes,farr,";;");
    # Parametreless srand() takes the seed from the current time.
    srand();
    # Increase 100 when the amount of fortunes reaches it.
    r=int((100*rand()) % length(farr));
    printf(farr[r]);
}
