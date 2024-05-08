import numpy as np


def expand_matrix(input_matrix, target_rows, target_columns):
    """
    Expands a given input matrix to a specified size, filling the new elements with zeros. This function
    preserves the original content of the input matrix in the top-left corner of the expanded matrix, and
    fills any additional rows and columns with zeros.

    :param input_matrix: The matrix to be expanded. It is a list of lists where each inner list represents a row.
    :param target_rows: The desired number of rows in the output matrix.
    :param target_columns: The desired number of columns in the output matrix.
    :return: The expanded matrix as a list of lists, with the new size determined by target_rows and target_columns.
             If the target size is smaller than the original size in any dimension, the output will still match the
             target size, but with the original content truncated to fit.
    """
    output_matrix = [[0] * target_columns for _ in range(target_rows)]

    for i in range(len(input_matrix)):
        for j in range(len(input_matrix[i])):
            output_matrix[i][j] = input_matrix[i][j]

    return output_matrix


def BintoHex(binstr: str) -> str:
    """
    Converts a binary string representation to its hexadecimal string equivalent. The function first interprets
    the input string as a binary number and then converts this number into a hexadecimal representation. The
    hexadecimal string is prefixed with '0x' to indicate that it is in hexadecimal format.

    :param binstr: A string representing a binary number (e.g., '1011'). The string should only contain '0's and '1's.
    :return: A string representing the hexadecimal equivalent of the input binary number. This string is prefixed
             with '0x' to indicate hexadecimal format (e.g., '0xb' for the binary '1011').
    """
    integer_num = int(binstr, 2)
    hex_string = hex(integer_num)
    return hex_string


def HextoBin(hexstr: str) -> str:
    integer_num = int(hexstr, 16)
    binary_string = bin(integer_num)[2:]  # [2:] is used to remove the '0b' prefix
    return binary_string


def string_to_binary(input_string):
    """
    Converts a string of text into its binary representation. Each character in the input string is converted to its
    ASCII value, which is then converted to a binary string. These binary strings are concatenated to form the final
    binary representation of the entire input string. Each character's binary representation is ensured to be 8 bits
    long, with leading zeros added if necessary to reach 8 bits.

    This method treats the input string as a sequence of characters, where each character is independently converted
    to its binary form based on its ASCII value. This means that the function supports the full range of ASCII characters,
    including letters, digits, and special characters.

    :param input_string: The string to be converted into binary. This can include any characters that are representable
                         in the ASCII character set.
    :return: A single string representing the binary form of the input string. Each character's binary representation
             is concatenated without any separators, resulting in a continuous string of '0's and '1's.
    """
    binary_string = ""
    for char in input_string:
        # Get ASCII value of the character
        ascii_value = ord(char)
        # Convert ASCII value to binary and remove the '0b' prefix
        binary_representation = bin(ascii_value)[2:]
        # Ensure each binary representation is 8 characters long by padding with zeros if necessary
        binary_representation = binary_representation.zfill(8)
        # Append the binary representation to the binary string
        binary_string += binary_representation
    return binary_string


def write_Mat_to_file(file_mat, Mat, delimiter=','):
    for row in Mat:
        file_mat.write(delimiter.join(map(str, row)))
        file_mat.write('\n')
    file_mat.write("-" * 100)


def write_SP_to_file(file_SP, SP_Arr, delimiter=','):
    for Mat in SP_Arr:
        for row in Mat:
            file_SP.write(delimiter.join(map(str, row)))
            file_SP.write('\n')
        file_SP.write('\n')
    file_SP.write("-" * 100)


def ReadModeBit(ControlReg_Str_reverse):
    return ControlReg_Str_reverse[::-1][1]


def WriteReadTarget(ControlReg_Str_reverse):
    ControlReg_Str = ControlReg_Str_reverse[::-1]
    WriteTarget = (ControlReg_Str[2:4])[::-1]
    ReadTarget = (ControlReg_Str[4:6])[::-1]
    return [WriteTarget, ReadTarget]


def ReadNKM(ControlReg_Str_reverse):
    ControlReg_Str = ControlReg_Str_reverse[::-1]
    N_str = (ControlReg_Str[8:10])[::-1]
    K_str = (ControlReg_Str[10:12])[::-1]
    M_str = (ControlReg_Str[12:14])[::-1]

    # print("this is N_str", N_str)
    # print("this is K_str", K_str)
    # print("this is M_str", M_str)

    N = int(N_str, 2) + 1
    K = int(K_str, 2) + 1
    M = int(M_str, 2) + 1

    # print("this is read N", N)
    # print("this is read K", K)
    # print("this is read M", M)

    return [N, K, M]


def generate_random_binary(length):
    return ''.join(str(np.random.choice([0, 1])) for i in range(length))


def multiply_matrices(A, B, SP_Arr, ControlReg_Str_reverse, file_param, Max_Dim, file_mat_res, file_SP, Test):
    N, K, M = ReadNKM(ControlReg_Str_reverse)
    mode_bit = ReadModeBit(ControlReg_Str_reverse)
    WriteTarget, ReadTarget = WriteReadTarget(ControlReg_Str_reverse)
    WriteSP = int(WriteTarget, 2)
    ReadSP = int(ReadTarget, 2)

    file_param.write(f"\nControl Register Random in Test {Test + 1}:\n")
    file_param.write(f"N = {N}, K = {K}, M = {M}\n")
    file_param.write(f"mode bit = {mode_bit}\n")
    file_param.write(f"WriteSP = {WriteSP}, ReadSP = {ReadSP}\n")

    if mode_bit == '1':
        C = SP_Arr[ReadSP]
    else:
        C = np.zeros((Max_Dim, Max_Dim))
    temp_res = np.dot(A, B)
    res_padd = expand_matrix(temp_res, Max_Dim, Max_Dim)
    new_res = C + res_padd
    SP_Arr[WriteSP] = new_res

    # Write matrices to files
    file_mat_res.write(f"\nMat Res in Test {Test + 1} is: \n\n")
    write_Mat_to_file(file_mat_res, new_res)
    file_SP.write(f"\nScratchPad in Test {Test + 1} is: \n\n")
    write_SP_to_file(file_SP, SP_Arr)

    return SP_Arr


def writecontrolreg(ControlRegStr, instrections, BusWidth, AddressWidth, pstrb_i):
    pwdata_i = int(ControlRegStr, 2)
    paddr_i = 0
    instrections.write(f"{pwdata_i},{paddr_i},{pstrb_i}\n")


def controlreg(Max_Dim: int, SPN: int) -> str:
    N = np.random.randint(Max_Dim)
    K = np.random.randint(Max_Dim)
    M = np.random.randint(Max_Dim)

    # N = 1
    # K = 1
    # M = 1
    # print("N normal Rand is: ", N +1)
    # print("K normal Rand is: ", K + 1)
    # print("M normal Rand is: ", M + 1)

    ControlReg = 0b0

    # Set the start bit (bit 0)
    ControlReg |= (0b0)

    # Set the mode bit (bit 1)
    ControlReg |= (np.random.randint(2) << 1)

    # Set the write target bits (bits 2 to 3)
    ControlReg |= (np.random.randint(SPN) << 2)

    # Set the read target bits (bits 4 to 5)
    ControlReg |= (np.random.randint(SPN) << 4)

    # Not in use (bits 6 to 7)
    ControlReg |= (0b00 << 6)

    # Dimension N (bits 8 to 9)
    ControlReg |= (N << 8)

    # Dimension K (bits 10 to 11)
    ControlReg |= (K << 10)

    # Dimension M (bits 12 to 13)
    ControlReg |= (M << 12)

    # Not in use (bits 14 to 15)
    ControlReg |= (0b11 << 14)

    # Print the binary representation of ControlReg
    ControlReg_Str = bin(ControlReg)[2:].zfill(16)
    return ControlReg_Str

def safe_multiply_and_add(value, multiplier, shift, DataWidth):
    """
    Safely multiplies `multiplier` by 2 raised to the power of (`shift` times `DataWidth`),
    and adds it to `value` to prevent overflow.
    """
    # Convert to a higher precision data type to prevent overflow
    result = np.int64(value) + np.int64(multiplier) * (2 ** (shift * DataWidth))
    return result

def main():
    instrections = open('instrections.txt', 'w')
    file_param = open('Param_File.txt', 'w')
    file_mat_res = open('Mat_Res.txt', 'w')
    file_SP = open('SP.txt', 'w')
    file_mat_A = open('Mat_A.txt', 'w')
    file_mat_B = open('Mat_B.txt', 'w')



    # Parmeters UnRandomised
    BusWidth = 32
    DataWidth = 8
    AddressWidth = 16
    SPN = 4
    Max_Dim = BusWidth // DataWidth  # 2

    SP_Arr = [np.zeros((Max_Dim, Max_Dim)) for i in range(SPN)]
    file_SP.write(f"\nScratchPad Before Tests: \n\n")
    write_SP_to_file(file_SP, SP_Arr)
    Num_Tests = 100

    file_param.write(f"\nNumbers of Tests: {Num_Tests}\n")
    file_param.write("\n" + "*" * 100 + "\n")
    file_param.write(f"\nParmeters of Design:\n")
    file_param.write(f"BusWidth = {BusWidth}, DataWidth = {DataWidth}\n")
    file_param.write(f"AddressWidth = {AddressWidth}, SPN = {SPN}\n")
    file_param.write(f"Max_Dim = {Max_Dim}\n")
    file_param.write("\n" + "*" * 100 + "\n")

    # Signals Bus
    pwdata_i = ""
    paddr_i = ""
    pstrb_i = "1" * Max_Dim
    pstrb_i = int(pstrb_i,2)

    for Test in range(Num_Tests):
        # Generate random matrices A and B
        ControlRegStr = controlreg(Max_Dim, SPN)
        # print(ControlRegStr)
        writecontrolreg(ControlRegStr, instrections, BusWidth, AddressWidth, pstrb_i)
        ControlRegStr_Start_Bit = ControlRegStr[:-1] + '1'
        # print(ControlRegStr_Start_Bit)

        N, K, M = ReadNKM(ControlRegStr)
        A = np.random.randint(-2 ** (DataWidth - 1), 2 ** (DataWidth - 1) - 1, size=(N, K))
        B = np.random.randint(-2 ** (DataWidth - 1), 2 ** (DataWidth - 1) - 1, size=(K, M))

        # A = [[1,2],
        #      [3,4]]

        # B = [[1,1],
        #      [1,1]]

        file_mat_A.write(f"\nMat A Random in Test {Test + 1} is: \n\n")
        write_Mat_to_file(file_mat_A, A)

        file_mat_B.write(f"\nMat B Random in Test {Test + 1} is: \n\n")
        write_Mat_to_file(file_mat_B, B)

        SP_Arr = multiply_matrices(A, B, SP_Arr, ControlRegStr, file_param, Max_Dim, file_mat_res, file_SP, Test)

        # Write for design in random
        row_A = [i for i in range(N)]
        row_B = [i for i in range(K)]
        Addr_Mat = np.random.choice([4, 8])
        while (row_A or row_B):
            Addr_Mat = np.random.choice([4, 8])
            writeArrdata = 0  # Use a basic integer, operations will be safely managed by `safe_multiply_and_add`

            if (Addr_Mat == 4 and row_A):
                A_idx = row_A.pop(0)
                Addr_Mat += (A_idx << 5)
                for k in range(K):
                    temp = A[A_idx][k]
                    if (temp < 0):
                        temp += 2 ** DataWidth
                    writeArrdata = safe_multiply_and_add(writeArrdata, temp, k, DataWidth)
                instrections.write(f"{writeArrdata},{Addr_Mat},{pstrb_i}\n")

            elif (Addr_Mat == 8 and row_B):
                B_idx = row_B.pop(0)
                Addr_Mat += (B_idx << 5)
                for m in range(M):
                    temp = B[B_idx][m]
                    if (temp < 0):
                        temp += 2 ** DataWidth
                    writeArrdata = safe_multiply_and_add(writeArrdata, temp, m, DataWidth)
                instrections.write(f"{writeArrdata},{Addr_Mat},{pstrb_i}\n")



        writecontrolreg(ControlRegStr_Start_Bit, instrections, BusWidth, AddressWidth, pstrb_i)
        file_param.write("\n" + "-" * 100 + "\n")

    instrections.close()
    file_param.close()
    file_mat_res.close
    file_SP.close()
    file_mat_A.close()
    file_mat_B.close()
    print("\nFinish Verification Script, Upload instrections.txt to Design\n")


if __name__ == "__main__":
    main()

