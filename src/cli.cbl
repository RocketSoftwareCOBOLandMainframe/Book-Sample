      ******************************************************************
      *
      * (C) Copyright 2023 Micro Focus or one of its affiliates.
      *
      * This sample code is supplied for demonstration purposes only
      * on an "as is" basis and is for use at your own risk.
      *
      ******************************************************************

       program-id cli.
       working-storage section.
       78  78-false                value 0.
       78  78-true                 value 1.

       01  bool-t                  pic x comp-5 typedef.

       01  ws-cmdline-buffer       pic x(256).
       01  ws-arg.
           03 ws-arg-len           pic xx comp-5.
           03 ws-arg-buffer        pic x(64).

       01  ws-main-arg-index       pic xx comp-5 value 0.
       01  ws-error                bool-t value 78-false.
       01  ws-show-help            bool-t value 78-true.
       01  ws-command              pic x.
           78 78-command-list          value 0.
           78 78-command-add           value 1.
           78 78-command-delete        value 2.
       01  ws-error-text           pic x(256).
           78 78-err-text-unexpected-arg   value "invalid argument".
           78 78-err-text-not-enough-args  value "not enough arguments supplied".
           78 78-err-text-unknown-command  value "unknown command".

       01  ws-add-book-title       pic x(50).
       01  ws-add-book-type        pic x(20).
       01  ws-add-book-author      pic x(50).
       01  ws-book-count           pic xxxx comp-5.
       01  ws-next-stockid-result  pic 9999 comp-5.
       01  ws-temp                 binary-long.

      **** The book storage
       copy book-rec replacing ==(prefix)== by ==ws-book==.

      **** Data for calling the book program
       01  ws-function             pic x.
           88 read-record              value "1".
           88 add-record               value "2".
           88 delete-record            value "3".
           88 next-record              value "4".
       01  ws-file-status          pic xx.

      **** Strings used for displaying the list of books
       01  ws-formatted-book-columns
           value "ID   NAME                          AUTHOR               PRICE STOCK SOLD" constant.

       01  ws-formatted-book-rule
           value "------------------------------------------------------------------------" constant.

       01  ws-formatted-book.
           03 ws-formatted-book-stockno    pic xxxx.
           03                              value ' '.
           03 ws-formatted-book-name       pic x(30).
           03 ws-formatted-book-author     pic x(20).
           03                              value "$".
           03 ws-formatted-book-retail     pic 99.99.
           03                              value " ".
           03 ws-formatted-book-stock      pic ZZZZ9.
           03                              value " ".
           03 ws-formatted-book-sold       pic ZZZ9.

       01  ws-formatted-number             pic Z(8)9.

       procedure division.
           perform process-arguments
           evaluate true
           when ws-show-help <> 78-false
               perform show-help
           when ws-error = 78-false
               perform execute-command
           when other
           end-evaluate
           if ws-error <> 78-false
               display ws-error-text
           end-if
           goback
           .

       show-help section.
           display 'A Micro Focus COBOL sample for performing ACID operations on'
           display 'a book repository using standard COBOL file handling.'
           display ' '
           display 'usage: book <command> [<args>] [-f <path>]'
           display '       book list'
           display '       book add <title> <author> <genre>'
           display '       book delete <id>'
           display ' '
           display 'options:'
           display '  -f <path>          Path of the book storage file.'
           .

       process-arguments section.
           perform until ws-error <> 78-false
               accept ws-cmdline-buffer from argument-value
               on exception
                   exit perform
               not on exception
                   move 0 to ws-arg-len
                   if ws-cmdline-buffer(1:1) = quote
                       perform varying ws-temp from 2 by 1 until ws-temp > length of ws-cmdline-buffer
                           if ws-cmdline-buffer(ws-temp:1) = quote
                               exit perform
                           end-if
                           add 1 to ws-arg-len
                       end-perform
                       move ws-cmdline-buffer(2:ws-arg-len) to ws-arg-buffer
                   else
                       inspect ws-cmdline-buffer tallying ws-arg-len for characters before ' '
                       move ws-cmdline-buffer(1:ws-arg-len) to ws-arg-buffer
                   end-if
                   perform process-argument
               end-accept
           end-perform
           .

       process-argument section.
           if ws-arg-len = 0
               exit section
           end-if
           if ws-arg-buffer(1:1) = '-'
               *> Option
           else
               if ws-main-arg-index = 0
                   evaluate ws-arg-buffer
                   when 'list'
                       move 78-command-list to ws-command
                   when 'add'
                       move 78-command-add to ws-command
                   when 'delete'
                       move 78-command-delete to ws-command
                   when other
                       move 78-err-text-unknown-command to ws-error-text
                       move 78-true to ws-error
                   end-evaluate
                   move 78-false to ws-show-help
               else
                   evaluate ws-command
                   when 78-command-add
                       evaluate ws-main-arg-index
                       when 1
                           move ws-arg-buffer to ws-add-book-title
                       when 2
                           move ws-arg-buffer to ws-add-book-author
                       when 3
                           move ws-arg-buffer to ws-add-book-type
                       when other
                           move 78-err-text-unexpected-arg to ws-error-text
                           move 78-true to ws-error
                       end-evaluate
                   when 78-command-delete
                       if ws-main-arg-index = 1
                           if function length (function trim (ws-arg-buffer trailing)) <> 4
                               move 'invalid book id' to ws-error-text
                               move 78-true to ws-error
                           else
                               move ws-arg-buffer to ws-book-stockno
                           end-if
                       else
                           move 78-err-text-unexpected-arg to ws-error-text
                           move 78-true to ws-error
                       end-if
                   end-evaluate
               end-if
               add 1 to ws-main-arg-index
           end-if
           .

       execute-command section.
           display "bookfile" upon environment-name
           display "bookfile.dat" upon environment-value
           evaluate ws-command
           when 78-command-add
               perform add-book
           when 78-command-list
               perform list-books
           when 78-command-delete
               perform delete-book
           end-evaluate
           .

       list-books section.
           display ws-formatted-book-rule
           display ws-formatted-book-columns
           display ws-formatted-book-rule
           move 0 to ws-book-count
           move "0000" to ws-book-stockno
           perform until exit
               set next-record to true
               perform call-book
               if ws-file-status = "00"
                   move ws-book-stockno to ws-formatted-book-stockno
                   move ws-book-title to ws-formatted-book-name
                   move ws-book-author to ws-formatted-book-author
                   move ws-book-retail to ws-formatted-book-retail
                   move ws-book-onhand to ws-formatted-book-stock
                   move ws-book-sold to ws-formatted-book-sold
                   add 1 to ws-book-count
                   display ws-formatted-book
               else
                   exit perform
               end-if
           end-perform
           if ws-book-count = 0
               move 78-true to ws-error
               move 'No books exist' to ws-error-text
           end-if
           display ws-formatted-book-rule
           move ws-book-count to ws-formatted-number
           display 'Total books: ' function trim (ws-formatted-number)
           .

       add-book section.
           if ws-main-arg-index <> 4
               move 78-err-text-not-enough-args to ws-error-text
               move 78-true to ws-error
               exit section
           end-if

           perform find-next-stockid
           move ws-next-stockid-result to ws-book-stockno

           move ws-add-book-title to ws-book-title
           move ws-add-book-type to ws-book-type
           move ws-add-book-author to ws-book-author
           move 9.99 to ws-book-retail
           move 100 to ws-book-onhand
           move 0 to ws-book-sold

           set add-record to true
           perform call-book
           if ws-file-status = '00' or ws-file-status = "02"
               display 'Added ' function trim (ws-add-book-title) " by " function trim (ws-add-book-author)
           else
               move 78-true to ws-error
               move 'Failed to add book' to ws-error-text
           end-if
           .

       delete-book section.
           if ws-main-arg-index <> 2
               move 78-err-text-not-enough-args to ws-error-text
               move 78-true to ws-error
               exit section
           end-if
           set read-record to true
           perform call-book
           set delete-record to true
           perform call-book
           display 'Deleted ' function trim (ws-book-title) " by " function trim (ws-book-author)
           .

       find-next-stockid section.
           *> Find next available stock ID from 1000 onwards
           move 999 to ws-next-stockid-result
           move ws-next-stockid-result to ws-book-stockno
           perform until exit
               set next-record to true
               perform call-book
               if ws-file-status = "00"
                   add 1 to ws-next-stockid-result
                   if ws-book-stockno <> ws-next-stockid-result
                       *> Next book did not match next the stock ID we
                       *> tested, so it must be available
                       exit perform
                   end-if
               else
                   *> Assume stock ID is available
                   add 1 to ws-next-stockid-result
                   exit perform
               end-if
           end-perform
           .

       call-book section.
           call "book" using by value ws-function
                             by reference ws-book-details
                             by reference ws-file-status
           .

       end program.
