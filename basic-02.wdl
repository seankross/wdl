version 1.0

workflow DataProcessingWorkflow {
    input {
        File input_file
        String prefix
    }

    call Preprocess {
        input: input_file = input_file
    }

    call Analysis {
        input: processed_file = Preprocess.output_file
    }

    call Postprocess {
        input: results = Analysis.results, prefix = prefix
    }

    output {
        File final_output = Postprocess.final_output
    }
}

task Preprocess {
    input {
        File input_file
    }

    command {
        # Simulate preprocessing (e.g., filtering, formatting)
        grep -v "^#" ~{input_file} > preprocessed.txt
    }

    output {
        File output_file = "preprocessed.txt"
    }

    runtime {
        docker: "ubuntu:latest"
    }
}

task Analysis {
    input {
        File processed_file
    }

    command <<<
        # Simulate analysis (e.g., statistical calculations)
        awk '{print $1, $2}' ~{processed_file} > analysis_results.txt
    >>>

    output {
        File results = "analysis_results.txt"
    }

    runtime {
        docker: "ubuntu:latest"
    }
}

task Postprocess {
    input {
        File results
        String prefix
    }

    command {
        # Simulate postprocessing (e.g., generating a report)
        mv ~{results} ~{prefix}_final_output.txt
    }

    output {
        File final_output = "~{prefix}_final_output.txt"
    }

    runtime {
        docker: "ubuntu:latest"
    }
}
