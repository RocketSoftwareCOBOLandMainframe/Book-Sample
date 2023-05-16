       program-id cli.
       working-storage section.
       78  78-false             value 0.
       78  78-true              value 1.

       01  bool-t               pic x comp-5 typedef.

       01  ws-cmdline-buffer    pic x(256).
       01  ws-cmdline.
           03 ws-cli-i          binary-long.
           03 dog.
               05 dog2          pic xxx.
       01  ws-arg.
           03 ws-arg-len        pic xx comp-5.
           03 ws-arg-buffer     pic x(16).

       01  ws-main-arg-index    pic xx comp-5 value 0.
       01  ws-error             bool-t value 78-false.
       01  ws-show-help         bool-t value 78-true.
       01  ws-command           pic x.
           78 78-command-create value 0.
           78 78-command-list   value 1.
           78 78-command-add    value 2.
           78 78-command-delete value 3.

       01  ws-book-count        pic xxxx comp-5.
       01  ws-temp              binary-long.

      **** The book storage
       copy book-rec replacing ==(prefix)== by ==ws-book==.

      **** Data for calling the book program
       01  ws-function          pic x.
           88 read-record       value "1".
           88 add-record        value "2".
           88 delete-record     value "3".
           88 next-record       value "4".
       01  ws-file-status       pic xx.

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

       01  ws-formatted-number             pic Z(9).

       procedure division.
           display "bookfile" upon environment-name
           display "bookfile.dat" upon environment-value
           perform process-arguments
           evaluate true
           when ws-show-help <> 78-false
               perform show-help
           when ws-error = 78-false
               perform execute-action
           when other
               display 'error occured'
           end-evaluate
           goback
           .

       show-help section.
           display 'A Micro Focus COBOL sample for performing ACID operations on'
           display 'a book repository using standard COBOL file handling.'
           display ' '
           display 'usage: book <command> [<args>] [-f <path>]'
           display '       book create'
           display '       book list'
           display '       book add <title> <author> <genre>'
           display '       book delete <id>'
           display ' '
           display 'options:'
           display '  -f <path>          Path of the book storage file.'
           .

       process-arguments section.
           accept ws-cmdline-buffer from command-line
           move 1 to ws-cli-i
           perform until exit
               move 0 to ws-arg-len
               unstring ws-cmdline-buffer delimited by ' '
                 into ws-arg-buffer count in ws-arg-len
                 with pointer ws-cli-i
               end-unstring
               if ws-arg-len = 0 or ws-error <> 78-false
                   exit perform
               else
                   perform process-argument
               end-if
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
                   when 'create'
                       move 78-command-create to ws-command
                   when 'list'
                       move 78-command-list to ws-command
                   when 'add'
                       move 78-command-add to ws-command
                   when 'delete'
                       move 78-command-delete to ws-command
                   when other
                       move 78-true to ws-error
                       display 'unknown command'
                   end-evaluate
                   move 78-false to ws-show-help
               else
                   evaluate ws-command
                   when 78-command-add
                       evaluate ws-main-arg-index
                       when 1
                           move ws-arg-buffer to ws-book-title
                       when 2
                           move ws-arg-buffer to ws-book-author
                       when 3
                           move ws-arg-buffer to ws-book-type
                       when other
                           display 'unexpected argument'
                       end-evaluate
                   when 78-command-delete
                       if ws-main-arg-index = 1
                           if function length (function trim (ws-arg-buffer trailing)) <> 4
                               move 78-true to ws-error
                               display 'invalid book id'
                           else
                               move ws-arg-buffer to ws-book-stockno
                           end-if
                       else
                           move 78-true to ws-error
                           display 'unexpected argument'
                       end-if
                   end-evaluate
               end-if
               add 1 to ws-main-arg-index
           end-if
           .

       execute-action section.
           evaluate ws-command
           when 78-command-create
               display 'Creating new book repository'
           when 78-command-add
               if ws-main-arg-index <> 4
                   display 'not enough arguments supplied'
               end-if

               display 'Adding ' function trim (ws-book-title) " by " function trim (ws-book-author)
               move function random (0) to ws-temp
               move function random () to ws-temp
               display ws-temp
               compute ws-temp = function mod (ws-temp, 10000)
               move ws-temp to ws-book-stockno
               display ws-temp
               display ws-book-stockno
               move 9.99 to ws-book-retail
               move 100 to ws-book-onhand
               move 0 to ws-book-sold

               move "2" to ws-function
               call "book" using by value ws-function
                                 by reference ws-book-details
                                 by reference ws-file-status
               display ws-book-details
               display ws-file-status
           when 78-command-list
               display ws-formatted-book-rule
               display ws-formatted-book-columns
               display ws-formatted-book-rule
               move 0 to ws-book-count
               move "0000" to ws-book-stockno
               perform until exit
                   move "4" to ws-function
                   call "book" using by value ws-function
                                     by reference ws-book-details
                                     by reference ws-file-status
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
               display ws-formatted-book-rule
               move ws-book-count to ws-formatted-number
               display 'Total books: ' function trim (ws-formatted-number)
           when 78-command-delete
               display 'Deleting book ' ws-book-stockno
           end-evaluate
           .

       end program.
