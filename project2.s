.data
        input_str:  .space      1001                   # Preallocate space for 1000 characters and the null string
        invalid:    .asciiz     "Invalid Input"        # Store and null-terminate the string to be printed for invalid inputs


.text
        main:
              li $v0, 8                            # Systemcall to get the user's input
              la $a0, input_str                    # Load register with the address of the input string
              li $a1, 1001                         # Read maximum of 1001 characters from user input (including null character)
              syscall

              la $s0, input_str                    # Load register with address of user input
              add $t0, $zero, $zero                # Initialize counter to zero

              # This subroutine is used to check for leading spaces and eliminate them by adjusting the start index of the string appropriately
              Loop1:
                    add $t1, $t0, $s0                    # Get the current character's address
                    lb $t2, 0($t1)                       # Load register $t2 with the current character
                    beq $t2, 0, PrintInvalid             # If current char is the null char, the string is empty. Therefore, invalid
                    beq $t2, 10, PrintInvalid            # If current char is the newline char, the string is empty. Therefore, invalid
                    bne $t2, 32, CheckTab                # If the current char is not a space character, go to subroutine to check if it's a tab
                    addi $t0, $t0, 1                     # If the current char is a space, increment $t0 to check next character
                    j Loop1                              # Jump back to beginning of the loop

              CheckTab:
                    bne $t2, 9, SetStartIndex            # If the current char is not a tab, then set char as the start index
                    addi $t0, $t0, 1                     # Else, increment the $t0 register to check for spaces and/or tabs in the next character
                    j Loop1                              # Jump back to Loop1 to check next character

              SetStartIndex:
                    add $t3, $t0, $zero                  # Load register $t3 with index of first character that is not a space/tab
