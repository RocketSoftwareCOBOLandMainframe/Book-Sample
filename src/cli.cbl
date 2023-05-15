       program-id cli.
       working-storage section.
       01  ws-cmdline-buffer   pic x(256).
       01  ws-cmdline.
           03 ws-cli-i         binary-long.
       01  ws-output           pic x(16).
       01  ws-output-len       binary-long.
       procedure division.
           accept ws-cmdline-buffer from command-line
           move 1 to ws-cli-i
           perform until exit
               move 0 to ws-output-len
               unstring ws-cmdline-buffer delimited by ' '
                   into ws-output count in ws-output-len
                   with pointer ws-cli-i
               end-unstring
               if ws-output-len = 0
                   exit perform
               else
                   display '<' ws-output(1:ws-output-len) '>'
               end-if
           end-perform
           .

       read-arguments section.
           
           .

       end program.
