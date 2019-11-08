. .data
        input_str:  .space      1001                   # Preallocate space for 1000 characters and the null string
        invalid:    .asciiz     "Invalid Input"        # Store and null-terminate the string to be printed for invalid inputs

.text
        main:
              li $v0, 8                            # Systemcall to get the user's input
              la $a0, input_str                    # Load register with the address of the input string
              li $a1, 1001                         # Read maximum of 1001 characters from user input (including null character)
              syscall
