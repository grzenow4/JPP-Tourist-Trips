% Grzegorz Nowakowski

:- ensure_loaded(library(lists)).

% Wypisuje na wyjście wyprawę daną jako uporządkowana lista (Tid, Kierunek).
wypiszWyprawa([(Tid, Kier)], D) :-
    trasa(Tid, Skad, Dokad, Rodzaj, _, _),
    (
        Kier == do
    ->  format('~w -(~w,~w)-> ~w~nDlugosc trasy: ~d.~n~n', [Skad, Tid, Rodzaj, Dokad, D])
    ;   format('~w -(~w,~w)-> ~w~nDlugosc trasy: ~d.~n~n', [Dokad, Tid, Rodzaj, Skad, D])
    ).
wypiszWyprawa([(Tid, Kier)|T], D) :-
    trasa(Tid, Skad, Dokad, Rodzaj, _, _),
    (
        Kier == do
    ->  format('~w -(~w,~w)-> ', [Skad, Tid, Rodzaj])
    ;   format('~w -(~w,~w)-> ', [Dokad, Tid, Rodzaj])
    ),
    wypiszWyprawa(T, D).

% Sprawdza, czy trasa jest jednego z możliwych rodzajów.
sprawdzRodzaj([], _).
sprawdzRodzaj(WR, R) :- member(R, WR).

% Sprawdza, czy długość wyprawy spełnia zadany warunek.
sprawdzDlugosc(nil, _).
sprawdzDlugosc((eq, K), K).
sprawdzDlugosc((lt, K), N) :- N < K.
sprawdzDlugosc((le, K), N) :- N =< K.
sprawdzDlugosc((gt, K), N) :- N > K.
sprawdzDlugosc((ge, K), N) :- N >= K.

% Sprawdza, czy wyprawa kończy się w zadanym punkcie.
sprawdzKoniec(nil, _).
sprawdzKoniec(B, [(Tid, do)|_]) :- trasa(Tid, _, B, _, _, _).
sprawdzKoniec(B, [(Tid, od)|_]) :- trasa(Tid, B, _, _, _, _).

% Sprawdza, czy wyprawa spełnia wszystkie warunki
% oraz wypisuje ją, jeśli jest poprawna.
sprawdzWyprawa(B, WD, D, T) :-
    sprawdzDlugosc(WD, D),
    sprawdzKoniec(B, T),
    reverse(T, TR),
    wypiszWyprawa(TR, D).
sprawdzWyprawa(_, _, _, _).

% Wypisuje wszystkie wyprawy z A do B spełniające warunki WR i WD.
query(nil, B, WR, WD) :- skadkolwiek(B, WR, WD).
query(A, B, WR, WD) :- query(A, B, WR, WD, 0, [], []).
query(A, B, WR, WD, D1, T, Visited) :-
    (
        trasa(Tid, A, C, R, _, D2), Kier = do ;
        trasa(Tid, C, A, R, oba, D2), Kier = od
    ),
    \+member((Tid, Kier), Visited),
    \+member((Tid, Kier), T),
    sprawdzRodzaj(WR, R),
    D3 is D1 + D2,
    sprawdzWyprawa(B, WD, D3, [(Tid, Kier)|T]),
    query(C, B, WR, WD, D3, [(Tid, Kier)|T], []),
    query(A, B, WR, WD, D1, T, [(Tid, Kier)|Visited]).
query(_, _, _, _, _, _, _).

% Wypisuje wyprawy z dowolnego miejsca startowego do B, spełniające WR i WD.
skadkolwiek(B, WR, WD) :- skadkolwiek([], B, WR, WD).
skadkolwiek(Visited, B, WR, WD) :-
    (trasa(_, A, _, _, _, _); trasa(_, _, A, _, oba, _)),
    \+member(A, Visited),
    query(A, B, WR, WD),
    skadkolwiek([A|Visited], B, WR, WD).
skadkolwiek(_, _, _, _).

% Sprawdza, czy podany warunek jest poprawny.
sprawdzWarunek(rodzaj(R)) :- atomic(R).
sprawdzWarunek(dlugosc(War, K)) :-
    member(War, [eq, lt, le, gt, ge]),
    integer(K),
    K >= 0.

% Sprawdza, czy podano nie więcej niż jeden warunek na długość.
jednaDlugosc(rodzaj(_), _).
jednaDlugosc(dlugosc(_, _), (_, nil)).

% Sprawdza, czy podano poprawne miejsce startowe / końcowe.
sprawdzMiejsce(nil).
sprawdzMiejsce(koniec) :- write('Koniec programu. Milych wedrowek!\n'), halt.
sprawdzMiejsce(A) :- atomic(A).
sprawdzMiejsce(Err) :- format('Error: niepoprawne miejsce - ~w.~n', [Err]), false.

% Rozbija podane warunki na warunki na rodzaj WR i na dlugość WD,
% jednocześnie sprawdzając ich poprawność.
parsujWarunki(nil, ([], nil)).
parsujWarunki(Term, W) :- parsujWarunki(Term, ([], nil), W).
parsujWarunki((W1, W2), A, W) :-
    (
        sprawdzWarunek(W1)
    ->  (
            jednaDlugosc(W1, A)
        ->  true
        ;   write('Error: za duzo warunkow na dlugosc.\n'), !, false
        )
    ;   format('Error: niepoprawny warunek - ~w.~n', [W1]), !, false
    ),
    !,
    dodajWarunek(W1, A, A1),
    parsujWarunki(W2, A1, W).
parsujWarunki(W1, A, W) :-
    (
        sprawdzWarunek(W1)
    ->  (
            jednaDlugosc(W1, A)
        ->  true
        ;   write('Error: za duzo warunkow na dlugosc.\n'), !, false
        )
    ;   format('Error: niepoprawny warunek - ~w.~n', [W1]), !, false
    ),
    dodajWarunek(W1, A, W).

% Dodaje warunek do akumulatora.
dodajWarunek(rodzaj(R), (WR, WD), ([R|WR], WD)).
dodajWarunek(dlugosc(War, K), (WR, nil), (WR, (War, K))).

% Wczytuje miejsce startowe.
wczytajStart(Start) :-
    write('Podaj miejsce startu: '),
    read(Start),
    sprawdzMiejsce(Start).
wczytajStart(Start) :- wczytajStart(Start).

% Wczytuje miejsce końcowe.
wczytajKoniec(Koniec) :-
    write('Podaj miejsce koncowe: '),
    read(Koniec),
    sprawdzMiejsce(Koniec).
wczytajKoniec(Koniec) :- wczytajKoniec(Koniec).

% Wczytuje warunki.
wczytajWarunki(W) :-
    write('Podaj warunki: '),
    read(Term),
    parsujWarunki(Term, W).
wczytajWarunki(W) :- wczytajWarunki(W).

% Główna pętla programu: pyta użytkownika o dane początkowe,
% a następnie wypisuje wszystkie wyprawy określone przez użytkownika.
interact :-
    wczytajStart(Start),
    wczytajKoniec(Koniec),
    wczytajWarunki((WR, WD)),
    nl,
    query(Start, Koniec, WR, WD),
    interact.

% Rozpoczyna program.
user:runtime_entry(start) :-
    (
        current_prolog_flag(argv, [File])
    ->  set_prolog_flag(fileerrors, off),
        (
            compile(File)
        ->  true
        ;   write('Error: niepoprawny argument lub plik.\n'), halt
        ),
        prompt(_, ''),
	    interact
    ;   write('Incorrect usage, use: program <file>\n'), halt
    ).
