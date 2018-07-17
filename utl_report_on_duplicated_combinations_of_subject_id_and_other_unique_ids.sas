Report on duplicated combinations of subject id and other unique ids

see github
https://tinyurl.com/y76e67kn
https://github.com/rogerjdeangelis/utl_report_on_duplicated_combinations_of_subject_id_and_other_unique_ids

https://tinyurl.com/yaq2w7v7
https://communities.sas.com/t5/Base-SAS-Programming/Help-in-my-macro-pgm/m-p/478393

inspired by S Lassen
https://communities.sas.com/t5/user/viewprofilepage/user-id/76464

INPUT
=====

 TMP.HAVONE total obs=5

   NO DUPLICATES ON UNIQUE IDS

   USUBJID       SSN       PATID

   Alfred     243811161    08948
   Alice      383193716    09794
   Barbara    257581089    08827
   Carol      036299670    10762
   Henry      445828345    14317


  TMP.HAVTWO total obs=6

   ONE DUPLICATE FOR USUBJID WITH SSN AND USUBJID WITH PATID

   USUBJID       SSN       PATID

   Alfred     243811161    08948
   Alice      383193716    09794

   Barbara    257581089    08827  ** dups
   Barbara    257581089    08827  ** dups

   Carol      036299670    10762
   Henry      445828345    14317


  TMP.HAVTRE total obs=7

   TWO DUPLICATES FOR USUBJID WITH SSN AND USUBJID WITH PATID

   USUBJID       SSN       PATID

   Alfred     243811161    08948  **  dups
   Alfred     243811161    08948  **

   Alice      383193716    09794  **  dups
   Alice      383193716    09794  **

   Barbara    257581089    08827
   Carol      036299670    10762
   Henry      445828345    14317


 EXAMPLE OUTPUT
 --------------

  d:/txt/utl_report_on_duplicated_combinations_of_subject_id_and_other_unique_ids.txt


  MEMNAME=HAVTWO      USUBJID=USUBJID      PATID=08827     * Usubjid x Patid is duplicated
  MEMNAME=HAVTWO      USUBJID=USUBJID      SSN=257581089   * Usubjid x SSN   is duplicated

  MEMNAME=HAVTRE      USUBJID=USUBJID      PATID=08948
  MEMNAME=HAVTRE      USUBJID=USUBJID      PATID=09794

  MEMNAME=HAVTRE      USUBJID=USUBJID      SSN=243811161
  MEMNAME=HAVTRE      USUBJID=USUBJID      SSN=383193716


  WORK.LOG total obs=6

   MEMNAME    USUBJID    NAME     RC     STATUS

   HAVONE     USUBJID    PATID     0    Completed   * checked no dups;
   HAVONE     USUBJID    SSN       0    Completed

   HAVTRE     USUBJID    PATID     0    Completed   * checked with dups;
   HAVTRE     USUBJID    SSN       0    Completed

   HAVTWO     USUBJID    PATID     0    Completed
   HAVTWO     USUBJID    SSN       0    Completed


PROCESS  (all the code)
=======================

%utlfkil(d:/txt/utl_report_on_duplicated_combinations_of_subject_id_and_other_unique_ids.txt);

* note mod option allows appending;
filename txt "d:/txt/utl_report_on_duplicated_combinations_of_subject_id_and_other_unique_ids.txt"
    mod lrecl=200 recfm=v;

data log;

  retain memname; retain usubjid "USUBJID";

  * get meta data;
  if _n_ then do;
     %let rc=%sysfunc(dosubl('
        proc contents data= tmp._all_ noprint out= havCon(keep=memname name) ;
        run;quit;
        data _null_;  * prime the pump;
          file txt;
        run;quit;
     '));
  end;

  set havCon(where=(upcase(name) ne 'USUBJID'));
  call symputx('memname',memname);
  call symputx('name',name);

  rc=dosubl('
     proc sort data=tmp.&memname out=_null_ dupout=dups_&memname nodupkey;
       by usubjid &name;
     run;quit;
     data _null_;
       length memname $32.;
       retain usubjid "USUBJID" memname "&memname";
       file txt;
       set dups_&memname(keep=&name);;
       put (_all_) (= $ +5);
     run;quit;
  ');

  if rc=0 then status='Completed';
  else status='Failed';

run;quit;

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;


libname tmp "d:/tmp";

data tmp.havOne tmp.havTwo tmp.havTre ;
  retain usubjid ssn;
  set sashelp.class(obs=5 rename=name=usubjid keep=name );
  ssn=put(_n_+int(1000000000*uniform(1234)),z9.);
  patid=put(_n_+int(100000*uniform(1234)),z5.);
  output tmp.havOne;
  output tmp.havTwo;
  output tmp.havTre;
  if _n_=3 then output tmp.havTwo;
  if _n_=1 then output tmp.havTre;
  if _n_=2 then output tmp.havTre;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

see process

