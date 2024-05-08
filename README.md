# Logic-Design-Project-APB-MatrixEngine-
APB-MatrixEngine is a Verilog-based system designed for high-performance matrix calculations. This project aims to provide a robust matrix processing unit that interfaces seamlessly with CPUs using the Advanced Peripheral Bus (APB) protocol. It's ideal for applications requiring efficient matrix operations in hardware acceleration environments.

# Features
Matrix Operations: Supports multiple matrix operations including addition, subtraction, multiplication, and potentially inversion.

APB Interface: Fully compatible with the APB protocol, ensuring smooth communication with the main CPU.

Configurable Dimensions: Supports matrices of configurable dimensions, adaptable for various application needs.

Optimized Performance: Designed for maximum throughput with minimal latency to enhance performance in critical applications.

# Overview of the Systolic Architecture

## Introduction
In this laboratory session, our objective is to design a systolic architecture system that efficiently performs matrix multiplication. The architecture will be either pipelined or non-pipelined, depending on operational requirements. This system utilizes computing elements, known as Processing Elements (PEs), and is optimized to minimize data transitions between the main memory and the processing unit.

## System Design 
The primary focus of our design is to ensure each data element is transferred into the system a single time. This is achieved by effectively storing each element in a specified address within the Register File (RF). Such an approach significantly reduces unnecessary data movement, thus enhancing the computational efficiency.

## Functional Capabilities
The systolic architecture supports two primary modes of matrix multiplication:
### Non-Pipelined Matrix Multiplication: 
      Equation:𝐶=𝐴×𝐵
      Description: This mode performs a straightforward multiplication of matrices A and B. These matrices are located in the
      operand registers, with matrix A stored at addresses 4-7 and matrix B at addresses 8-RF within the Register File (RF).

### Pipelined Matrix Multiplication:
      Equation: 𝐷=𝐴×𝐵+𝐶
      Description: In addition to performing multiplication of matrices A and B (stored similarly to the non-pipelined mode),
      this mode adds the results to matrix C. Matrix C comprises results from previous calculations and is stored in the
      ScratchPad (SP) memory, enabling successive operations to build on earlier results.
## Control Register Configuration 
      Start Bit (LSB): Initiates the operation within the system.
      Mode Bit: Determines the operational mode of the system:
        A value of '1' activates the pipelined mode, allowing for the operation 
        A×B+C, which is essential for sequential processing tasks.
        A value of '0' sets the system to non-pipelined mode, suitable for isolated matrix multiplication tasks.
      Additional Bits: These are configured to store and reference the source and target addresses in the ScratchPad (SP),           matrix dimensions, and other relevant operational parameters.
## Conclusion
    The systolic architecture designed in this lab provides a robust framework for matrix multiplication, adaptable to both
    pipelined and non-pipelined operations. It is particularly well-suited for applications requiring efficient and rapid
    matrix computations with minimal memory overhead.


        
      
