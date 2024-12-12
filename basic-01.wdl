version 1.0

workflow HelloWorld {
    call HelloTask
}

task HelloTask {
    command {
        echo "Hello, World!"
    }
    output {
        String message = read_string(stdout())
    }
}
