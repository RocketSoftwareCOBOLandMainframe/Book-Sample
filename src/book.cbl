      ******************************************************************
      *
      * (C) Copyright 2010-2024 Rocket Software, Inc. or one of its affiliates. All Rights Reserved.
      *
      * This sample code is supplied for demonstration purposes only
      * on an "as is" basis and is for use at your own risk.
      *
      ******************************************************************

       program-id BookLegacy.

       environment division.
       input-output section.
       file-control.
           select bookfile assign to external bookfile
               file status is ls-file-status
               organization is indexed
               access mode is dynamic
               record key is b-stockno
               alternate record key is b-title with duplicates
               alternate record key is b-author with duplicates
               .

       data division.
       file section.
       fd bookfile.
       copy "book-rec.cpy" replacing ==(prefix)== by ==b==.

       working-storage section.
       01 ls-file-status   pic xx.
       01 ls-call-status   pic x(2) comp-5.

       linkage section.
       01 lnk-function       pic x.
           88 read-record    value "1".
           88 add-record     value "2".
           88 delete-record  value "3".
           88 next-record    value "4".
       01 lnk-file-status    pic xx.
       copy "book-rec.cpy" replacing ==(prefix)== by ==lnk-b==.


       procedure division using by value lnk-function
                                by reference lnk-b-details
                                by reference lnk-file-status.
       main section.

           call "CBL_TOUPPER" using lnk-b-text-details
                           by value length lnk-b-text-details
                           returning ls-call-status

           evaluate true
               when read-record
                   perform do-read-record

               when add-record
                   perform do-add-record

               when delete-record
                   perform do-delete-record

               when next-record
                   perform do-next-record

           end-evaluate
           exit program
           stop run
           .

       do-read-record section.
           open input bookfile
           if ls-file-status <> "00"
               initialize lnk-b-details
               move all '*' to lnk-b-text-details

               move ls-file-status to lnk-file-status
               exit section
           end-if
           evaluate true
               when lnk-b-stockno <> spaces
                   move lnk-b-stockno to b-stockno
                   read bookfile

               when lnk-b-title <> spaces
                   move lnk-b-title  to b-title
                   read bookfile key is b-title

               when lnk-b-author <> spaces
                   move lnk-b-author to b-author
                   read bookfile key is b-author

              when other
      *>-----------No key specified - return unsuccessful read
                   move "23" to ls-file-status

           end-evaluate
           move ls-file-status to lnk-file-status
           if ls-file-status = "00"
               move b-title to lnk-b-title
               move b-type to lnk-b-type
               move b-author to lnk-b-author
               move b-stockno to lnk-b-stockno
               move b-retail to lnk-b-retail
               move b-onhand to lnk-b-onhand
               move b-sold to lnk-b-sold
           else
               initialize lnk-b-details
               move all '*' to lnk-b-text-details
           end-if
           close bookfile
           .

       do-next-record section.
           open input bookfile
           if ls-file-status <> "00"
               initialize lnk-b-details
               move all '*' to lnk-b-text-details

               move ls-file-status to lnk-file-status
               exit section
           end-if

           move lnk-b-stockno to b-stockno
           start bookfile key > b-stockno
           read bookfile next

           move ls-file-status to lnk-file-status
           if ls-file-status = "00"
               move b-title to lnk-b-title
               move b-type to lnk-b-type
               move b-author to lnk-b-author
               move b-stockno to lnk-b-stockno
               move b-retail to lnk-b-retail
               move b-onhand to lnk-b-onhand
               move b-sold to lnk-b-sold
           else
               initialize lnk-b-details
               move all '*' to lnk-b-text-details
           end-if
           close bookfile
           .

       do-add-record section.
           open i-o bookfile
           evaluate ls-file-status
               when "05"
      *>-------File not created yet
               when "00"
                   continue

               when other
                   move ls-file-status to lnk-file-status
                   exit section
           end-evaluate

           move lnk-b-stockno   to b-stockno
           read bookfile
           if ls-file-status = "00"
      * Record already exists - so error
               move "99" to ls-file-status
           else
               move lnk-b-title  to b-title
               move lnk-b-type   to b-type
               move lnk-b-author to b-author
               move lnk-b-retail to b-retail
               move lnk-b-onhand to b-onhand
               move lnk-b-sold   to b-sold
               write b-details
           end-if

           move ls-file-status to lnk-file-status
           close bookfile
           .

       do-delete-record section.
           open i-o bookfile
           if ls-file-status <> "00"
               move ls-file-status to lnk-file-status
               exit section
           end-if

           evaluate true
               when lnk-b-stockno <> spaces
                   move lnk-b-stockno to b-stockno
                   read bookfile
                   delete bookfile record

               when lnk-b-title <> spaces
                   move lnk-b-title to b-title
                   read bookfile key is b-title
                   delete bookfile record

               when lnk-b-author <> spaces
                   move lnk-b-author to b-author
                   read bookfile key is b-author
                   delete bookfile record

              when other
      *>------------No key specified - return unsuccessful read
                   move "23" to ls-file-status

           end-evaluate

           move ls-file-status to lnk-file-status
           close bookfile
           .
