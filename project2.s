.data
        input_str:        .space      1001                   # Preallocate space for 1000 characters and the null string
        invalid:          .asciiz     "Invalid Input"        # Store and null-terminate the string to be printed for invalid inputs
        null_char:        .byte       0                      # Allocate byte in memory for null char
        space_char:       .byte       32                     # Allocate byte in memory for space char
        tab_char:         .byte       9                      # Allocate byte in memory for tab char
        nl_char:          .byte       10                     # Allocate byte in memory for newline char
.text
        main:
              li $v0, 8                            # Systemcall to get the user's input
              la $a0, input_str                    # Load register with the address of the input string
              li $a1, 1001                         # Read maximum of 1001 characters from user input (including null character)
              syscall

              # Load $s1 - $s4 registers with the null, newline, space and tab chars respectively
              lb $s1, null_char
              lb $s2, nl_char
              lb $s3, space_char
              lb $s4, tab_char

              la $s0, input_str                    # Load register with address of user input

              add $t0, $zero, $zero                # Initialize counter to zero
              add $t3, $zero, $zero                # Initalize counter to zero

              # This subroutine is used to check for leading spaces and eliminate them by adjusting the start index of the string appropriately
              Loop1:
                    add $t1, $t0, $s0                    # Get the current character's address
                    lb $t2, 0($t1)                       # Load register $t2 with the current character
                    beq $t2, $s1, PrintInvalid           # If current char is the null char, the string is empty. Therefore, invalid
                    beq $t2, $s2, PrintInvalid           # If current char is the newline char, the string is empty. Therefore, invalid
                    bne $t2, $s3, CheckTab               # If the current char is not a space character, go to subroutine to check if it's a tab
                    addi $t0, $t0, 1                     # If the current char is a space, increment $t0 to check next character
                    j Loop1                              # Jump back to beginning of the loop

              # This subroutine checks if the current chacter is a tab only when it is not a space
              CheckTab:
                    bne $t2, $s4, SetStartIndex          # If the current char is not a tab, then set char as the start index
                    addi $t0, $t0, 1                     # Else, increment the $t0 register to check for spaces and/or tabs in the next character
                    j Loop1                              # Jump back to Loop1 to check next character

              # This subroutine sets the set index after looping through all leading spaces and tabs
              SetStartIndex:
                    add $s5, $t0, $zero                  # Load register $s5 with index of first character that is not a space/tab
                    j Loop2                              # Jump to loop 2 to check for the end of the string

              # This subroutine prints the string "Invalid Input" for invalid user inputs.
              PrintInvalid:
                    li $v0, 4                            # Load register with immediate 4 to print a string
                    la $a0, invalid                      # Load address $a0 with the memory address of the string labeled 'invalid'
                    syscall

                    # j Exit

                # This subroutine checks for the index of the last character in the string by checking for the null or newline characters
                Loop2:
                    add $t4, $s5, $s0                    # Get current char's address starting from new start index
                    lb $t2, 0($t4)                       # Load register $t2 with the current char
                    beq $t2, $s1, StringEnd              # If the current char is the null char, go to StringEnd
                    beq $t2, $s2, StringEnd              # If the current char is the newline char, go to StringEnd
                    addi $t4, $t4, 1                     # Increment counter to check next character
                    j Loop2                              # Restart Loop

                # This subroutine keeps track of the end of string
                StringEnd:
                    add $t6, $t2, $zero                  # Load the $t6 register with the index at the end of string
                    j Loop3                              # Jump to Loop 3 to skip trailing space and tab characters

                # This subroutine skips trailing spaces and tabs in input string iterating backwards from the index calculated at StringEnd
                Loop3:
                    add $t5, $t6, $s0                    # Get last char in the string
                    lb $t2, 0($t5)                       # Load the register with the last char in the string
                    bne $t2, $s3, CheckTab2              # If current char is not a space char, check if it is a tab char

                #This subroutine checks if the current char is a tab if it is not a space. Used for eliminating trailing tabs
                CheckTab2:
                    bne $t2, $s4, SetEndIndex             # If current char is also not a tab, set as end index for string
                    addi $t6, $t6, -1                     # Decrement register storing the end of the string by -1
