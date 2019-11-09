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
                    bne $t2, 32, SetStartIndex           # If the current char is not a space character, go to subroutine to set it as start index
