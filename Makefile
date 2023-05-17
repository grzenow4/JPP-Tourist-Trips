SICSTUSHOME=/opt/sicstus
SICSTUSBIN= $(SICSTUSHOME)/bin
PL = $(SICSTUSBIN)/sicstus
SPLD = spld
SPLDFLAGS = --static --exechome=$(SICSTUSBIN)

BINFILES = gn429576

all: $(BINFILES)

%: %.sav
	$(SPLD) $(SPLDFLAGS) $< -o wyprawy

%.sav: %.pl
	echo "compile('$<'). save_program('$@')." | $(PL)

clean:
	rm -f $(ALL) *.sav
