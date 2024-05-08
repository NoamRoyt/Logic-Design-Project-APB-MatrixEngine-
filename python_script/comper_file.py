def compare_files_ignore_whitespace(file_path1, file_path2):
    """
    Compare two files line by line, ignoring differences in whitespace. Additionally, count hits and misses
    and return a summary including details of misses.

    :param file_path1: Path to the first file
    :param file_path2: Path to the second file
    :return: Summary including counts of hits and misses, and details of misses
    """
    hit_count = 0
    miss_count = 0
    misses = []

    try:
        with open(file_path1, 'r') as file1, open(file_path2, 'r') as file2:
            for line_number, (line1, line2) in enumerate(zip(file1, file2), start=1):
                if line1.strip() == line2.strip():
                    hit_count += 1
                else:
                    miss_count += 1
                    misses.append((line_number, line1.strip(), line2.strip()))

            # Check for any remaining lines in either file
            for line in file1:
                miss_count += 1
                misses.append((line_number + 1, line.strip(), "No corresponding line"))
                line_number += 1
            for line in file2:
                miss_count += 1
                misses.append((line_number + 1, "No corresponding line", line.strip()))
                line_number += 1

    except Exception as e:
        return f"An error occurred: {e}"

    # Build the summary table or structure
    summary = {
        'hits': hit_count,
        'misses': miss_count,
        'details': misses
    }

    return summary


if __name__ == "__main__":
    file_path1 = 'C:/Users/97252/Desktop/lab1/Mat_Res.txt'
    file_path2 = 'C:/Users/97252/Desktop/lab1/matrix.txt'

    result = compare_files_ignore_whitespace(file_path1, file_path2)
    print(f"Summary:\nHits: {result['hits']}\nMisses: {result['misses']}")
    if result['misses'] > 0:
        print("Miss Details (Line Number, File1 Line, File2 Line):")
        for miss in result['details']:
            print(miss)