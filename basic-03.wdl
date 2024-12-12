version 1.0

workflow FileProcessingPipeline {
    input {
        File input_file
        Int split_lines = 5
    }

    # Step 1: Split the input file into smaller chunks
    call SplitFile {
        input: input_file = input_file, lines_per_file = split_lines
    }

    # Step 2: Process each chunk (sort lines alphabetically)
    scatter (chunk in SplitFile.chunk_files) {
        call SortChunk {
            input: chunk_file = chunk
        }
    }

    # Step 3: Merge all sorted chunks
    call MergeFiles {
        input: sorted_files = SortChunk.sorted_file
    }

    # Step 4: Compress the merged file
    call CompressFile {
        input: file_to_compress = MergeFiles.merged_file
    }

    output {
        File final_compressed_file = CompressFile.compressed_file
    }
}

# Task: Split a large file into smaller chunks
task SplitFile {
    input {
        File input_file
        Int lines_per_file
    }

    command {
        split -l ~{lines_per_file} ~{input_file} chunk_
    }

    output {
        Array[File] chunk_files = glob("chunk_*")
    }

    runtime {
        docker: "ubuntu:latest"
    }
}

# Task: Sort each chunk alphabetically
task SortChunk {
    input {
        File chunk_file
    }

    command {
        sort ~{chunk_file} > sorted_~{basename(chunk_file)}
    }

    output {
        File sorted_file = "sorted_~{basename(chunk_file)}"
    }

    runtime {
        docker: "ubuntu:latest"
    }
}

# Task: Merge sorted chunks into one file
task MergeFiles {
    input {
        Array[File] sorted_files
    }

    command {
        cat ~{sep=' ' sorted_files} > merged_output.txt
    }

    output {
        File merged_file = "merged_output.txt"
    }

    runtime {
        docker: "ubuntu:latest"
    }
}

# Task: Compress the merged file
task CompressFile {
    input {
        File file_to_compress
    }

    command {
        gzip -c ~{file_to_compress} > ~{basename(file_to_compress)}.gz
    }

    output {
        File compressed_file = "~{basename(file_to_compress)}.gz"
    }

    runtime {
        docker: "ubuntu:latest"
    }
}
