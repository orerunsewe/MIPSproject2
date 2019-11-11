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

              # This subroutine sets the start index after looping through all leading spaces and tabs
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
                    addi $t6, $t6, -1                    # Decrement last char in string by 1 to keep checking for non space/tab char

                    j Loop3                              # Restart Loop

                # This subroutine checks if the current char is a tab if it is not a space. Used for eliminating trailing tabs
                CheckTab2:
                    bne $t2, $s4, SetEndIndex             # If current char is also not a tab, set as end index for string
                    addi $t6, $t6, -1                     # Decrement register storing the end of the string by -1

                    j Loop3                               # Jump back to Loop3

                # This subroutine sets the end index after looping through all trailing spaces and tabs
                SetEndIndex:
                    add $s6, $t6, $zero                   # Store the end index in register $s6
                    j Initialize                          # Jump to Loop4

                # This subroutine initializes registers to be used in Loop4
                Initialize:
                add $t0, $zero, 1                         # Initialize $t3 to 1. Will be incremented by x30 in Loop4
                addi $t1, $zero, 30                       # Load register $t7 with immediate 30 for calculations in Loop4
                add $s7, $zero, $zero                     # Initialize register $s7 for sum to calculate decimal value

                j Loop4

                # This subroutine loops through each character and does the calculations to determine whether the string is invalid or valid
                # If the string is invalid, the string "Invalid Input" is printed and the program exits
                # If the string is valid, it is converted to its decimal value in this subroutine
                Loop4:
                add $t7, $s6, $s0                         # Start reading characters for conversion from the end index in register $s6
                lb $a2, 0($t7)                            # Load register $a2 with current character
                jal ConvertCharToDecimal                  # Jump to subroutine to convert current char then return to next instruction
                mult $t0, $v1                             # Multiply decimal value of char by 30^n where n char position starting from the right at 0
                mflo $t8                                  # Move result from multiplication to the $t8 register
                add $s7, $s7, $t8                         # Add result to the sum
                


                #This subroutine is used to convert the string characters to their corresponding decimal values, treating each character as a base-N number
                # Conversions done based on formula N = 26 + (X % 11) where X is my StudentID: 02805400
                # N = 30 so valid range is from 'a' to 't' or 'A' to 'T'
                # Characters '0' to '9' correspond to a decimal value of 0 to 9 respectively
                # Characters 'a' to 't' correspond to a decimal value of 10 to 29 respectively
                # Characters 'A' to 'T' correspond to a decimal value of 10 to 29 respectively
                # All other characters are out of range and correspond to a decimal value 0
                # Register $a2 contains current character in the string
                ConvertCharToDecimal:
                add $t2, $zero, $a2                       # Copy character at $a2 to temporary register $t2
                addi $t3, $zero, 87                       # Load $t3 with reference value 87 (ascii value of 'a' - 10) for conversion
                bgt $t2, 't', PrintInvalid                # If current character is greater than 't', it is out of range. PrintInvalid
                bge $t2, 'a', Return1                     # If current character is between 'a' and 't', go to Return1 to convert
                addi $t3, $zero, 55                       # Change reference value to 55 for uppercase characters
                bgt $t2, 'T', PrintInvalid                # If current character is greater than 'T', it is out of range. Go to PrintInvalid
                bge $t2, 'A', Return1                     # If current character is between 'A' and 'T', go to Return1 to convert
                addi $t3, $zero, 48                       # Change reference value to 48 for numbers
                bgt $t2, '9', PrintInvalid                # If current character is greater than '9' it is out of range. Go to PrintInvalid
                bge $t2, '0', Return1                     # If current char is between '0' and '9', go to Return1 to convert
                blt $t2, '0', PrintInvalid                # For all other characters out of the range, go to PrintInvalid

                # This subroutine calculates the decimal value of the character
                # The result is returned in $v1
                Return1:
                sub $v1, $t2, $t3         # subtract the the reference value in $t3 from the character's 1-byte ascii value
                jr $ra                    # Return the decimal value in $v1 to Loop4
