
********************************************
*****        SAS MANUAL EUECM          *****
********************************************;

*Get licensed packages installed list;
PROC SETINIT;
RUN;

*************           **************
*************CHAPTER TWO**************
*************           **************;

*Example of data block;
DATA ONE TWO;
 INPUT A B @@;
 IF A > B THEN OUTPUT ONE;
  ELSE OUTPUT TWO;;
CARDS;
4 5 7 6 8 9
;
RUN;

*Example of proc block;
PROC UNIVARIATE DATA = SASHELP.COMET PLOT NORMAL;
 BY Sample; VAR Length;
 OUTPUT OUT = TWO
 MAX = MAIMI MODE = MODAL SKEWNESS = ASIML;
RUN;

*************             **************
*************CHAPTER THREE**************
*************             **************;

*Example of permanent archive;
LIBNAME JOHN 'C:\Users\riosa\Documents\datasets\sas\sas_manual_euecm';
DATA JOHN.MATRIX;
  INPUT X Y;
  CARDS;
  1 2
  4 6
  ;
RUN;
 
 /* SAS creation files patterns */
 * 1) Data is in a physical location in text format;
 /* DATA SAS-FILE;
      INFILE filename;
	  INPUT ...;
	RUN;
*/

* 2) Data is introduced in the text editor;
/* DATA SAS-FILE;
     INPUT ...;
	 CARDS;
	 Lines with data ...
	 ;
   RUN;
*/

* 3) Data is going to be read from a file .sas7bdat in the disc;
/* LIBNAME JOHN 'C:\';
   DATA SAS-FILE;
     SET JOHN.MATRIX;
   RUN;
*/

* 4) Data is going to be read from a file with a format excel, dbase, etc.;
/* PROC IMPORT DATAFILE='filepath' OUT=SAS-FILE;
     OPTIONS;
   RUN;
*/

* Note: the default length of the variable names is eigth;

* Check the variables in the most recently used dataset using the CONTENTS procedure;
PROC CONTENTS;
RUN;

PROC PRINT DATA = SASHELP.CLASS;
 *TITLE 'TESTING TITLE';
RUN;

* Note on comments: Note that if you have a comment that spans several lines, it is good practice 
* to place a "start comment" marker at the beginning of each new line.;

* Way of restoring titles, from https://blogs.sas.com/content/sasdummy/2013/10/01/restoring-sas-titles/;

* Define macro to save titles;
%macro saveTitles;
  data _savedTitles;
    set sashelp.vtitle;
  run;
%mend;
 
* Define macro to restore previously saved titles;
%macro restoreTitles;
  proc sql noprint;
    * Using a SAS 9.3 feature that allows open-ended macro range;
    select text into :SavedTitles1- from _savedTitles where type="T";
    %let SavedTitlesCount = &sqlobs.;
 
    * and footnotes;
    select text into :SavedFootnotes1- from _savedTitles where type="F";
    %let SavedFootnotesCount = &sqlobs.;
 
    * remove data set that stored our titles;
    drop table _savedTitles;
  quit;
 
  * emit statements to reinstate the titles;
  TITLE; * clear interloping titles;
  %do i = 1 %to &SavedTitlesCount.;
    TITLE&i. "&&SavedTitles&i.";
  %end;
 
  FOOTNOTE; * clear interloping footnotes;
  %do i = 1 %to &SavedFootnotesCount.;
    FOOTNOTE&i. "&&SavedFootnotes&i.";
  %end;
%mend;

* Note: the first macro must be executed before the statement that modifies the title, only one time
* the other macro is to restored the title value to the one saved with the %saveTitles macro;
%saveTitles;
%restoreTitles;

* Testing the diferences between CLASS and BY statements;

PROC MEANS DATA = SASHELP.CLASS;
  VAR AGE;
  CLASS SEX;
RUN;

* Create another dataset like sashelp.class so it can be
* modified by PROC SORT;
DATA TESTSET;
  SET SASHELP.CLASS;
RUN;

PROC SORT DATA = TESTSET;
  BY SEX;
RUN;

PROC MEANS DATA = TESTSET;
  VAR AGE;
  BY SEX;
RUN;

* Testing PROC UNIVARIATE;
PROC UNIVARIATE DATA = SASHELP.CARS;
RUN;

* Trying to get the frequencies of the variable "Make";
PROC FREQ DATA = SASHELP.CARS;
 TABLES Make;
RUN;

* Sorted frequencies;
PROC FREQ DATA = SASHELP.CARS ORDER = FREQ;
 TABLES Make;
RUN;


* Example: reading data with cards;

data one;
 input age 1-2 sex $ 3 weight 4-6 .1;
 cards;
24M804
12F337
15M384
run;

* Let's see the output;

proc print data = one;
run;

* Example: reading by column long alphanumeric variables;

data one;
 length province $ 30;
 input province $ 1-27 codigo 28-30;
 cards;
La Couruña                 345
Las Palmas de Gran Canaria 260
Orense                     113
;
run;

proc print data = one;
run;

* Free format lecture;

data one;
 infile 'C:\Users\riosa\Documents\datasets\sas\sas_manual_euecm\datos_libre.txt';
 input edad sexo $ peso;
run;

proc print data = one;
run;

* Reading comma separated values;
data one;
 infile 'C:\Users\riosa\Documents\datasets\sas\sas_manual_euecm\datos_coma.txt' dlm = ',';
 input edad sexo $ peso;
run;

proc print data = one;
run;

* Example: using @@ for reading several cases per line;

data two;
 input age sex $ weight @@;
cards;
24 H 80.4 12 M 33.7
15 M 38.4
;
run;

proc print data = two;
run;

* Example: what happens when you not use @@;

data two;
 input a b c;
cards;
12 2
4
1 3
3 5 6
5 . 8 8
;
run;

proc print data = two;
run;

* Reading alphanumeric vars in 'free format';

* (1) If the var is in free format and the text variable occupies more than 8 characters
      you must specify the length with 'length var. $ n';

* (2) The symbol & indicates that two white spaces are needed for reading the next variable;

data one;
 length name $ 15;
 input name $ @@;
cards;
Cantalapiedra Gonzalez Shostakovich
;
run;

proc print data = one;
run;

data two;
 length name $ 30;
 input name $ &;
cards;
Paco Pérez   18
María Méndez 22
;
run;

proc print data = two;
run;

* Reading with format;

data one;
 length name $ 20;
 input name $10. heigth 3.2 income comma7. weigth bz3.1;
cards;
Pio Baroja165200,0007 5
;
run;

proc print data = one;
run;

* Example: Observations that fills more than one line;
data one;
 length name direction $ 60;
 input
 #1 name $58. age 59-60 sex $ 61
 #2 direction $59. code;
cards; 
Pedro Pérez García                                        25V
Avenida de la Ilustración, 29                              28021
María López Maeso                                         23M
Calle Antonio López, 42                                    28012
;
run;

proc print data = one;
run;

* Example: Observations that fills several lines;

data one;
 input age 1-2 @3 sex $ / weight 1-3 .1 heigth #3;
cards;
24H
804 1.75
435643643643
12M
337 1.60
234525252552
15M
384 1.70
457456465465
;
run;

proc print data = one;
run;

* Example: Observations with a variable number of lines or a variable number variables;

data one;
 input x1 x2 control @;
 if control=2 then input #2 x3 x4;
cards;
5 23 1
6 34 2
6 7
4 23 1
3 45 2
5 6
;
run;

proc print data = one;
run;

* Example: Reading of a subgroup of observations;
data one;
 infile cards firstobs = 2  obs = 3;
 input a b; 
cards;
1 6
9 6
45 4
3 1
;
run;

proc print data = one;
run;

* Example: Abreviated notation while reading with format;

data one;
 input (x1-x3) (2.);
cards;
455678
324512
;
run;

proc print data = one;
run;

* Example: Reading of data with several observations for each value of one or several key observations;

data one;
 input group @;
 do i = 1 to 3;
  input a b @@;
  output;
 end;
cards;
1 78 43 34 21 2 1
2 33 11 9 7 8 5
;
run;

proc print data = one;
run;

* Example: Read only the necessary variables;

data one;
 input edad 1-2 #3;
cards;
24H
804 1.75
435643643643
12M
337 1.60
234525252552
15M
384 1.70
457456465465
;
run;

proc print data = one;
run;

* Example: Save data into sas files;

* First day;

libname testLib 'C:\Users\riosa\Documents\datasets\sas\sas_manual_euecm';
data testLib.one;
 input age 1-2 @3 sex $ / weigth 1-3 .1 heigth #3;
cards;
24H
804 1.75
435643643643
12M
337 1.60
234525252552
15M
384 1.70
457456465465
;
run;

proc print data = testLib.one;
run;

* Next session;

data two;
 set testLib.one;
run;

proc print data = two;
run;

* Read data from an excel file;

proc import datafile = 'C:\Users\riosa\documents\datasets\sas\sas_manual_euecm\test.xlsx' out = one dbms = xlsx replace;
 *getnames = YES;
 *sheet = Hoja1;
 range = "Hoja1$::A4:G6";
 getnames = NO;
run;

proc print data = one;
run;

/************************************************************
*                                                           *
*    CHAPTER 4: THE ITERATIVE CHARACTER OF THE DATA STEP    *
*                                                           *
*************************************************************/

* Example: Iterative character of the data step;

data one;
 put 'next line to data';
 put 'Observation nº' _N_ a= b=;
 input a b @@;
 put 'next line after input';
 put 'Observation nº' _N_ a= b=;
cards;
4 5 6 7 8 9
;
run;

* Example: Creating two different SAS files in one single data step;

data one two;
 input a b @@;
 if a > b then output one; else output two;
cards;
4 5 7 6 8 9
;
run;

proc print data = one;
run;

proc print data = two;
run;

* Example: Using retain. First with missing variables;
data _null_;
 input b @@;
 sum = sum + b;
 put sum =;
cards;
3 4 5
;
run;

* Example: Calculating sum using retain;

data _null_;
 retain sum 0;
 input b @@;
 sum = sum + b;
 put sum =;
cards;
3 4 5
;
run;

* Example: Calculating the minimum of the observations readed with input;

data min;
 retain m;
 input b @@;
 m = min(b, m);
 put m =;
cards;
2 5 7 8 -1
;
run;

* Example. Observations selection with if;

data one;
 input x @@;
 if x > 6;
cards;
2 5 7 8 -1
;
run;

proc print data = one;
run;

* Example: Selecting observations with where;
data one;
 length month $ 10;
 input month $ income;
cards;
julio 10000
agosto 13000
septiembre 15000
mayo 20200
junio 8800
;
run;

data two;
 set one;
 where month in ('julio', 'agosto', 'septiembre');
 if log(income)>5;
run;

proc print data = one;
run;

proc print data = two;
run;

/*******************************************************
*                                                      *
*    CHAPTER 5: READING AND COMBINATION OF SAS DATA    *
*                                                      *
*******************************************************/

* Example: Creating a SAS file with observations from other file;

data datta (drop = i);
 do i = 1 to 100;
  x = round(ranuni(123)*10 + 1);
  output;
  *put x =;
 end;
run;

data one;
 do i = 1, 3, 6;
  set datta point = i;
  output;
 end;
 stop;
run;

proc print data = one;
run;

data two;
 do i = 1 to 25, 40 to 100;
  set datta point = i;
  output;
 end;
 stop;
run;

* Example: Controling the number of observations in the readed file;

data three;
 set datta nobs = nume;
 put nume =;
 nume2 = nume;
run;

* Example: Selection of each k observations of a sas file;

data four;
 set datta;
 put _n_ = ;
 if MOD(_n_ + 1, 5) = 1 then output;
run;

proc print data = four;
run;

* Example: Secuential union of two SAS files;
data one;
 input a b @@;
cards;
2 1 3 4
;
run;

data two;
 input b c @@;
cards;
6 9 5 1 2 7
;
run;

data three;
 set one two;
run;

proc print data = three;
run;

* Example: Parallel union of SAS files using set;

data three;
 set one;
 set two;
run;

proc print data = three;
run;

* Example: union of one observation from one file with all the observations of another file;

data one;
 input a;
cards;
1
;
run;

data two;
 input b c @@;
cards;
3 2 4 5 7 8
;
run;

data three;
 if _n_ = 1 then set one;
 set two;
 z = b + c - a;
run;

proc print data = three;
run;

* Example: parallel union between SAS files with merge;

data one;
 input a;
cards;
3
;

data two;
 input b;
cards;
4
5
;

data three;
 merge one two;
run;

proc print data = three;
run;

* Let's compare the result with paralell solution instead;
data four;
 set one;
 set two;
run;

proc print data = four;
run;

* Example: Parallel union of files by key var;

data person;
 input name $ sex $;
cards;
maria f
ana f
tomas m
;

data place;
 input name $ city $ region;
cards;
jose alava 5
maria malaga 2
maria orense 7
ana orense 6
;

proc sort data = person; by name;
proc sort data = place; by name;
data datta;
 merge person place;
 by name;
run;

proc print data = datta;
run;

* Example: basic selection of observations and variables in SAS files;

data Bei;
 set sashelp.bei;
run;

data one (keep = Aluminum Boron);
 set sashelp.Bei (firstobs = 23906 obs = 24000);
run;

* Example: observations selection;

data matrix;
 input x z name $;
cards;
3 6 pepe
8 3 maria
9 5 juan
;

data one;
 set matrix (where = (x > 7 and (0 < z < 6 or name = 'juan')));
run;

proc print; run;

* Example: union of files by key word, with selection of observations;

data person;
 input name $ sex $;
cards;
maria f
ana f
tomas m
;
run;

data place;
 input name $ city $ region;
cards;
jose alava 5
maria malaga 2
maria orense 7
ana orense 6
;
run;
proc sort data = person; by name;
proc sort data = place; by name; run;

data datta;
 merge person (in = in_pers) place (in = in_pla);
 by name;
 in_person = in_pers;
 in_place = in_pla;
 if in_person = 1 & in_place = 1;
run;

proc print data = datta; run;


DATA CAFE(KEEP=NAME PLACE CNUM);
   length NAME $ 10;
   INPUT NAME $ ;
   PLACE = 'CAFE   ';
   CNUM = 'C' || LEFT(PUT(_N_,2.));
   DATALINES;
ANDERSON 
COOPER
DIXON 
FREDERIC
FREDERIC
PALMER
RANDALL
RANDALL
SMITH
SMITH 
SMITH
;
RUN;

* Example: Variables that indicate start and ending of a category;

data one;
 input cat edad @@;
cards;
1 21 1 20 2 23 2 25 3 24
;
run;

proc print data = one;
run;

data two;
 set one;
 by cat;
 firstCat = first.cat;
 lastCat = last.cat;
run;

proc print data = two;
run;

* Let's try it with another dataset;

data test3;
 set sashelp.baseball (keep = team);
run;

proc sort data = test3; by team; run;

data test4;
 set test3;
 by team;
 firstTeam = first.Team;
 lastTeam = last.Team;
run;

proc print data = test4;
run;

* Example: Obtaining all unique values of a categoric variable;

data test5;
 set test3;
 by team;
 if first.team = 1 then output;
run;

proc print data = test5;
run; 

* Example: Locate categories with only one element;
* (Use one dataset from sashelp);

data test (keep = CITY);
 set sashelp.Zipcode;
run;

proc sort data = test;
 by city;
run;

data uniqueCities;
 set test;
 by CITY;
 if first.CITY = 1 & last.city = 1 then output;
run;

proc print data = uniqueCities;
run;


* With the book's data;

data one;
 length city $ 9;
 input city $ code $;
cards;
valencia 4
orense 6
madrid 7
madrid 7
barcelona 3
;
run;

proc sort data = one; by city; run;

data oneUnique oneDuplicated;
 set one;
 by city;
 if first.city = 1 & last.city = 1 then output oneUnique;
 else output oneDuplicated;
run;

proc print data = oneUnique;
proc print data = oneDuplicated; run;

* Example: Delete duplicated observations with proc sort;

proc sort data = one out = nodupli nodupkey;
 by city;
run;

proc print data = one;
proc print data = nodupli; run;

* Example: Syntax of the put sentence;

data one;
 input a b c @@;
 *b = b + 4;
 put @3 a / b +4 c;
cards;
3 4 5 1 2 3
;
run;

data one;
 input a b c @@;
 put a = b = c =;
cards;
3 4 5 1 2 3
;
run;

data one;
 input a b c @@;
 put 'este es el valor de a:' a;
cards;
3 4 5 1 2 3
;
run;

* Example: Write output to txt file;

data one;
 input a b c @@;
 file 'C:\Users\riosa\documents\datasets\sas\sas_manual_euecm\testPutSAS.txt';
 put @3 a / b +4 c;
cards;
3 4 5 1 2 3
;
run;

* Example: Creating a txt file with data from a SAS file;

data one;
 length city $ 9;
 input city $ code obs ;
cards;
Valencia 4 1
Orense 6 2
Madrid 7 3
Barcelona 3 5
;
run;

data _null_;
 set one;
 file 'C:\Users\riosa\documents\datasets\sas\sas_manual_euecm\testPut2SAS.txt';
 put city code obs;
run;

* Example: Combine the output of the output window and the text of the put sentence;

data matriz;
 input b @@;
 file 'C:\Users\riosa\documents\datasets\sas\sas_manual_euecm\testPut3SAS.txt' print;
 put b =;
cards;
3 5 7 8
;

proc means data = matriz;
run;

* Example: add informamtion to an existing txt file;

data _null_;
 set one;
 file 'C:\Users\riosa\documents\datasets\sas\sas_manual_euecm\testPut3SAS.txt' mod;
 put city $ code obs;
run;

/**********************************
*                                 *
*    CHAPTER 6: SAS FUNCTIONS     *
*                                 *
**********************************/ 


data test;
 input a b @@;
 c = sqrt(a + b);
 d = _n_**2;
 e = sqrt(d);
cards;
1 2 3 4 5 6 7 8 9
10 11 12 13 14 15 16
17 18 19 20
;
run;

proc print data = test;
run;

* Example: factorial of a number;

data facto7;
 y = gamma(8);
 put '7!=' y;
run;

* Example: find the minimum value between the variables for each observation;

data mini;
 input a b;
 c = min(a, b);
 put 'minimum of (a, b) =' c;
cards;
3 4
2 1
77 87
99 9
52 41
;
run;

proc print data = mini;
run;

* Testing proc means;

data one;
 input a @@;
cards;
1 2 3 4 5 6 7 8 9
;

proc means data = one;
run;

* Example: generating random numbers;

data one;
 x = ranuni(0);
 y = rannor(0)*3 + 5;
run;

proc print data = one;
run;

data two;
 input a @@;
 b = rannor(0)*3 + 15;
cards;
1 2 3 4 5 6 7 8 9
10 11 12 13 14 15 16 17 18 19
20 21 22 23 24 25 26 27 28 29
30 31 32 33 34 35 36 37 38 39
;
run;

proc print data = two;
run;

proc means data = two;
 var b;
run;

* Example: Rounding variables with round and int;

data one;
 input a;
 c1 = round(a, 10);
 c2 = round(a, 1);
 c3 = round(a, 0.1);
 c4 = round(a, 0.2);
 c5 = int(a);
cards;
23.145
1234.42
;
run;

proc print; run;

* Example: Another type of rounding of variables;

data one;
 input a;
 /* c1 = redondeo al primer decimal */
 /* c2 = redondeo al segundo decimal */
 c1 = int(a*10)/10;
 c2 = int(a*100)/100;
cards;
23.145
1234.42
;
proc print; run;

* Example: manipulating alphanumeric variables;

data one;
 length a $30.;
 a = '  En un lugar de la Mancha';
 x = compress(a, ' M'); put x =;
 y = trim(a); put y =;
 z = scan(a, 3); put z =;
run;

* Example: Using the lag function;

data one;
 input x @@;
 y = lag1(x);
 z = lag2(x);
 q = lag1(y);
cards;
1 2 3 4 5
;

proc print; run;

* Example: Converting string variables to numeric and numeric to string ones;

data one;
 x = '22222';
 y = 66666;
 z = put(y, $10.);
 w = input(x, 20.);
 put z = w =;
run;

proc contents data = one; run;

proc contents data = sashelp.bei; run;

/********************************
*                               *
*    CHAPTER 7: conditionals    *
*                               *
********************************/

* Example: Conditional selection of observations;

data two;
 input name $ age;
cards;
Ana 18
Julia 25
Berta 71
Carmen 93
Rocio 21
Veronica 31
;
run;

data one;
 set two;
 if age < 30 then delete;
 output;
run;

* Example: selection of observation with the option if var in (...);

data euroBrands;
 set sashelp.cars (keep = Make Model Type Origin DriveTrain);
 if origin in ('Asia', 'USA') then delete;
run;

proc print data = euroBrands;
run;

* Let's try to take a sample of only one car for each european brand;

proc sort data = euroBrands;
 by Make;
run;

data euroSample;
 set euroBrands;
 by Make;
 if first.Make = 1 then output;
run;

proc print data = euroSample;
run;

* Example: Programming block conditional sentence;

data two;
 input name $ age heigth;
cards;
Ana 18 155
Julia 25 162
Berta 71 170
Carmen 93 145
Rocio 21 183
Veronica 31 146
;
run;

data one;
 set two;
 if age < 30 then
  do;
   age = age + 7;
   rate = heigth/age;
  end;
 else;
  do;
   age = age - 5;
   rate = heigth/age - 4;
  end;
run;

proc print data = one;
run;


* Example: Using the conditional sentence select;

* First let's create a dataset using random numbers;

data one (drop = i);
 *input year income expenditures;
 do i = 1 to 100000;
  year = int(ranuni(123)*20 + 1989);
  income = int(ranuni(124)*10000 + 100000);
  expenditures = int(ranuni(125)*5000 + 50000);
  output;
 end;
run;

proc print data = one;
run;

proc contents data = one;
run;

proc means data = one;
run;

proc freq data = one;
 tables year;
run;

proc univariate data = one;
 histogram income;
run;

data anterior period1 period2 period3 period4 period5;
 set one;
 select (year);
  when (1989) output period1;
  when (1990) output period2;
  when (1991) output period3;
  when (1992) output period4;
  when (1993) output period5;
  otherwise output anterior;
 end;
run;

/**************************
*                         *
*    CHAPTER 8: LOOPS     *
*                         *
**************************/

* Example: Basic syntax of the do end sentence;

data _null_;
 do i = 1 to 5;
  put 'Hello';
 end;
run;

* Example: Basic syntax of the do end sentence (2);

data _null_;
 sum = 0;
 do i = 1 to 13 by 2;
  sum = sum + i;
 end;
 put sum =;
run;

* Example: Basic syntax of the do end sentence (3);

data _null_;
 sum = 0;
 do i = 2, 5, 9, 18;
  sum = sum + i;
 end;
 put sum =;
run;

* Example: Basic syntax of the do end sentence (4);

data _null_;
 length month $ 15;
 conta = 0;
 do month = 'january', 'february', 'april';
  conta = conta + 1;
  put conta month;
 end;
run;

* Example: Basic syntax of the do end sentence (5);

data one;
 do count = 3 to 5, 20 to 26 by 2;
  output;
 end;
run;

* Example: Basic syntax of the do end sentence (6);

data one (drop = i);
 input x @@;
 put 'reading observation nº' _n_ x=;
 stop = 10;
 sum = 0;
 do i = 1 to stop;
  sum = sum + i*x;
  put i = sum =;
  if sum > 20 then i = stop;
 end;
cards;
3 4 7
;
run;

* Example: Basic syntax of the do end sentence (7);

data one;
 do i = 1 to 3;
  do j = 1 to 4;
   output;
  end;
 end;
run;

* Example: Sentence do while;
data _null_;
 n = 0;
 do while (n < 5);
  put n =;
  n = n + 1;
 end;
run;

* Example: Sentence do until;

data _null_;
 n = 0;
 do until (n >= 5);
  put n =;
  n = n + 1;
 end;
run;

* Example: Combining the formats do, do until and do while;

data _null_;
 sum = 0;
 do i = 1 to 10 by .5 while (sum < 8.5);
  sum = sum + i;
  put sum =;
  end;
run;

* Example: Creating a probabilistic table (Poisson);

* First try;

data _null_;
 /* HEADER */
 put / @7 'TABLA DE PROBABILIDADES ACUMULADAS PARA POISSON (LAMBDA)';
 do i = 1 to 62;
  put '-' @;
 end;
 put / @25 'LAMBDA';
 do i = 1 to 62;
  put '-' @;
 end;
 put / 'k' @3 @;
 do i = 0.1 to 1.2 by 0.1;
  *put;
  put i 4.1 +1 @;
 end;
 put / @;
 do i = 1 to 62;
  put '-' @;
 end;
 put / @;
 do i = 0 to 7;
  put i @;
  do j = 0.1 to 1.2 by 0.1;
   value = round(poisson(j, i), 0.001);
   put value 4.3 +1 @;
  end;
  put / @;
 end;
run;

* Solution;

data _null_;
 /* HEADER */
put / @7 'TABLA DE PROBABILIDADES ACUMULADAS PARA POISSON (LAMBDA)';

do i = 1 to 62;
 put '-' @;
end;
put;
put @25 'LAMBDA';
do i = 1 to 62;
 put '-' @;
end;
put;
put 'k' @3 @;
do i = 0.1 to 1.2 by 0.1;
 put i 4.1 +1 @;
end;
put;
do i = 1 to 62;
 put '-' @;
end;

/* CREATION OF THE TABLE */

do k = 0 to 7;
 put / k @;
 do lambda = 0.1 to 1.2 by 0.1;
  pro = poisson(lambda, k);
  put pro 4.3 +1 @;
 end;
end;

run;

* Example: Creating a SAS file with several artificial variables;

data one (drop = i);
 do i = 1 to 20;
  x1 = rannor(i)*sqrt(2) + 2;
  x2 = 5*rangam(i, 2);
  output;
 end;
run;

* Example: Obtaining random samples with replacement;

* Testing creating random numbers from a uniform from 1 to 30;

data two (drop = i);
 do i = 1 to 100000;
  nume = int(30*ranuni(0) + 1);
  output;
 end;
run;

proc means data = two;
run;

data _null_;
 set two;
 retain testMin testMax;
 if (_n_ = 1) then
  do;
   testMin = nume;
   testMax = nume;
  end;
 else
  do;
   testMin = min(testMin, nume);
   testMax = max(testMax, nume);
  end;
 *;
 if (_n_ = 100000) then
  do;
   put testMin =;
   put testMax =;
  end;
 ;
run;

* Actual example;

data two (drop = i);
 retain nume;
 do i = 1 to 30;
  nume = int(30*ranuni(0) + 1);
  set sashelp.baseball (keep = Team Name) point = nume;
  originalIndex = nume;
  output;
 end;
 stop;
run;

* Looking if replacemente have ocurred in the sample;

proc freq data = two order = freq;
 table originalIndex;
run;

* Example: Obtaining a sample without replacement (method 1);

data three;
 set sashelp.baseball (keep = Team Name);
 index = ranuni(12345);
run;

proc sort data = three;
 by index;
run;

data sampleThree;
 set three;
 if (_n_ = 11) then stop;
run;

* Solution;

data four;
 set sashelp.baseball (keep = Team Name);
 nume = int(30*ranuni(0));
run;

proc sort data = four;
 by nume;
run;

data five;
 set four;
 if _n_ > 10 then stop;
run;

* Example: Obtaining samples without replacement (method 2);

data alea;
 set sashelp.Bei (keep = X Y);
 x = ranuni(0);
 if x < 0.04 then output alea;
run;

proc sort data = alea;
 by x;
run;

data alea;
 set alea;
 if _n_ > 320 then stop;
run;

proc contents data = alea;
run;

* Example: systematic sampling;

* First let's inspect the dataset;

proc freq data = sashelp.Bweight order = freq;
 table MomAge;
run;

proc univariate data = sashelp.Bweight;
 
run;

* Let's take a subsample of 2000 observations from the Bweight dataset;

data one;
 set sashelp.Bweight (keep = Weight Married MomSmoke);
 if _n_ > 2000 then stop;
run;

data two;
 u = int(ranuni(0)*10 + 1);
 do i = u to 2000 by 10;
  set one point = i;
  output;
 end;
 stop;
run;

proc means data = one;
 var Weight;
run;

proc freq data = one order = freq;
 table Married MomSmoke;
run;

proc freq data = two order = freq;
 table Married MomSmoke;
run;

proc means data = two;
 var Weight;
run;

* Example: Obtaining a sample of a proportion from the original file;

* First: 30% of the original with replacement;

data two;
 z = 1;
 if _n_ = 1 then set sashelp.baseball (keep = Team Name) point = z nobs = total;
 do until (z > int(0.30*total));
  nume = int(total*ranuni(0) + 1);
  set sashelp.baseball (keep = Team Name) point = nume;
  z = z + 1;
  output;
 end;
 stop;
run;


data _null_;
 set sashelp.baseball nobs = total;
 retain samplesize;
 if _n_ = 1 then
  do;
   *nobs = total;
   samplesize = int(0.3*total);
   put total =;
   put samplesize =;
  end;
  *stop;
run;

proc contents data = two;
run;

* Without replacement;

data three;
 set sashelp.baseball (keep = Team Name);
 nume = int(30*ranuni(0));
run;

proc sort data = three;
 by nume;
run;

data four;
 set three nobs = total;
 if _n_ > int(0.30*total + 1) then stop;
run;

proc contents data = four;
run;

data _null_;
 set four nobs = total;
 if _n_ = 1 then put total =;
run;

/**************************
*                         *
*    CHAPTER 9: ARRAYS    *
*                         *
**************************/


* Example: transforming several variables using arrays;

data one (drop = i);
 array group a b c;
  input a b c;
  do i = 1 to 3;
   if group{i} < 4 then group{i} = 4;
  end;
cards;
2 3 6
1 2 5
;
run;

* Example: transforming several variables using arrays(2);

* First let's simulate a dataset that also takes negative values;

data one (drop = i);
 do i = 1 to 100;
  a = round(ranuni(0)*200 - 100);
  b = round(ranuni(0)*200 - 100);
  c = round(ranuni(0)*200 - 100);
  output;
 end;
run;

proc means data = one;
run;

data two (drop = i);
 array x{3} a b c;
 set one;
 do i = 1 to 3;
  if x{i} < 0 then x{i} = 0;
 end;
run;

proc means data = two;
run;

* Example: Creating an artifical SAS file;

data one (drop = obse i);
 array x{5};
  do obse = 1 to 100;
   do i = 1 to 5;
    x{i} = rannor(0);
   end;
   output;
  end;
run;

* Example: Reading data using arrays;

data one;
 array x{10};
 input x1-x10;
cards;
2 4 8 2 1 5 9 0 4 5
5 8 6 9 5 34 5 5 5 6
5 4 3 2 1 7 8 9 0 10
;
run;

* Example: Using arrays in no standard SAS programming mode;

data one;
 input a @@;
cards;
2 4 8 2 1 5 9 0 4 5
;


data two (drop = a);
 array x{10};
 set one end = fin;
 x{_n_} = a;
 if fin = 1 then output two;
run;

data _null_;
 array x{10};
 set two;
 sum = 0;
 do i = 1 to 10;
  sum = sum + x{i}**2;
 end;
 put 'sum of squares =' sum;
run;

* Withou arrays the program would be;

data one;
 retain sum 0;
 input a @@;
 sum = sum + a**2;
 if _n_ = 10 then put 'sum of squares =' sum;
cards;
2 4 8 2 1 5 9 0 4 5
run;

* Example: Using SAS functions instead of programming with loops;

* Firs let's create a dataset;

data one (drop = i);
 do i = 1 to 100;
  a = int(200*ranuni(0) - 100);
  b = int(200*ranuni(0) - 100);
  c = int(200*ranuni(0) - 100);
  d = int(200*ranuni(0) - 100);
  e = int(200*ranuni(0) - 100);
  output;
 end;
run;

proc means data = one;
run;

data two;
 set one;
 media = mean(a, b);
run;

* Previous program is more efficient than;

data two (drop = i x1-x5);
 array x{5} a b c d e;
 set one;
 media = 0;
 do i = 1 to 5;
  media = media + x{i};
 end;
 media = media/5;
run;

* Example: Multidimensional array;

data tempes (drop = i j);
 array temprg{2, 5} c1t1-c1t5 c2t1-c2t5;
 input c1t1-c1t5 /
       c2t1-c2t5;
 do i = 1 to 2;
  do j = 1 to 5;
   temprg{i, j} = (temprg{i, j} - 32)/1.8;
  end;
 end;
cards;
89.5 65.4 75.3 77.7 89.3
73.7 87.3 89.9 98.2 35.6
75.8 82.1 98.2 93.5 67.7
101.3 86.5 59.2 35.6 75.7
;
run;

/*************************************************************
*                                                            *
*      CHAPTER 10: INTRODUCTION TO THE SAS PROCEDURES        *
*                                                            *
*************************************************************/


* Example: Personal options by default;

/*
options

nocenter
nodate
nodetails
formdlim = ''
linesize = 90
nonumber
pagesize = 30000
probsig = 2
nosource
nonotes;

*/

* Example: Send by default to txt files the results of the window outupt and log;

proc printto log = 'C:\users\riosa\documents\datasets\sas\sas_manual_euecm\datlog.txt' print = 'C:\users\riosa\documents\datasets\sas\sas_manual_euecm\datosput.txt';
run;

data one;
 set sashelp.bei (keep = X Y);
 if _n_ > 100 then stop;
run;

proc means data = one;
run;

* Example: Creation of output files in the procedures;

proc univariate data = one;
 var X Y;
 output out = two mean = meanx meany min = minx miny max = maxx maxy;
run;


* Example: Using where in the procedures;

proc print data = sashelp.baseball;
 var Name;
 where Team = 'Chicago';
run;

* Example: Using the option noprint for obtaining results in the output window;

proc univariate data = one noprint;
 var x y;
 output out = two mean = mediax mediay min = minx miny max = maxx maxy;
run;

/*************************************************************
*                                                            *
*        CHAPTER 11: Writting format of SAS variables        *
*                                                            *
*************************************************************/

* Example: Format for alphanumeric categoric variables;

proc contents data = sashelp.baseball;
run;

proc print data = sashelp.baseball (firstobs = 1 obs = 10);
run;

data one;
 set sashelp.baseball (keep = Team Name nAtBat League Division);
 if Team in ('Chicago', 'Baltimore', 'Houston', 'Detroit');
run;

proc freq data = one order = freq;
 table Team;
run;

proc format; value $formTeam 'Chicago' = 'Chi' 'Baltimore' = 'Balt' 'Detroit' = 'Det' 'Houston' = 'Hous';
run;

proc print data = one; format Team $formTeam.;
run;

* Example: format in numeric categorical variables;

proc format; value formage low-12 = 'kid' 13-19 = 'adolescent' 20-high = 'adult';
run;

data one;
 input age;
cards;
15
23
7
13
;
run;

proc print data = one;
 format age formage.;
run;

* Example: using the function put(variable, format) to create new cualitative variables;

data one;
 length country $ 30;
 input country $ 1-30;
cards;
Spain
United States
Japan
;
run;

proc format; 
 value $curre
 'United States' = 'Dollar'
 'Spain' = 'Euro'
 'Japan' = 'Yen';
run;

data two;
 set one;
 currency2 = put(country, $curre.);
run;

proc print data = two;
run;

* The previous program is more efficient than;

data three;
 set one;
 if country = 'United States' then currency2 = 'Dollar';
 else if country = 'Spain' then currency2 = 'Euro';
 else if country = 'Japan' then currency2 = 'Yen';
run;

* Example: Representing numeric intervals;

proc format; picture income 0-70000 = '00000'
                       70001-150000 = '000000'
					   other = 'mas de 150000' (noedit);
run;

data one;
 input incom;
cards;
50000
300000
130000
;

proc print data = one;
 format incom income.;
run;

* Example: Using the print procedure;

data one;
 do i = 1 to 10;
  x = 5 + normal(i)*2;
  y = 3*ranexp(i);
  output one;
 end;
run;

proc print data = one round;
 id i;
 sum x;
run;

* Example: Using the procedure sort and print;

data one;
 do i = 1 to 20;
  x = round(5 + normal(i)*25);
  y = round(10*ranexp(i));
  sex = round(ranuni(i));
  output;
 end;
run;

proc sort data = one;
 by sex;
run;

proc print data = one noobs;
 by sex;
run;

* Example: Using the procedure sort and print (2);

proc sort data one;
 by sex;
run;

proc print data = one noobs;
 sum x;
 by sex;
run;

* Example: Using proc contents procedure;

* First let's simulate a dataset;

proc format;
 value formSex
  0 = 'Male'
  1 = 'Female';
run;


data one (drop = i auxsex);
 do i = 1 to 100;
  salary = round(ranexp(i)*1500, .01);
  auxsex = round(ranuni(i));
  sex = put(auxsex, formSex.);
  output;
 end;
run;

proc print data = one;
run;

proc means data = one;
 var salary;
run;

proc freq data = one order = freq;
 table sex;
run;

proc contents data = one;
run;

* Example: Obtaining a list of the variables present in a file;

proc contents data = sashelp.bei out = two noprint;
run;

proc print data = two;
 var type length varnum name;
run;

data _null_;
 set two;
 put name @@;
 file 'C:\users\riosa\documents\datasets\sas\sas_manual_euecm\listvar.txt';
 put name @@;
run;

* Example: transposition of a SAS file;

data orig;
 input x y;
cards;
1 2
4 5
6 7
4 5
;
run;

proc transpose data = orig prefix = a name = names out = trans;
run;

* Example: operations with one matrix using arrays and proc transpose;

data one;
 input x1-x4;
cards;
1 3 5 1
3 5 8 7
3 2 1 1
3 2 2 2
;
run;

proc transpose data = one prefix = y out = tra;
run;

data sum;
 array x{4};
 array y{4};
 array z{4};
 set one;
 set tra;
 do i = 1 to 4;
  z{i} = x{i} + y{i};
 end;
run;

* Example: Proc univariate;

data one (drop = i);
 do i = 1 to 100;
  x = 4*normal(i) + 10;
  output;
 end;
run;

proc univariate data = one plot normal;
 var x;
 output out = two mean = meanx max = maxx skewness = asimetr;
run;

proc print data = two;
run;

* Example: Proc reg;

data one (drop = i epsi);
 do i = 1 to 20;
  epsi = rannor(111)*sqrt(6);
  x = rannor(222)*3 + 4;
  y = 2 + 3*x + epsi;
  output;
 end;
run;

proc gplot data = one;
 plot y*x / overlay;
run;

proc reg data = one;
 model y = x;
 output out = two
 r = resi
 p = predi;
run;

/*******************************************
*                                          *
*        CHAPTER 13: Macro language        *
*                                          *
*******************************************/


* Example: Creation of a macrovariable;

%let root = dat;
data one;
 &root = 5;
 z = 10*&root;
run;

* It's the same as;

data two;
 dat = 5;
 z = 10*dat;
run;

* Example: Using a macrovariable as a numeric constant;

%let u = 224;

data one;
 x = 5*&u;
 put x =;
run;

* It's the same as;

data two;
 x = 5*224;
 put x =;
run;

* Example: Incorrect treatment of a macrovariable;

* This is incorrect;
%let n = 224;

data one;
 put &n;
run;

* The correct form is;

%let n = 224;

data one;
 %put &n;
run;

* Example: combining text with macrovariables;

%let lib = sashelp;

data _null_;
 %put &lib;
 %put &lib.bei;
 %put &lib..bei;
run;

%let n = 150;

proc print data = &lib..baseball (firstobs = 100 obs = &n);
run;

 * Example: using macrovariables in the dimensions of an array;

%let dim1 = 10;
%let dim2 = 30;
%let obse = 200;

data one;
 array x{&dim1};
 array y{&dim2};
 do j = 1 to &obse;
  do i = 1 to &dim1;
   x{i} = rannor(0);
  end;
  do i = 1 to &dim2;
   y{i} = ranuni(0);
  end;
  output;
 end;
run;

proc means data = one;
 var x1-x&dim1
     y1-y&dim2;
 output out = sal
 mean = meanx1-meanx&dim1 meany1-meany&dim2;
run;

proc print data = sal;
run;

* Try to replicate the above example but using random uniform generated numbers to
  change the parameters of random normal generated numbers that would be the values of the
  variables in the dataset;
%let upperunif = 10;
%let numobs = round(ranuni(0)*9999 + 1);
%let xyrange = int(ranuni(0)*&upperunif) + 1;
%let randmean = int(ranuni(0)*120) + 1;
%let randvar = int(ranuni(0)*10) + 1;
*%let auxdim1 = 1000;
data test (drop = i j dim1 dim2);
 dim1 = &xyrange;
 dim2 = &xyrange;
 array x{&upperunif}; 
 array y{&upperunif};
 do i = 1 to &numobs;
  do j = 1 to dim1;
   x{j} = round(rannor(j)*&randvar + &randmean);
  end;
  do j = 1 to dim2;
   y{j} = round((rannor(j)*&randvar + &randmean));
  end;
  output;
 end;
 call symput ('auxdim1', left(dim1 + 1)); * !!!!! REVIEW THIS;
 call symput ('auxdim2', left(dim2 + 1));
run;

data _null_;
 %let testcat = x&auxdim1;
 %let testcat2 = y&auxdim2;
 %put &testcat;
 %put &testcat2;
 if &auxdim1 eq 11 then put 'auxdim1 equals 11';
 else put 'auxdim1 not equals 10';
 if &auxdim2 = 11 then put 'auxdim2 equals 11';
 else put 'auxdim2 not equals 10';
run;

data _null_;
 if &auxdim1 ne 11 then put 'auxdim1 equals 11';
 else put "auxdim1 doesn't equals 11";
run;

* This is not working, better to try to use the if clause within a macro;

data test2;
 if &auxdim1 ne 11 then do;
  set test (drop = x&auxdim1-x10);
 end;
 else do;
  set test;
 end;
run;

data test2;
 if &auxdim2 ne 11 then set test2 (drop = y&auxdim2-y10);
run;

%macro myTestmacro;
 %if &auxdim1 = 11 %then %do;
  data test2;
   set test;
  run;
 %end;
 %else %do;
  data test2;
   set test (drop = x&auxdim1-x10);
  run;
 %end;

 %if &auxdim2 ne 11 %then %do;
  data test2;
   set test2 (drop = y&auxdim2-y10);
  run;
 %end;
%mend;

%myTestmacro;

* Now let's try to include all process in one single macro;

%macro randomDataSet;
 %let upperunif = 10; * Upper bound of the random uniform generated numbers;
 %let numobs = round(ranuni(0)*9999 + 1); * Random number of observations, from 1 to 10000;
 %let xyrange = int(ranuni(0)*&upperunif) + 1; * Random number of observations, from 1 to 10;
 %let randmean = int(ranuni(0)*120) + 1;
 %let randvar = int(ranuni(0)*10) + 1;

 data test (drop = i j dim1 dim2);
  dim1 = &xyrange;
  dim2 = &xyrange;
  array x{&upperunif}; 
  array y{&upperunif};
  do i = 1 to &numobs;
   do j = 1 to dim1;
    x{j} = round(rannor(j)*&randvar + &randmean);
   end;
   do j = 1 to dim2;
    y{j} = round((rannor(j)*&randvar + &randmean));
   end;
   output;
  end;
  call symput ('auxdim1', left(dim1 + 1)); * !!!!! REVIEW THIS;
  call symput ('auxdim2', left(dim2 + 1));
 run;

 %if &auxdim1 ne 11 %then %do;
  data test;
   set test (drop = x&auxdim1-x10);
  run;
 %end;

 %if &auxdim2 ne 11 %then %do;
  data test;
   set test (drop = y&auxdim2-y10);
  run;
 %end;

%mend;

%randomDataset;

proc means data = test;
run;


* Example: Creating groups of vartiables of interest using macrovariables;

data one;
 input age sex heigth income nsons;
cards;
23 1 170 20000 1
28 2 190 15000 0
;
run;

proc contents data = one out = two noprint;
run;

data _null_;
 set two;
 put name @@;
run;

* Example: setting the value of a macrovariable to a SAS variable in a data step;

%let x = 10;
data one;
 y = &x;
 put y =;
run;

* Example: asigning the value of a SAS variable to a macrovariable in a data step;

data one;
 name = 'Peter';
 call symput('forename', name);
run;

data _null_;
 %put Name = &forename;
run;

data one;
 age = 21;
 call symput('years', age);
run;

data _null_;
 %put years = &years;
run;

data one;
 age = 21;
 call symput('years', left(age));
run;

data _null_;
 z = &years;
 put z =;
run;


* Example: macro with the SAS file of interest as a parameter;

* First let's simulate the dataset;

data one (drop = i j);
 array x{10};
 do i = 1 to 100;
  do j = 1 to 10;
   x{j} = int(ranuni(i)*100) + 1;
  end;
  output;
 end;
run;

%macro meanss(file);
 proc means data = &file;
  var x1-x10;
  output out = outmeans mean = mean1-mean10;
 run;
 data _null_;
  array mean{10};
  set outmeans;
  file 'C:\Users\riosa\documents\datasets\sas\sas_manual_euecm\means.txt';
  do i = 1 to 10;
   put mean{i} =;
  end;
 run;
%mend;

%meanss(one);

* Example: macro with SAS file and list of variables as parameters;

%macro meanss2(file, listvar, nvar);
 proc univariate data = &file;
  var &listvar;
  output out = outunivar
  mean = mean1-mean&nvar;
 run;
 data _null_;
  array mean{&nvar};
  set outunivar;
  file 'C:\Users\riosa\documents\datasets\sas\sas_manual_euecm\means2.txt';
 do i = 1 to &nvar;
  put mean{i} =;
 end;
 run;
%mend;

* Let's simulate two datasets to test it;

data one (drop = i);
 do i = 1 to 200;
  x = round(rannor(i)*20 + 200);
  y = round(rannor(i)*10 + 80);
  z = round(ranexp(i)*50);
  age = int(ranuni(i)*120 + 1);
  output;
 end;
run;

data two (drop = i j);
 array x{15};
 do i = 1 to 300;
  do j = 1 to 15;
   x{j} = round(rannor(i)*20 + 250);
  end;
  output;
 end;
run;

proc means data = one;
run;

proc means data = two;
run;

%meanss2(one, x y z age, 4);

%meanss2(two, x1-x15, 15);


* Example: macro for obtain an ordered list of correlations between vars in a file;

* First let's simulate a dataset to apply it the macro;

data one (drop = i j);
 array x{12};
 do i = 1 to 100;
  do j = 1 to 12;
   x{j} = round(rannor(j)*25 + 320);
  end;
  output;
 end;
run;

* Let's explore what the code does;

proc corr data = one outp = two;
 var x1-x12;
run;

data three;
 set two;
 if _type_ = 'CORR' then output;
run;

data four (keep = i j corre correabs);
 array x{12};
 set three;
 j = _n_;
 do i = 1 to 12;
  if i <= j then do;
   correabs = abs(x{i});
   corre = x{i};
   output;
  end;
 end;
run;

proc sort data = four;
 by descending correabs;
run;

data _null_;
 set four;
 if _n_ = 1 then put 'i' @5 'j' @10 'Abs(Correlation)' @40 'Correlation' //;
 if i ne j then put i @5 j @10 correabs @40 corre;
run;

%macro corres(archi, dim);
 proc corr data = &archi outp = dos;
  var x1-x&dim;
 run;

 data three;
  set two;
  if _type_ = 'CORR' then output;
 run;

 data four (keep = i j corre correabs);
  array x{&dim};
  set three;
  j = _n_;
  do i = 1 to &dim;
   if i <= j then do;
    correabs = abs(x{i});
	corre = x{i};
	output;
   end;
  end;
 run;

 proc sort data = four;
  by descending correabs;
 run;

 data _null_;
  set four;
  if _n_ = 1 then put 'i' @5 'j' @10 'Abs(Correlation)' @40 'Correlation' //;
  if i ne j then put i @5 j @10 correabs @40 corre;
 run;
%mend;

%corres(one, 12);

* Example: Transforming a list of variables to indexed variables in a SAS file;

%macro change(inputt, outputt, nvar, root);
 data _null_;
  do i = 1 to &nvar;
   vari = scanq(&listvar, i, " ");
   put vari =;
   call symput('var' || left(i), left(vari));
  end;
 run;

 data &outputt (keep = &root.1-&root&nvar);
 set &inputt;
 %do i = 1 %to &nvar;
  &root&i=&&var&i;
 %end;
 run;
%mend;

data testSet;
 set sashelp.baseball;
run;

proc contents data = testset output = sal;
run;

data _null_;
 set sal;
 put NAME @;
run;

%let listvar = 'CrAtBat CrBB CrHits CrHome CrRbi CrRuns Div Division League Name Position Salary Team YrMajor logSalary nAssts nAtBat nBB nError nHits nHome nOuts nRBI nRuns';

%change(testSet, sal2, 24, z);

proc print data = sal2;
run;

proc sort data = sal;
 by VARNUM;
run;

proc contents data = testset;
run;


* Example: Conditional sentence about numeric values of one macrovariable;

%macro create;
 %do i = 1 %to 3;
  data archi&i;
   do j = 1 to 10;
    x&i = rannor(0)*&i;
    output;
   end;
 %end;
%mend;

%create;
