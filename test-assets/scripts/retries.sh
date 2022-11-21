execute_with_retries() {
    command=$1
    number_of_retries=$2
    sleep_interval=$3

    if [[ -z $command ]]
    then
        echo "Expected the command to execute as the first parameter."
        exit 1
    fi

    if [[ -z $number_of_retries ]]
    then
        echo "Expected the number of times to retry the command as the second parameter."
        exit 1
    fi

    if [[ -z $sleep_interval ]]
    then
        echo "Expected the sleep interval between retries as the third parameter."
        exit 1
    fi

    echo "Attempting the following command with $number_of_retries retries and $sleep_interval seconds between each retry: '$command'"
    for i in $(seq 1 $number_of_retries); do [ $i -gt 1 ] && sleep $sleep_interval; $command && s=0 && break || s=$?; done; (exit $s)
}